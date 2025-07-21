require 'bundler/setup'
require 'active_record'
require 'yaml'
require 'rake/testtask'

namespace :db do
  db_config = YAML.load_file(File.open('config/database.yml'), aliases: true)
  db = db_config[(ENV['RAILS_ENV'] || 'development')].merge({ schema_search_path: 'public' })

  desc "Create the database"
  task :create do
    ActiveRecord::Base.establish_connection(db.except('database'))
    ActiveRecord::Base.connection.create_database(db['database'])

    puts "Database created."
  end

  desc "Migrate the database"
  task :migrate do
    ActiveRecord::Base.establish_connection(db)
    ActiveRecord::Migrator.migrate("db/migrate/")
    Rake::Task["db:schema"].invoke
    puts "Database migrated."
  end

  desc "Drop the database"
  task :drop do
    ActiveRecord::Base.establish_connection(db)
    ActiveRecord::Base.connection.drop_database(db["database"])
    puts "Database deleted."
  end

  desc "Reset the database"
  task :reset => [:drop, :create, :migrate]

  namespace :schema do
    desc "Set up the database"
    task :load do
      ActiveRecord::Base.establish_connection(db)

      load 'db/schema.rb'
      puts "Schema is applied."
    end

    desc 'Create a db/schema.rb file that is portable against any DB supported by AR'
    task :dump do
      ActiveRecord::Base.establish_connection(db)
      require 'active_record/schema_dumper'
      filename = "db/schema.rb"
      File.open(filename, "w:utf-8") do |file|
        ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
      end
    end
  end
end

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
end

task default: :test
