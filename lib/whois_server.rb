require 'bundler/setup'
require 'eventmachine'
require 'active_record'
require 'yaml'

pwd  = File.dirname(File.expand_path(__FILE__))
load pwd + '/../app/models/domain.rb'

WHOIS_ENV = 'development'

module WhoisServer
  def dbconfig
    pwd  ||= File.dirname(File.expand_path(__FILE__))
    dbconfig ||= YAML::load(File.open("#{pwd}/../config/database.yml"))[WHOIS_ENV]
  end

  def connection
    con ||= ActiveRecord::Base.establish_connection(dbconfig)
  end

  def receive_data(data)
    connection
    domain = Domain.where(name: data.strip).first
    if domain.nil?
      send_data "Not found: #{data}" 
    else
      send_data domain.whois_body 
    end
    close_connection_after_writing
  end
end

EventMachine::run {
  EventMachine::start_server "127.0.0.1", 1043, WhoisServer
}
