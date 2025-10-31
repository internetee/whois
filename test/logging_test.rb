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

  def test_log_json_with_invalid_encoding
    payload = {
      domain: "test\xFF\xFE".force_encoding('BINARY'),
      ip: '127.0.0.1'
    }
    
    log_json(payload)
    @output.rewind
    log_output = @output.read
    
    assert log_output.length > 0
  end

  def test_log_json_with_json_generator_error
    payload = {
      domain: 'test'
    }
    
    logger.stubs(:info).raises(JSON::GeneratorError.new('test'))
    logger.expects(:error).at_least_once
    
    log_json(payload)
  end

  def test_sanitize_for_json_with_array
    array_with_invalid = ["test\xFF".force_encoding('BINARY'), 'valid']
    result = send(:sanitize_for_json, array_with_invalid)
    
    assert_equal Array, result.class
    assert_equal 2, result.length
  end

  def test_sanitize_for_json_with_hash
    hash_with_invalid = {
      key1: "test\xFF".force_encoding('BINARY'),
      key2: 'valid'
    }
    result = send(:sanitize_for_json, hash_with_invalid)
    
    assert_equal Hash, result.class
    assert_equal 2, result.length
  end

  def test_sanitize_for_json_with_other_types
    assert_equal 42, send(:sanitize_for_json, 42)
    assert_nil send(:sanitize_for_json, nil)
    assert_equal true, send(:sanitize_for_json, true)
    assert_equal false, send(:sanitize_for_json, false)
  end

  def test_build_base_log_includes_timestamp
    payload = { domain: 'test.ee', ip: '127.0.0.1' }
    result = send(:build_base_log, payload)
    
    assert result.key?(:timestamp)
    assert result[:timestamp].is_a?(String)
    assert_match /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/, result[:timestamp]
  end

  def test_build_base_log_includes_service_info
    payload = { domain: 'test.ee' }
    result = send(:build_base_log, payload)
    
    assert result.key?(:service)
    assert_equal 'whois', result[:service][:name]
    assert_equal 'whois_server', result[:service][:type]
  end

  def test_event_info_with_record_found
    payload = { record_found: true, status: 'custom_status' }
    result = send(:event_info, payload)
    
    assert_equal 'custom_status', result[:status]
  end

  def test_event_info_without_record_found
    payload = { record_found: false }
    result = send(:event_info, payload)
    
    assert_equal 'not_found', result[:status]
  end

  def test_event_info_defaults_to_not_found
    payload = {}
    result = send(:event_info, payload)
    
    assert_equal 'not_found', result[:status]
  end

  def test_source_info_returns_host_and_ip
    result = send(:source_info)
    
    assert result.key?(:host)
    assert result.key?(:ip)
    assert result[:host].is_a?(String)
    assert [NilClass, String].include?(result[:ip].class) if result[:ip]
  end

  def test_current_user_with_env
    ENV['WHOIS_USER'] = 'test_user'
    result = send(:current_user)
    
    assert_equal 'test_user', result
    ENV.delete('WHOIS_USER')
  end

  def test_current_user_without_env
    original_whois_user = ENV.delete('WHOIS_USER')
    
    result = send(:current_user)
    assert result.is_a?(String)
    assert result.length > 0
    
    ENV['WHOIS_USER'] = original_whois_user if original_whois_user
  end

  def test_logger_info_with_env_version
    ENV['APP_VERSION'] = '2.0.0'
    result = send(:logger_info)
    
    assert_equal 'whois', result[:name]
    assert_equal '2.0.0', result[:version]
    ENV.delete('APP_VERSION')
  end

  def test_logger_info_without_env_version
    original_version = ENV.delete('APP_VERSION')
    
    result = send(:logger_info)
    assert_equal 'whois', result[:name]
    assert_equal '1.0', result[:version]
    
    ENV['APP_VERSION'] = original_version if original_version
  end

  def test_client_info_extracts_ip_and_port
    payload = { ip: '192.168.1.1', session_id: '9999' }
    result = send(:client_info, payload)
    
    assert_equal '192.168.1.1', result[:ip]
    assert_equal '9999', result[:port]
  end

  def test_data_info_extracts_all_fields
    payload = {
      domain: 'test.ee',
      searched_by: 'test.ee',
      record_found: true,
      record_id: 42
    }
    result = send(:data_info, payload)
    
    assert_equal 'test.ee', result[:query]
    assert_equal 'test.ee', result[:normalized_query]
    assert_equal true, result[:record_found]
    assert_equal 42, result[:record_id]
  end

  def test_data_info_with_nil_values
    payload = {}
    result = send(:data_info, payload)
    
    assert_nil result[:query]
    assert_nil result[:normalized_query]
    assert_nil result[:record_found]
    assert_nil result[:record_id]
  end

  def test_metadata_info
    result = send(:metadata_info)
    
    assert_equal 'whois', result[:protocol]
    assert_equal '1.0', result[:version]
  end

  def test_build_base_log_with_compact_removes_nil_error
    payload = { domain: 'test.ee', ip: '127.0.0.1' }
    result = send(:build_base_log, payload)
      
    refute result.key?(:error) unless payload[:message]
  end

  def test_build_base_log_includes_all_sections
    payload = {
      domain: 'test.ee',
      ip: '127.0.0.1',
      session_id: '12345',
      message: 'test message'
    }
    result = send(:build_base_log, payload)
    
    assert result.key?(:timestamp)
    assert result.key?(:level)
    assert result.key?(:logger)
    assert result.key?(:service)
    assert result.key?(:event)
    assert result.key?(:source)
    assert result.key?(:client)
    assert result.key?(:user)
    assert result.key?(:data)
    assert result.key?(:metadata)
    assert_equal 'test message', result[:error]
  end

  def test_log_json_with_encoding_error
    payload = { domain: 'test' }
    
    stubs(:sanitize_for_json).raises(Encoding::UndefinedConversionError.new('test'))
    logger.expects(:error).at_least_once
    
    log_json(payload)
  end

  def test_service_info_with_env
    ENV['WHOIS_ENV'] = 'production'
    result = send(:service_info)
    
    assert_equal 'whois', result[:name]
    assert_equal 'whois_server', result[:type]
    assert_equal 'production', result[:env]
    ENV['WHOIS_ENV'] = 'test'
  end
end
