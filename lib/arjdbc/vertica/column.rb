module ActiveRecord

  module ConnectionAdapters
    class VerticaColumn < Column
      def initialize(name, default, data_type_id, table_name, sql_type = nil, null = true, default_function = nil, primary_key = false)
        super(name,
              default = self.class.extract_value_from_default(default),
              self.class.sql_type_metadata(sql_type, data_type_id),
              null,
              table_name
        )

        # Might need to set if it is primary key below? don't know
        # self.primary = primary_key
      end

      def self.sql_type_metadata(sql_type, data_type_id)
        cast_type = self.cast_type_from_data_type_id(data_type_id) || self.cast_type_from_sql_type(sql_type)
        ActiveRecord::ConnectionAdapters::SqlTypeMetadata.new(sql_type: sql_type, type: cast_type.type, limit: cast_type.limit, precision: cast_type.precision, scale: cast_type.scale)
      end

      def self.cast_type_from_data_type_id(data_type_id)
        case data_type_id
        when 5 #, 'bool', :bool
          ::ActiveRecord::Type::Boolean.new
        when 6 #, 'integer', :integer
          ::ActiveRecord::Type::Integer.new
        when 7 #, 'float', :float
          ::ActiveRecord::Type::Float.new
        when 8 #, 'char', :unicode_string
          ::ActiveRecord::Type::String.new
        when 9 #, 'varchar', :unicode_string
          ::ActiveRecord::Type::String.new
        when 10 #, 'date', :date
          ::ActiveRecord::Type::Date.new
        when 11 #, 'time'
          ::ActiveRecord::Type::Time.new
        when 12 #, 'timestamp', :timestamp
          ::ActiveRecord::Type::DateTime.new
        when 13 #, 'timestamp_tz', :timestamp
          ::ActiveRecord::Type::DateTime.new
        when 14 #, 'time_tz'
          ::ActiveRecord::Type::DateTime.new
        when 16 #, 'numeric', :bigdecimal
          ::ActiveRecord::Type::Decimal.new
        when 17 #, 'bytes', :binary_string
          ::ActiveRecord::Type::Binary.new
        when 115 #, 'long varchar', :unicode_string
          ::ActiveRecord::Type::String.new
        else
          nil
        end
      end

      def self.cast_type_from_sql_type(sql_type)
        case "#{sql_type}"
        when /bool/i # :bool
          ::ActiveRecord::Type::Boolean.new
        when /integer/i # :integer
          ::ActiveRecord::Type::Integer.new
        when /float/i # :float
          ::ActiveRecord::Type::Float.new
        when /^char/i # :unicode_string
          ::ActiveRecord::Type::String.new
        when /varchar/i # :unicode_string
          ::ActiveRecord::Type::String.new
        when /long varchar/i # :unicode_string
          ::ActiveRecord::Type::String.new
        when /date/i # :date
          ::ActiveRecord::Type::Date.new
        when /time$/i
          ::ActiveRecord::Type::Time.new
        when /timestamp$/i # :timestamp
          ::ActiveRecord::Type::DateTime.new
        when /timestamp_tz/i # :timestamp
          ::ActiveRecord::Type::DateTime.new
        when /time_tz/i
          ::ActiveRecord::Type::DateTime.new
        when /numeric/i # :bigdecimal
          ::ActiveRecord::Type::Decimal.new
        when /bytes/i # :binary_string
          ::ActiveRecord::Type::Binary.new
        else
          nil
        end
      end

      def self.extract_value_from_default(default)
        case default
          # Numeric types
        when /\A\(?(-?\d+(\.\d*)?\)?)\z/ then
          $1
          # Character types
        when /\A'(.*)'::(?:character varchar|varying|bpchar|text)\z/m then
          $1
          # Character types (8.1 formatting)
        when /\AE'(.*)'::(?:character varchar|varying|bpchar|text)\z/m then
          $1.gsub(/\\(\d\d\d)/) { $1.oct.chr }
          # Binary data types
        when /\A'(.*)'::bytea\z/m then
          $1
          # Date/time types
        when /\A'(.+)'::(?:time(?:stamp)? with(?:out)? time zone|date)\z/ then
          $1
        when /\A'(.*)'::interval\z/ then
          $1
          # Boolean type
        when 'true' then
          true
        when 'false' then
          false
          # Geometric types
        when /\A'(.*)'::(?:point|line|lseg|box|"?path"?|polygon|circle)\z/ then
          $1
          # Network address types
        when /\A'(.*)'::(?:cidr|inet|macaddr)\z/ then
          $1
          # Bit string types
        when /\AB'(.*)'::"?bit(?: varying)?"?\z/ then
          $1
          # XML type
        when /\A'(.*)'::xml\z/m then
          $1
          # Arrays
        when /\A'(.*)'::"?\D+"?\[\]\z/ then
          $1
          # Object identifier types
        when /\A-?\d+\z/ then
          $1
        else
          # Anything else is blank, some user type, or some function
          # and we can't know the value of that, so return nil.
          nil
        end
      end
    end
  end

end
