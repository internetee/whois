require 'bundler/setup'
require 'eventmachine'
require 'active_record'
require 'yaml'
load File.expand_path('../../app/models/domain.rb', __FILE__)

module WhoisServer
  def dbconfig
    return @dbconfig unless @dbconfig.nil?
    begin
      dbconf = YAML.load(File.open(File.expand_path('../../config/database.yml', __FILE__)))
      @dbconfig = dbconf[ENV['WHOIS_ENV']]
    rescue NoMethodError => e
      $stderr.puts "\n----> Please inspect config/database.yml for issues! Error: #{e}\n\n"
    end
  end

  def connection
    ActiveRecord::Base.establish_connection(dbconfig)
  end

  def receive_data(data)
    connection
    domain = Domain.where(name: data.strip).first
    if domain.nil?
      send_data no_entries_msg
    elsif domain.whois_body.blank?
      send_data no_body_msg 
    else
      send_data domain.whois_body + footer_msg
    end
    close_connection_after_writing
  end

  private

  def no_entries_msg
    "\nDomain not found" + footer_msg
  end

  def no_body_msg
    "\nThere was a technical issue with whois body, please try again later!" +
    footer_msg
  end

  def footer_msg
    "\n\nEstonia .ee Top Level Domain WHOIS server\n" \
    "More information at http://internet.ee\n"
  end
end

EventMachine.run do
  EventMachine.start_server '0.0.0.0', 1043, WhoisServer
end
