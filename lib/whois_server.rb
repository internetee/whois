require 'bundler/setup'
require 'eventmachine'
require 'active_record'
require 'yaml'
load File.expand_path('../../app/models/domain.rb', __FILE__)

module WhoisServer
  def dbconfig
    @dbconfig ||= YAML.load(File.open(File.expand_path('../../config/database.yml', __FILE__)))[WHOIS_ENV]
  end

  def connection
    ActiveRecord::Base.establish_connection(dbconfig)
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

EventMachine.run do
  EventMachine.start_server '127.0.0.1', 1043, WhoisServer
end
