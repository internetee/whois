require 'bundler/setup'
require 'eventmachine'
require 'active_record'
require 'yaml'
require 'syslog/logger'
load File.expand_path('../../app/models/whois_record.rb', __FILE__)

module WhoisServer
  def logger
    @logger ||= Syslog::Logger.new 'whois'
  end

  def dbconfig
    return @dbconfig unless @dbconfig.nil?
    begin
      dbconf = YAML.load(File.open(File.expand_path('../../config/database.yml', __FILE__)))
      @dbconfig = dbconf[(ENV['WHOIS_ENV'] || 'development')]
    rescue NoMethodError => e
      logger.fatal "\n----> Please inspect config/database.yml for issues! Error: #{e}\n\n"
    end
  end

  def connection
    @connection ||= ActiveRecord::Base.establish_connection(dbconfig)
  end

  def receive_data(data)
    connection
    ip = Socket.unpack_sockaddr_in(get_peername)
    name = data.strip
    name = name.downcase
    name = SimpleIDN.to_unicode(name)
    whois_record = WhoisRecord.find_by(name: name)    

    if whois_record.nil?
      logger.info "#{ip}: requested: #{data} [searched by: #{name}; No record found]"
      send_data no_entries_msg
    elsif whois_record.body.blank?
      logger.info "#{ip}: requested: #{data} [searched by: #{name}; Record found with id: #{whois_record.try(:id)} but body was EMPTY]"
      send_data no_body_msg 
    else
      logger.info "#{ip}: requested: #{data} [searched by: #{name}; Record found with id: #{whois_record.try(:id)}]"
      send_data whois_record.body
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
  EventMachine.start_server '0.0.0.0', 43, WhoisServer
  EventMachine.set_effective_user ENV['WHOIS_USER'] || `whoami`.strip
end
