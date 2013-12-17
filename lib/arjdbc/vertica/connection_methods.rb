class ActiveRecord::Base
  def self.vertica6_connection(config)
    config[:port] ||= 5433
    config[:url] ||= "jdbc:vertica://#{config[:host]}:#{config[:port]}/#{config[:database]}"
    config[:driver] ||= "com.vertica.jdbc.Driver"
    config[:adapter_class] ||= ::ActiveRecord::ConnectionAdapters::VerticaAdapter

    jdbc_connection(config)
  end
end
