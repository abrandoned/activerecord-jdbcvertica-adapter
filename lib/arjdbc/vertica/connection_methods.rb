class ActiveRecord::Base
  def self.vertica_connection(config)
    config[:port] || 5433
    config[:url] ||= "jdbc:vertica://#{config[:host]}:#{config[:port]}/#{config[:database]}"
    config[:driver] ||= "com.vertica.jdbc.Driver"

    jdbc_connection(config)
  end
end
