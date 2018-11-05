require 'bundler/setup'

# Standalone migration tasks
require 'active_record_migrations'
ActiveRecordMigrations.configure do |c|
  c.yaml_config = 'config/database.yml'
end
ActiveRecordMigrations.load_tasks

# Minitest task
require "rake/testtask"
Rake::TestTask.new do |t|
  t.name = "test"
  t.warning = false
  t.test_files = FileList["test/**/*test.rb"]
end
