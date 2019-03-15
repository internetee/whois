require 'bundler/setup'

# Minitest task
require "rake/testtask"
Rake::TestTask.new do |t|
  t.name = "test"
  t.warning = false
  t.test_files = FileList["test/**/*test.rb"]
end
