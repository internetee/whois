require 'bundler/setup'
require 'eventmachine'
require 'active_record'
require 'yaml'
require 'syslog/logger'
load File.expand_path('../../app/models/whois_record.rb', __FILE__)
require_relative '../app/validators/unicode_validator'

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
    begin
      ip = Socket.unpack_sockaddr_in(get_peername)
    rescue StandardError::TypeError => e
      logger.error("uncaught #{e} exception while handling connection: #{e.message}")
      close_connection
    end

    validator = UnicodeValidator.new(data)
    invalid_data = !validator.valid?

    if invalid_data
      logger.info "#{ip}: requested domain name is not in utf-8"
      send_data(invalid_encoding_msg)
      close_connection_after_writing
      return
    end

    name = data.strip
    name = name.downcase
    name = SimpleIDN.to_unicode(name)
    whois_record = WhoisRecord.find_by(name: name)

    if whois_record
      logger.info "#{ip}: requested: #{data} [searched by: #{name}; Record found with id: #{whois_record.try(:id)}]"
      send_data whois_record.unix_body
    else
      logger.info "#{ip}: requested: #{data} [searched by: #{name}; No record found]"
      provide_data_body(name)
    end
    close_connection_after_writing
  end

  private

  def provide_data_body(domain_name)
    return send_data(no_entries_msg) if domain_valid_format?(domain_name)

    send_data(policy_error_msg)
  end

  def domain_valid_format?(domain_name)
    domain_name_regexp = /\A[a-z0-9\-\u00E4\u00F5\u00F6\u00FC\u0161\u017E]{2,61}\.
    ([a-z0-9\-\u00E4\u00F5\u00F6\u00FC\u0161\u017E]{2,61}\.)?[a-z0-9]{1,61}\z/x

    formatted_domain_name = domain_name.strip.downcase
    nil != (formatted_domain_name =~ domain_name_regexp)
  end

  def policy_error_msg
    "\nPolicy error" + footer_msg
  end

  def no_entries_msg
    "\nDomain not found" + footer_msg
  end

  def no_body_msg
    "\nThere was a technical issue with whois body, please try again later!" +
    footer_msg
  end

  def invalid_encoding_msg
    "\nERROR: invalid encoding, please use utf-8" +
    footer_msg
  end

  def footer_msg
    "\n\nEstonia .ee Top Level Domain WHOIS server\n" \
    "More information at http://internet.ee\n"
  end
end

EventMachine.run do
  EventMachine.start_server ENV['HOST'] || '0.0.0.0', ENV['PORT'] || '43', WhoisServer
  EventMachine.set_effective_user ENV['WHOIS_USER'] || `whoami`.strip
end
