module Activerecord::Jdbcvertica::Adapter
  class Railtie < ::Rails::Railtie

    rake_tasks do
      if defined?(Rake)
        load "tasks/vertica_database_tasks.rake"
      end
    end

  end
end
