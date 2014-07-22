require 'arjdbc/vertica/column'
require 'securerandom'

# Load a mapping for the "text" type that will actually work
::ActiveRecord::ConnectionAdapters::JdbcTypeConverter::AR_TO_JDBC_TYPES[:text] << lambda { |r| r['type_name'] =~ /varchar$/i }

# Override sequence_name to work without setting explicitly in models
module ::ActiveRecord
  class Base
    def self.sequence_name
      "#{self.table_name}_#{self.primary_key || 'id'}_seq"
    end

    def self.bulk_insert(columns, data)
      connection.bulk_insert(self.table_name, self.primary_key, self.sequence_name, columns, data)
    end

    def self.bulk_insert_records(*records)
      records.flatten!
      data = []
      column_names_without_id = column_names.reject { |name| name == self.primary_key }

      records.each do |record|
        values = []
        column_names_without_id.each do |column_name|
          if ::ArJdbc::Vertica::TIMESTAMP_COLUMNS.include?("#{column_name}")
            # Set the Timestampt if it is not already set
            values << (record.__send__("#{column_name}") || ::ArJdbc::Vertica.current_time)
          else
            values << record.__send__("#{column_name}")
          end
        end
        data << values
      end

      bulk_insert(column_names_without_id, data)
    end
  end
end

