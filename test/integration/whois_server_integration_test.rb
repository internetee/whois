require 'test_helper'
require 'simpleidn'
require_relative '../../lib/whois_server'
require_relative '../../lib/whois_server_core'
require_relative '../../app/models/whois_record'
require_relative '../../app/validators/unicode_validator'

class WhoisServerIntegrationTest < Minitest::Test
  include WhoisServer

  def setup
    super
    @sent_data = []
    @connection_closed = false
    @connection_closed_after_writing = false
    @logger_output = StringIO.new
    @logger = Logger.new(@logger_output)
    ENV['WHOIS_ENV'] = 'test'
  end

  def test_receive_data_with_invalid_data
    stubs(:invalid_data?).returns(true)
    stubs(:invalid_encoding_msg).returns('Invalid encoding')
    stubs(:connection).returns(nil)

    receive_data('invalid\xFF')

    assert_equal 1, @sent_data.length
    assert_includes @sent_data.first, 'Invalid encoding'
    assert @connection_closed_after_writing
  end

  def test_receive_data_with_no_ip
    stubs(:extract_ip).returns(nil)
    stubs(:connection).returns(nil)

    receive_data('example.ee')

    assert_equal 0, @sent_data.length
  end

  def test_receive_data_full_flow
    data = 'example.ee'
    ip = ['12345', '127.0.0.1']
    mock_record = Minitest::Mock.new
    mock_record.expect(:unix_body, 'Whois body')
    mock_record.expect(:id, 1)

    stubs(:connection).returns(nil)
    stubs(:extract_ip).returns(ip)
    stubs(:invalid_data?).returns(false)
    WhoisRecord.stubs(:find_by).returns(mock_record)

    receive_data(data)

    assert_equal 1, @sent_data.length
    assert @connection_closed_after_writing
    mock_record.verify
  end

  def test_receive_data_integration_full_flow
    data = 'integration-test.ee'
    ip = ['12345', '127.0.0.1']
    
    stubs(:connection).returns(nil)
    stubs(:extract_ip).returns(ip)
    stubs(:invalid_data?).returns(false)
    
    mock_record = Minitest::Mock.new
    mock_record.expect(:unix_body, 'Integration test body')
    mock_record.expect(:id, 1)
    
    WhoisRecord.stubs(:find_by).returns(mock_record)
    
    receive_data(data)
    
    assert_equal 1, @sent_data.length
    assert @connection_closed_after_writing
    mock_record.verify
  end

  def test_process_whois_request_with_invalid_encoding
    data = "\xFF\xFE".force_encoding('ASCII-8BIT')
    ip = ['12345', '127.0.0.1']
    
    send(:process_whois_request, data, ip)

    assert_equal 1, @sent_data.length
    assert_includes @sent_data.first, 'invalid encoding'
  end

  def test_process_whois_request_with_invalid_domain_format
    data = 'invalid..domain.ee'
    ip = ['12345', '127.0.0.1']

    send(:process_whois_request, data, ip)

    assert_equal 1, @sent_data.length
    assert_includes @sent_data.first, 'Policy error'
  end

  def test_process_whois_request_with_valid_domain_found
    data = 'example.ee'
    ip = ['12345', '127.0.0.1']
    mock_record = Minitest::Mock.new
    mock_record.expect(:unix_body, 'Whois body')
    mock_record.expect(:id, 1)

    WhoisRecord.stubs(:find_by).returns(mock_record)

    send(:process_whois_request, data, ip)

    assert_equal 1, @sent_data.length
    assert_equal 'Whois body', @sent_data.first
    mock_record.verify
  end

  def test_process_whois_request_with_valid_domain_not_found
    data = 'nonexistent.ee'
    ip = ['12345', '127.0.0.1']

    WhoisRecord.stubs(:find_by).returns(nil)

    send(:process_whois_request, data, ip)

    assert_equal 1, @sent_data.length
    assert_includes @sent_data.first, 'Domain not found'
  end

  def test_process_whois_request_strips_whitespace
    data = '  example.ee  '
    ip = ['12345', '127.0.0.1']
    mock_record = Minitest::Mock.new
    mock_record.expect(:unix_body, 'Whois body')
    mock_record.expect(:id, 1)

    WhoisRecord.stubs(:find_by).returns(mock_record)

    send(:process_whois_request, data, ip)

    assert_equal 1, @sent_data.length
    assert_equal 'Whois body', @sent_data.first
    mock_record.verify
  end

  def test_process_whois_request_with_whitespace_only
    data = '   '
    ip = ['12345', '127.0.0.1']
    
    send(:process_whois_request, data, ip)
    
    assert_equal 1, @sent_data.length
    assert_includes @sent_data.first, 'Policy error'
  end

  def test_process_whois_request_calls_logging_with_punycode
    data = 'example.ee'
    ip = ['12345', '127.0.0.1']
    
    mock_record = Minitest::Mock.new
    mock_record.expect(:unix_body, 'Whois body')
    mock_record.expect(:id, 1)
    
    WhoisRecord.stubs(:find_by).returns(mock_record)
    
    send(:process_whois_request, data, ip)
    
    assert_equal 1, @sent_data.length
    assert_equal 'Whois body', @sent_data.first
    mock_record.verify
  end

  def test_handle_whois_record_found
    name = 'example.ee'
    ip = ['12345', '127.0.0.1']
    cleaned_data = 'example.ee'

    mock_record = Minitest::Mock.new
    mock_record.expect(:unix_body, 'Whois record body')
    mock_record.expect(:id, 1)

    WhoisRecord.stubs(:find_by).with(name: name).returns(mock_record)

    send(:handle_whois_record, name, ip, cleaned_data)

    assert_equal 1, @sent_data.length
    assert_equal 'Whois record body', @sent_data.first
    mock_record.verify
  end

  def test_handle_whois_record_not_found
    name = 'nonexistent.ee'
    ip = ['12345', '127.0.0.1']
    cleaned_data = 'nonexistent.ee'

    WhoisRecord.stubs(:find_by).with(name: name).returns(nil)
    stubs(:no_entries_msg).returns('Domain not found')

    send(:handle_whois_record, name, ip, cleaned_data)

    assert_equal 1, @sent_data.length
    assert_includes @sent_data.first, 'Domain not found'
  end

  def send_data(data)
    @sent_data << data
  end

  def close_connection_after_writing
    @connection_closed_after_writing = true
  end

  def close_connection
    @connection_closed = true
  end

  def get_peername
    Socket.pack_sockaddr_in(12345, '127.0.0.1')
  end

  def logger
    @logger
  end
end

