# lib/logging.rb
module Logging
  def logger
    @logger ||= Syslog::Logger.new 'whois'
  end

  def log_json(payload)
    logger.info(payload.to_json)
  end

  def log_invalid_data(ip, data)
    log_json(
      ip: ip[1],
      session_id: ip[0],
      domain: data.strip,
      status: 'invalid_encoding',
      message: 'Requested domain name is not in UTF-8'
    )
  end

  def log_record_found(ip, cleaned_data, name, whois_record)
    log_json(
      ip: ip[1],
      session_id: ip[0],
      domain: cleaned_data,
      searched_by: name,
      record_found: true,
      record_id: whois_record.id
    )
  end

  def log_record_not_found(ip, cleaned_data, name)
    log_json(
      ip: ip[1],
      session_id: ip[0],
      domain: cleaned_data,
      searched_by: name,
      record_found: false
    )
  end
end
