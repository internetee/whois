require 'bundler/setup'
require 'eventmachine'
require 'active_record'
require 'yaml'
load 'app/models/domain.rb'

WHOIS_ENV = 'development'

module WhoisServer
  def dbconfig
    dbconfig = YAML::load(File.open('config/database.yml'))[WHOIS_ENV]
  end

  def connection
    con ||= ActiveRecord::Base.establish_connection(dbconfig)
  end

  def receive_data(data)
    connection
    domain = Domain.where(name: data.strip).first
    send_data domain.body unless domain.nil?
    close_connection_after_writing
  end
end

EventMachine::run {
  EventMachine::start_server "127.0.0.1", 1043, WhoisServer
}