##
# Adapter
#
module ::ArJdbc
  module Vertica
    ADAPTER_NAME = 'Vertica'.freeze
    INSERT_TABLE_EXTRACTION = /into\s+(?<table_name>[^\(]*).*values\s*\(/im

    NATIVE_DATABASE_TYPES = {
      :primary_key => "INTEGER NOT NULL PRIMARY KEY",
      :string      => { :name => "varchar", :limit => 255 },
      :text        => { :name => "varchar", :limit => 15000 },
      :integer     => { :name => "integer" },
      :float       => { :name => "float" },
      :decimal     => { :name => "decimal" },
      :datetime    => { :name => "datetime" },
      :timestamp   => { :name => "timestamp" },
      :time        => { :name => "time" },
      :date        => { :name => "date" },
      :binary      => { :name => "bytea" },
      :boolean     => { :name => "boolean" },
      :xml         => { :name => "xml" }
    }

    TIMESTAMP_COLUMNS = [
      "created_at",
      "created_on",
      "updated_at",
      "updated_on"
    ]

    def self.current_time
      ::ActiveRecord::Base.default_timezone == :utc ? ::Time.now.utc : ::Time.now
    end

    def adapter_name
      ADAPTER_NAME
    end

    def add_index(*args)
      # no op
    end

    def bulk_insert(table_name, primary_key, sequence_name, column_names, data)
      sql = "INSERT INTO #{table_name} (#{column_names.join(',')},#{primary_key || 'id'}) #{$/}"
      row_count = data.size
      last_index = row_count - 1
      temp_table_name = vertica_random_temp_table_name
      column_types = vertica_column_types_for(table_name, column_names)

      sql << "SELECT #{temp_table_name}.*, #{sequence_name}.nextval FROM ("
      data.each_with_index do |data_row, index|
        sql << "SELECT #{vertica_bulk_insert_select_for(column_types, data_row)} "

        unless index == last_index
          sql << "#{$/} UNION ALL #{$/}"
        end
      end
      sql << ") #{temp_table_name};"

      execute(sql)
    end

    def columns(table_name, name = nil)
      sql = "SELECT * from V_CATALOG.COLUMNS WHERE table_name = '#{table_name}';"
      raw_columns = execute(sql, name || "SCHEMA")

      columns = raw_columns.map do |raw_column|
        ::ActiveRecord::ConnectionAdapters::VerticaColumn.new(
          raw_column['column_name'],
          raw_column['column_default'],
          raw_column['data_type'],
          raw_column['is_nullable'], 
          raw_column['is_identity']
        )
      end

      return columns
    end

    ##
    # Override create_table to create the sequences
    # needed to manage primary keys
    #
    def create_table(table_name, options = {})
      super

      sequence_name = sequence_name_for(table_name, options[:primary_key] || "id")
      unless sequence_exists?(sequence_name)
        create_sequence(sequence_name)
      end
    end

    def create_sequence(sequence_name)
      sql = <<-SQL
        CREATE SEQUENCE #{sequence_name};
      SQL

      return execute(sql)
    end

    def drop_sequence(sequence_name)
      sql = <<-SQL
        DROP SEQUENCE #{sequence_name};
      SQL

      return execute(sql)
    end

    def drop_table(table_name, options = {})
      super

      sequence_name = sequence_name_for(table_name, options[:primary_key] || "id")
      if sequence_exists?(sequence_name)
        drop_sequence(sequence_name)
      end
    end

    ##
    # Vertica JDBC does not work with JDBC GET_GENERATED_KEYS
    # so we need to execute the sql raw and then lookup the 
    # LAST_INSERT_ID() that occurred in this "session"
    #
    def exec_insert(sql, name, binds, primary_key = nil, sequence_name = nil)
      # Execute the SQL
      execute(sql, name, binds)
    end

    def extract_table_ref_from_insert_sql(sql)
      match_data = INSERT_TABLE_EXTRACTION.match(sql)
      match_data[:table_name].strip if match_data[:table_name]
    end

    def native_database_types
      NATIVE_DATABASE_TYPES
    end 

    def next_insert_id_for(sequence_name)
      return select_value("SELECT NEXTVAL('#{sequence_name}');")
    end

    def next_sequence_value(sequence_name)
      next_insert_id_for(sequence_name)
    end

    def prefetch_primary_key?(table_name = nil)
      true
    end

    def primary_key_for(table_name)
      primary_keys(table_name)
    end

    ##
    # Vertica should "auto-discover" the primary key if marked on the table
    #
    def primary_keys(table_name)
      @primary_keys ||= {}
      return @primary_keys[table_name] if @primary_keys[table_name]

      keys = self.execute("SELECT column_name FROM v_catalog.primary_keys WHERE table_name = '#{table_name}';")
      @primary_keys[table_name] = [ keys.first && keys.first['column_name'] ]
      @primary_keys[table_name]
    end

    ##
    # Vertica does not allow the table name to prefix the columns when
    # setting a value, this is not a pleasant work-around, but it works
    #
    def quote_table_name_for_assignment(table, attr)
      quote_column_name(attr)
    end

    def remove_index(*args)
      # no op
    end

    def rename_index(*args)
      # no op
    end

    def sequence_exists?(sequence_name)
      sql = <<-SQL
        SELECT 1 from v_catalog.sequences WHERE sequence_name = '#{sequence_name}';
      SQL

      sequence_present = select_value(sql)
      return sequence_present == 1
    end

    def sequence_name_for(table_name, primary_key_name = nil)
      "#{table_name}_#{primary_key_name || 'id'}_seq"
    end

    ##
    # Custom Vertica methods to allow
    # bulk insert operations on a db engine
    # that does not support multi-insert
    def vertica_bulk_insert_select_for(column_types, data_row)
      insert_values = data_row.each_with_index.map do |value, index|
        "#{quote(value)}::#{column_types[index]}"
      end

      return insert_values.join(",")
    end

    def vertica_column_types_for(table_name, column_names)
      column_names.map { |column_name| vertica_column_type_for(table_name, column_name) }
    end

    def vertica_column_type_for(table_name, column_name)
      column = vertica_memoized_columns(table_name).find { |column| column.name == "#{column_name}" }
      return column.sql_type if column
      return nil
    end

    def vertica_memoized_columns(table_name, name = nil)
      @vertica_memoized_columns ||= {}
      normalized_table_name = "#{table_name}"

      unless @vertica_memoized_columns.has_key?(normalized_table_name)
        @vertica_memoized_columns[normalized_table_name] = columns(table_name, name)
      end

      return @vertica_memoized_columns[normalized_table_name]
    end

    def vertica_random_temp_table_name
      # Generate a Random "table_name" to prevent collisions (not sure if needed)
      "temporary_table_#{::SecureRandom.hex}"
    end

  end
end

module ActiveRecord::ConnectionAdapters
  class VerticaAdapter < JdbcAdapter
    include ::ArJdbc::Vertica
  end
end
