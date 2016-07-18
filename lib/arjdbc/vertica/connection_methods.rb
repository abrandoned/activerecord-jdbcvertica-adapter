class ActiveRecord::Base
  def self.parse_port_from_host(host)
    # looking for vertica_host_1:2098
    return nil unless host.include?(":")
    host.split(":").last
  end

  def self.trim_port_from_host(host)
    return host unless host.include?(":")
    host_parts = host.split(":")
    host_parts.pop
    host_parts.join(":")
  end

  def self.vertica5_connection(config)
    current_host = nil
    current_port = nil

    if config[:hosts] && config[:hosts].is_a?(Array)
      current_host = config[:hosts].sample
      current_port = parse_port_from_host(current_host)
      current_host = trim_port_from_host(current_host)
    end

    current_host ||= config[:host]
    current_port ||= config[:port]
    config[:url] = "jdbc:vertica://#{current_host}:#{current_port}/#{config[:database]}"
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
