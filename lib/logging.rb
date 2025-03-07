# lib/logging.rb
require 'logger'

module Logging
  def logger
    @logger ||= Logger.new($stdout, progname: 'whois').tap do |log|
      log.formatter = proc do |severity, datetime, progname, msg|
        "[#{progname}] #{msg}\n"
      end
    end
  end

  def log_json(payload)
    base_log = {
      timestamp: Time.now.utc.iso8601(3),
      level: 'info',
      logger: {
        name: 'whois',
        version: ENV['APP_VERSION'] || '1.0'
      },
      service: {
        name: 'whois',
        type: 'whois_server',
        env: ENV['WHOIS_ENV'] || 'development'
      },
      event: {
        time: Time.now.utc.iso8601(3),
        status: payload[:status] || (payload[:record_found] ? 'success' : 'not_found')
      },
      source: {
        host: Socket.gethostname,
        ip: Socket.ip_address_list.find { |addr| addr.ipv4? && !addr.ipv4_loopback? }&.ip_address
      },
      client: {
        ip: payload[:ip],
        port: payload[:session_id]
      },
      user: ENV['WHOIS_USER'] || `whoami`.strip,
      data: {
        query: payload[:domain],
        normalized_query: payload[:searched_by],
        record_found: payload[:record_found],
        record_id: payload[:record_id]
      },
      error: payload[:message],
      metadata: {
        protocol: 'whois',
        version: '1.0'
      }
    }.compact

    logger.info(base_log.to_json)
  end

  def log_invalid_encoding(ip, data)
    log_json(
      ip: ip[1],
      session_id: ip[0],
      domain: data,
      status: 'invalid_encoding',
      message: 'Requested domain name is not in UTF-8'
    )
  end

  def log_policy_error(ip, cleaned_data, name)
    log_json(
      ip: ip[1],
      session_id: ip[0],
      domain: cleaned_data,
      searched_by: name,
      status: 'policy_error',
      message: 'Domain name format does not comply with policy'
    )
  end

  def log_record_found(ip, cleaned_data, name, whois_record)
    log_json(
      ip: ip[1],
      session_id: ip[0],
      domain: cleaned_data,
      searched_by: name,
      record_found: true,
      record_id: whois_record.id,
      status: 'success'
    )
  end

  def log_record_not_found(ip, cleaned_data, name)
    log_json(
      ip: ip[1],
      session_id: ip[0],
      domain: cleaned_data,
      searched_by: name,
      record_found: false,
      status: 'not_found'
    )
  end
end
