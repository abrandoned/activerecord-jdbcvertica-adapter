module ActiveRecord

  module ConnectionAdapters
    class VerticaColumn < Column
      def initialize(name, default, sql_type = nil, null = true, primary_key = false)
        super(name, self.class.extract_value_from_default(default), sql_type, null)
        # Might need to set if it is primary key below? don't know
        # self.primary = primary_key
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
