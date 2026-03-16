require 'test_helper'
require_relative '../../lib/whois_server'
require_relative '../../lib/whois_server_core'

class WhoisServerCoreTest < Minitest::Test
  include WhoisServer

  def test_allows_one_letter_domain
    assert_match WhoisServerCore::DOMAIN_NAME_REGEXP, 'a.ee'
    assert_match WhoisServerCore::DOMAIN_NAME_REGEXP, 'õ.ee'
    assert_match WhoisServerCore::DOMAIN_NAME_REGEXP, '1.ee'
    refute_match WhoisServerCore::DOMAIN_NAME_REGEXP, 'a..ee'
    assert_match WhoisServerCore::DOMAIN_NAME_REGEXP, 'ab.ee'
  end

  def test_domain_valid_format_valid_domains
    assert send(:domain_valid_format?, 'example.ee')
    assert send(:domain_valid_format?, 'test-domain.ee')
    assert send(:domain_valid_format?, 'õ.ee')
    assert send(:domain_valid_format?, 'example.ee'.downcase)
  end

  def test_domain_valid_format_invalid_domains
    refute send(:domain_valid_format?, 'invalid..ee')
    refute send(:domain_valid_format?, '')
    refute send(:domain_valid_format?, 'no-tld')
    refute send(:domain_valid_format?, '.ee')
    refute send(:domain_valid_format?, 'example.')
  end

  def test_domain_valid_format_with_whitespace
    assert send(:domain_valid_format?, '  example.ee  ')
    assert send(:domain_valid_format?, "\texample.ee\n")
  end

  def test_domain_valid_format_with_mixed_case
    assert send(:domain_valid_format?, 'EXAMPLE.EE')
    assert send(:domain_valid_format?, 'ExAmPlE.Ee')
  end
end
