# Override rails database tasks since vertica database cannot be dropped/created
# with commands from the appliation

::Rake::Task["db:test:purge"].clear if ::Rake::Task.task_defined?("db:test:purge")

namespace :db do
  namespace :test do
    task :purge => [:environment, :load_config] do
      ::ActiveRecord::Base.establish_connection(:test)
      ::ActiveRecord::Base.connection.tables.each do |table|
        ::ActiveRecord::Base.connection.drop_table(table)
      end
    end
  end
end
