require 'test_helper'
require 'simpleidn'
require_relative '../../lib/whois_server'
require_relative '../../lib/whois_server_core'
require_relative '../../app/models/whois_record'
require_relative '../../app/validators/unicode_validator'

TEST_DOMAIN = 'test-domain.ee'
INTEGRATION_TEST_DOMAIN = 'integration-test.ee'

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

  def stub_connection_and_ip(ip = ['12345', '127.0.0.1'])
    stubs(:connection).returns(nil)
    stubs(:extract_ip).returns(ip)
  end

  def mock_whois_record(body: 'Whois body', id: 1)
    mock_record = Minitest::Mock.new
    mock_record.expect(:unix_body, body)
    mock_record.expect(:id, id)
    WhoisRecord.stubs(:find_by).returns(mock_record)
    mock_record
  end

  def test_receive_data_rejects_invalid_encoding
    invalid_payload = "\xFF\xFE".dup.force_encoding('ASCII-8BIT')
    receive_data(invalid_payload)

    assert_equal 1, @sent_data.length
    assert_includes @sent_data.first.downcase, 'invalid encoding'
    assert @connection_closed_after_writing
  end

  def test_receive_data_returns_valid_whois_body
    stub_connection_and_ip
    mock_record = mock_whois_record(body: 'This is a valid WHOIS record')
  
    receive_data(TEST_DOMAIN)
  
    assert_equal 1, @sent_data.length
    assert_includes @sent_data.first, 'This is a valid WHOIS record'
    assert @connection_closed_after_writing
  
    mock_record.verify
  end

  def test_receive_data_domain_not_found
    stub_connection_and_ip
    WhoisRecord.stubs(:find_by).returns(nil)

    receive_data(TEST_DOMAIN)

    assert_equal 1, @sent_data.length
    assert_includes @sent_data.first.downcase, 'domain not found'
    assert @connection_closed_after_writing
  end

  def test_receive_data_with_no_ip
    stubs(:extract_ip).returns(nil)
    stubs(:connection).returns(nil)

    receive_data(TEST_DOMAIN)

    assert_equal 0, @sent_data.length
  end

  def test_receive_data_full_flow
    scenarios = [
      {domain: TEST_DOMAIN, body: 'Whois body'},
      {domain: 'integration-test.ee', body: 'Integration test'}
    ]

    scenarios.each do |scenario|
      mock_record = mock_whois_record(body: scenario[:body])
      stub_connection_and_ip

      receive_data(scenario[:domain])

      assert_equal 1, @sent_data.length
      assert @connection_closed_after_writing
      mock_record.verify

      @sent_data.clear
      @connection_closed_after_writing = false
    end
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
