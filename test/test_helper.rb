gem "minitest"
require 'minitest/autorun'

require 'active_record'
require 'yaml'

ENV['WHOIS_ENV'] ||= 'test'
require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/app/models/version/'
  add_filter '/lib/action_controller/'
  add_filter '/lib/core_monkey_patches/'
  add_filter '/lib/daemons/'
  add_filter '/lib/gem_monkey_patches/'
  add_filter '/lib/tasks/'
end

class Minitest::Test
  def dbconfig
    return @dbconfig unless @dbconfig.nil?
    begin
      dbconf = YAML.load(File.open(File.expand_path('../../config/database.yml', __FILE__)))
      @dbconfig = dbconf[(ENV['WHOIS_ENV'])]
    rescue NoMethodError => e
      logger.fatal "\n----> Please inspect config/database.yml for issues! Error: #{e}\n\n"
    end
  end

  def connection
    @connection ||= ActiveRecord::Base.establish_connection(dbconfig)
  end

  def setup
    super

    connection
  end
end
