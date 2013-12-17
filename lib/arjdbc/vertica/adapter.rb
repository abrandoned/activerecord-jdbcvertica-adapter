# Load a mapping for the "text" type that will actually work
::ActiveRecord::ConnectionAdapters::JdbcTypeConverter::AR_TO_JDBC_TYPES[:text] << lambda { |r| r['type_name'] =~ /varchar$/i }

module ::ArJdbc
  module Vertica
    ADAPTER_NAME = 'Vertica'.freeze

    NATIVE_DATABASE_TYPES = {
      :primary_key => "auto_increment", 
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

    def adapter_name
      ADAPTER_NAME
    end

    ##
    # Vertica JDBC does not work with JDBC GET_GENERATED_KEYS
    # so we need to execute the sql raw and then lookup the 
    # LAST_INSERT_ID() that occurred in this "session"
    #
    def exec_insert(sql, name, binds, *args)
      execute(sql, name, binds)

      return select_value("SELECT LAST_INSERT_ID();")
    end

    ##
    # Vertica does not allow the table name to prefix the columns when
    # setting a value, this is not a pleasant work-around, but it works
    #
    def exec_update(sql, name, binds)
      set_split = sql.split("SET")
      before_set = set_split.first
      after_set = set_split.last
      table_name = before_set.split("UPDATE").last.strip

      new_sql = "#{before_set} SET #{after_set.gsub(table_name + '.', '')}"

      return super(new_sql, name, binds)
    end

    def native_database_types
      NATIVE_DATABASE_TYPES
    end 

  end
end

module ActiveRecord::ConnectionAdapters
  class VerticaAdapter < JdbcAdapter
    include ::ArJdbc::Vertica

    def rename_index(*args)
      raise ArgumentError, "rename_index does not work on Vertica"
    end
  end
end
