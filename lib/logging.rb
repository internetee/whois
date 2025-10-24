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
    base_log = build_base_log(payload)
    safe_log = sanitize_for_json(base_log)
    logger.info(safe_log.to_json)
  rescue JSON::GeneratorError, Encoding::UndefinedConversionError => e
    logger.error("[ERROR] JSON serialization failed: #{e.class} - #{e.message}")
    logger.error("[CONTEXT] Original payload: #{payload.inspect}")
  end

  private

  def sanitize_for_json(value)
    case value
    when String
      value.dup.encode('UTF-8', invalid: :replace, undef: :replace, replace: '�').scrub('�')
    when Array
      value.map { |item| sanitize_for_json(item) }
    when Hash
      value.transform_values { |item| sanitize_for_json(item) }
    else
      value
    end
  end

  # rubocop:disable Metrics/MethodLength
  def build_base_log(payload)
    {
      timestamp: current_timestamp,
      level: 'info',
      logger: logger_info,
      service: service_info,
      event: event_info(payload),
      source: source_info,
      client: client_info(payload),
      user: current_user,
      data: data_info(payload),
      error: payload[:message],
      metadata: metadata_info
    }.compact
  end
  # rubocop:enable Metrics/MethodLength

  def current_timestamp
    Time.now.utc.iso8601(3)
  end

  def logger_info
    {
      name: 'whois',
      version: ENV['APP_VERSION'] || '1.0'
    }
  end

  def service_info
    {
      name: 'whois',
      type: 'whois_server',
      env: ENV['WHOIS_ENV'] || 'development'
    }
  end

  def event_info(payload)
    {
      time: current_timestamp,
      status: payload[:status] || (payload[:record_found] ? 'success' : 'not_found')
    }
  end

  def source_info
    {
      host: Socket.gethostname,
      ip: Socket.ip_address_list.find { |addr| addr.ipv4? && !addr.ipv4_loopback? }&.ip_address
    }
  end

  def client_info(payload)
    {
      ip: payload[:ip],
      port: payload[:session_id]
    }
  end

  def current_user
    ENV['WHOIS_USER'] || `whoami`.strip
  end

  def data_info(payload)
    {
      query: payload[:domain],
      normalized_query: payload[:searched_by],
      record_found: payload[:record_found],
      record_id: payload[:record_id]
    }
  end

  def metadata_info
    {
      protocol: 'whois',
      version: '1.0'
    }
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
