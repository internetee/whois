require 'simplecov'
SimpleCov.start 'rails'

require 'minitest/autorun'
require 'mocha/minitest'
require 'active_record'
require 'yaml'

ENV['WHOIS_ENV'] ||= 'test'

# --- Prevent EventMachine from starting in tests ---
# This monkey-patch must run before whois server files are required.
require 'eventmachine'
module EventMachine
  class << self
    def run(*)
      yield if block_given?
    end

    def start_server(*)
      # no-op in tests to avoid binding real ports
    end

    def set_effective_user(*)
      # no-op in tests
    end
  end
end
# ---------------------------------------------------

class Minitest::Test
  def dbconfig
    return @dbconfig unless @dbconfig.nil?

    begin
      dbconf = YAML.load_file(File.expand_path('../config/database.yml', __dir__), aliases: true)
      @dbconfig = dbconf[ENV['WHOIS_ENV']]
    rescue NoMethodError => e
      warn "\n----> Please inspect config/database.yml for issues! Error: #{e}\n\n"
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
