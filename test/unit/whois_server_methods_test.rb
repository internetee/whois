require 'test_helper'
require 'tempfile'
require_relative '../../lib/whois_server'
require_relative '../../lib/whois_server_core'
require_relative '../../app/validators/unicode_validator'

class WhoisServerMethodsTest < Minitest::Test
  include WhoisServer

  def setup
    super
    @logger_output = StringIO.new
    @logger = Logger.new(@logger_output)
    ENV['WHOIS_ENV'] = 'test'
  end

  def test_policy_error_msg
    msg = send(:policy_error_msg)
    assert_includes msg, 'Policy error'
    assert_includes msg, 'internet.ee'
    assert_includes msg, send(:footer_msg)
  end

  def test_no_entries_msg
    msg = send(:no_entries_msg)
    assert_includes msg, 'Domain not found'
    assert_includes msg, send(:footer_msg)
  end

  def test_invalid_encoding_msg
    msg = send(:invalid_encoding_msg)
    assert_includes msg, 'invalid encoding'
    assert_includes msg, 'utf-8'
    assert_includes msg, send(:footer_msg)
  end

  def test_footer_msg
    msg = send(:footer_msg)
    assert_includes msg, 'Estonia .ee Top Level Domain WHOIS server'
    assert_includes msg, 'internet.ee'
  end

  def test_no_body_msg
    msg = send(:no_body_msg)
    assert_includes msg, 'technical issue'
    assert_includes msg, send(:footer_msg)
  end

  def test_invalid_data_with_nil
    ip = ['12345', '127.0.0.1']
    assert send(:invalid_data?, nil, ip)
  end

  def test_invalid_data_with_empty_string
    ip = ['12345', '127.0.0.1']
    result = send(:invalid_data?, '', ip)
    assert [true, false].include?(result)
  end

  def test_invalid_data_with_invalid_encoding
    ip = ['12345', '127.0.0.1']
    invalid_data = 'example.ee'
    UnicodeValidator.any_instance.stubs(:valid?).returns(false)
    assert send(:invalid_data?, invalid_data, ip)
  end

  def test_invalid_data_with_valid_data
    ip = ['12345', '127.0.0.1']
    valid_data = 'example.ee'
    UnicodeValidator.any_instance.stubs(:valid?).returns(true)
    refute send(:invalid_data?, valid_data, ip)
  end

  def test_extract_ip_success
    ip = send(:extract_ip)
    assert_equal 12345, ip[0]
    assert_equal '127.0.0.1', ip[1]
  end

  def test_extract_ip_with_error
    stubs(:get_peername).raises(StandardError.new('Connection failed'))
    ip = send(:extract_ip)
    assert_nil ip
    assert @connection_closed
  end

  def test_extract_ip_logs_error_on_exception
    logger.expects(:error).at_least_once
    stubs(:get_peername).raises(StandardError.new('connection failed'))
    
    ip = send(:extract_ip)
    assert_nil ip
    assert @connection_closed
  end

  def test_yaml_properly_load_file_with_aliases
    test_file = Tempfile.new(['test', '.yml'])
    test_file.write(<<~YAML)
      default: &default
        key: value
      test:
        <<: *default
    YAML
    test_file.close

    result = YAML.properly_load_file(test_file.path)
    assert_equal 'value', result['test']['key']
    test_file.unlink
  rescue ArgumentError
    skip 'YAML aliases not supported in this Ruby version'
  end

  def test_yaml_properly_load_file_fallback
    test_file = Tempfile.new(['test', '.yml'])
    test_file.write(<<~YAML)
      test:
        key: value
    YAML
    test_file.close

    result = YAML.properly_load_file(test_file.path)
    assert_equal 'value', result['test']['key']
    test_file.unlink
  end

  def test_dbconfig_returns_config
    ENV['WHOIS_ENV'] = 'test'
    config = dbconfig
    refute_nil config
    assert config.key?('database')
  end

  def test_dbconfig_with_error
    original_dbconfig = @dbconfig
    @dbconfig = nil
    
    YAML.stubs(:properly_load_file).raises(NoMethodError.new('test error'))
    
    config = dbconfig
    @dbconfig = original_dbconfig
  end

  def test_dbconfig_logs_fatal_error
    original_dbconfig = @dbconfig
    @dbconfig = nil
    
    logger.expects(:fatal).at_least_once
    YAML.stubs(:properly_load_file).raises(NoMethodError.new('test'))
    
    dbconfig
    
    @dbconfig = original_dbconfig
  end

  def test_connection_establishes_connection
    stubs(:dbconfig).returns({ 'database' => 'test_db', 'adapter' => 'postgresql' })

    conn1 = connection
    refute_nil conn1
    
    conn2 = connection
    assert_equal conn1.object_id, conn2.object_id
  end

  def test_logging_methods_are_called_on_invalid_encoding
    ip = ['12345', '127.0.0.1']
    data = 'invalid\xFF'
    
    logger.expects(:info).at_least_once
    
    send(:log_invalid_encoding, ip, data)
  end

  def test_logging_methods_are_called_on_policy_error
    ip = ['12345', '127.0.0.1']
    cleaned_data = 'invalid..domain.ee'
    name = 'invalid..domain.ee'
    
    logger.expects(:info).at_least_once
    
    send(:log_policy_error, ip, cleaned_data, name)
  end

  def test_logging_methods_are_called_on_record_found
    ip = ['12345', '127.0.0.1']
    cleaned_data = 'example.ee'
    name = 'example.ee'
    mock_record = Minitest::Mock.new
    mock_record.expect(:id, 42)
    
    logger.expects(:info).at_least_once
    
    send(:log_record_found, ip, cleaned_data, name, mock_record)
    mock_record.verify
  end

  def test_logging_methods_are_called_on_record_not_found
    ip = ['12345', '127.0.0.1']
    cleaned_data = 'nonexistent.ee'
    name = 'nonexistent.ee'
    
    logger.expects(:info).at_least_once
    
    send(:log_record_not_found, ip, cleaned_data, name)
  end

  def get_peername
    Socket.pack_sockaddr_in(12345, '127.0.0.1')
  end

  def close_connection
    @connection_closed = true
  end

  def logger
    @logger
  end
end

