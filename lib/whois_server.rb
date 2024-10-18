require 'bundler/setup'
require 'eventmachine'
require 'active_record'
require 'yaml'
require 'syslog/logger'
load File.expand_path('../../app/models/whois_record.rb', __FILE__)
require_relative '../app/validators/unicode_validator'

module YAML
  def self.properly_load_file(path)
    YAML.load_file path, aliases: true
  rescue ArgumentError
    YAML.load_file path
  end
end


module WhoisServer
  def logger
    @logger ||= Syslog::Logger.new 'whois'
  end

  def dbconfig
    return @dbconfig unless @dbconfig.nil?
    begin
      dbconf = YAML.properly_load_file(File.open(File.expand_path('../../config/database.yml', __FILE__)))
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
    ip = get_client_ip
    return if ip.nil?

    name = sanitize_domain_name(data)
    return if name.nil?

    process_whois_request(name, ip, data)
    close_connection_after_writing
  end

  private

  def get_client_ip
    Socket.unpack_sockaddr_in(get_peername)
  rescue StandardError::TypeError => e
    logger.error("uncaught #{e} exception while handling connection: #{e.message}")
    close_connection
    nil
  end

  def sanitize_domain_name(data)
    validator = UnicodeValidator.new(data)
    if !validator.valid?
      logger.info "#{ip}: requested domain name is not in utf-8"
      send_data(invalid_encoding_msg)
      close_connection_after_writing
      return nil
    end

    SimpleIDN.to_unicode(data.strip.downcase)
  end

  def process_whois_request(name, ip, original_data)
    if special_ee_domain?(name)
      handle_special_ee_domain(name, ip, original_data)
    else
      handle_regular_domain(name, ip, original_data)
    end
  end

  def special_ee_domain?(name)
    %w[pri.ee fie.ee med.ee com.ee].include?(name)
  end

  def handle_special_ee_domain(name, ip, original_data)
    logger.info "#{ip}: requested: #{original_data} [searched by: #{name}; Special .ee second-level domain]"
    send_data special_ee_domain_msg(name)
  end

  def handle_regular_domain(name, ip, original_data)
    whois_record = WhoisRecord.find_by(name: name)

    if whois_record
      logger.info "#{ip}: requested: #{original_data} [searched by: #{name}; Record found with id: #{whois_record.try(:id)}]"
      send_data whois_record.unix_body
    else
      logger.info "#{ip}: requested: #{original_data} [searched by: #{name}; No record found]"
      provide_data_body(name)
    end
  end

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
    "\nPolicy error: please study \"Requirements for the registration of a Domain Name\" of .ee domain regulations. " \
    "https://www.internet.ee/domains/ee-domain-regulation#registration-of-domain-names" + footer_msg
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

  def special_ee_domain_msg(domain)
    <<~MSG
      Estonia .ee Top Level Domain WHOIS server

      Domain:
      name:       #{domain}
      status:     Blocked

      Estonia .ee Top Level Domain WHOIS server
      More information at http://internet.ee

    MSG
  end
end

EventMachine.run do
  EventMachine.start_server ENV['HOST'] || '0.0.0.0', ENV['PORT'] || '43', WhoisServer
  EventMachine.set_effective_user ENV['WHOIS_USER'] || `whoami`.strip
end
