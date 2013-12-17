class ActiveRecord::Base
  def self.vertica5_connection(config)
    config[:port] ||= 5433
    config[:url] = "jdbc:vertica://#{config[:host]}:#{config[:port]}/#{config[:database]}"
    config[:driver] = "com.vertica.jdbc.Driver"
    config[:prepared_statements] = false
    config[:connection_alive_sql] = "SELECT 1;"
    config[:adapter_class] = ::ActiveRecord::ConnectionAdapters::VerticaAdapter

    jdbc_connection(config)
  end

  class << self
    # connection methods should be the same 
    alias_method :vertica7_connection, :vertica5_connection
    alias_method :vertica6_connection, :vertica5_connection
    alias_method :jdbcvertica7_connection, :vertica5_connection
    alias_method :jdbcvertica6_connection, :vertica5_connection
    alias_method :jdbcvertica5_connection, :vertica5_connection
  end
end
