require 'test_helper'
require 'minitest/autorun'
require 'stringio'
require 'ostruct'
require_relative '../lib/logging'

class LoggingTest < Minitest::Test
  include Logging

  def setup
    @output = StringIO.new
    @logger = nil
  end

  def logger
    @logger ||= begin
      original_logger = super
      io_logger = Logger.new(@output, progname: 'whois')
      io_logger.formatter = proc do |severity, datetime, progname, msg|
        "[#{progname}] #{msg}\n"
      end
      @logger = io_logger
    end
  end

  def test_log_json
    payload = {
      ip: '127.0.0.1',
      session_id: '12345',
      domain: 'example.com',
      searched_by: 'example.com',
      record_found: true,
      record_id: 1,
      status: 'success',
      message: 'Test message'
    }

    log_json(payload)
    @output.rewind
    log_output = @output.read

    assert_includes log_output, '"ip":"127.0.0.1"'
    assert_includes log_output, '"query":"example.com"'
    assert_includes log_output, '"status":"success"'
    assert_includes log_output, '"error":"Test message"'
  end

  def test_log_invalid_encoding
    log_invalid_encoding(['12345', '127.0.0.1'], 'invalid_data')
    @output.rewind
    log_output = @output.read

    assert_includes log_output, '"status":"invalid_encoding"'
    assert_includes log_output, '"error":"Requested domain name is not in UTF-8"'
  end

  def test_log_policy_error
    log_policy_error(['12345', '127.0.0.1'], 'cleaned_data', 'name')
    @output.rewind
    log_output = @output.read

    assert_includes log_output, '"status":"policy_error"'
    assert_includes log_output, '"error":"Domain name format does not comply with policy"'
  end

  def test_log_record_found
    whois_record = OpenStruct.new(id: 1)
    log_record_found(['12345', '127.0.0.1'], 'cleaned_data', 'name', whois_record)
    @output.rewind
    log_output = @output.read

    assert_includes log_output, '"status":"success"'
    assert_includes log_output, '"record_found":true'
    assert_includes log_output, '"record_id":1'
  end

  def test_log_record_not_found
    log_record_not_found(['12345', '127.0.0.1'], 'cleaned_data', 'name')
    @output.rewind
    log_output = @output.read

    assert_includes log_output, '"status":"not_found"'
    assert_includes log_output, '"record_found":false'
  end  
end
