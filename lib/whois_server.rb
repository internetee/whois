# frozen_string_literal: true

require 'json'
require 'bundler/setup'
require 'eventmachine'
require 'active_record'
require 'yaml'
require 'syslog/logger'
load File.expand_path('../app/models/whois_record.rb', __dir__)
require_relative '../app/validators/unicode_validator'
require_relative 'logging'

# This module extends the YAML module to properly load files with aliases.
module YAML
  def self.properly_load_file(path)
    YAML.load_file path, aliases: true
  rescue ArgumentError
    YAML.load_file path
  end
end

# This module handles WHOIS server operations, including receiving data,
# validating domain names, and querying the database for WHOIS records.
module WhoisServer
  include Logging

  def dbconfig
    return @dbconfig unless @dbconfig.nil?

    begin
      dbconf = YAML.properly_load_file(File.open(File.expand_path('../config/database.yml', __dir__)))
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
    ip = extract_ip
    return unless ip

    if invalid_data?(data, ip)
      send_data(invalid_encoding_msg)
      close_connection_after_writing
      return
    end

    process_whois_request(data, ip)
    close_connection_after_writing
  end

  private

  def extract_ip
    Socket.unpack_sockaddr_in(get_peername)
  rescue StandardError => e
    logger.error("uncaught #{e} exception while handling connection: #{e.message}")
    close_connection
    nil
  end

  def invalid_data?(data, ip)
    validator = UnicodeValidator.new(data)
    if !validator.valid?
      log_invalid_data(ip, data)
      true
    else
      false
    end
  end

  def process_whois_request(data, ip)
    cleaned_data = data.strip
    name = SimpleIDN.to_unicode(cleaned_data.downcase)
    whois_record = WhoisRecord.find_by(name: name)

    if whois_record
      log_record_found(ip, cleaned_data, name, whois_record)
      send_data whois_record.unix_body
    else
      log_record_not_found(ip, cleaned_data, name)
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
    (formatted_domain_name =~ domain_name_regexp) != nil
  end

  def policy_error_msg
    "\nPolicy error: please study \"Requirements for the registration of a Domain Name\" of .ee domain regulations. " \
    'https://www.internet.ee/domains/ee-domain-regulation#registration-of-domain-names' + footer_msg
  end

  def no_entries_msg
    "\nDomain not found#{footer_msg}"
  end

  def no_body_msg
    "\nThere was a technical issue with whois body, please try again later!#{footer_msg}"
  end

  def invalid_encoding_msg
    "\nERROR: invalid encoding, please use utf-8#{footer_msg}"
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
