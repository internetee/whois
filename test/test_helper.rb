require 'minitest/autorun'
require 'mocha/minitest'
require 'active_record'
require 'yaml'

ENV['WHOIS_ENV'] ||= 'test'

require 'simplecov'
SimpleCov.start 'rails'

class Minitest::Test
  def dbconfig
    return @dbconfig unless @dbconfig.nil?

    begin
      dbconf = YAML.load_file(File.open(File.expand_path('../config/database.yml', __dir__)), aliases: true)
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
