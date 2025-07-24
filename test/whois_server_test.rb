require 'minitest/autorun'
require_relative '../lib/whois_server_core'

class WhoisServerTest < Minitest::Test
  def test_allows_one_letter_domain
    assert_match WhoisServerCore::DOMAIN_NAME_REGEXP, 'a.ee'
    assert_match WhoisServerCore::DOMAIN_NAME_REGEXP, 'õ.ee'
    assert_match WhoisServerCore::DOMAIN_NAME_REGEXP, '1.ee'
    refute_match WhoisServerCore::DOMAIN_NAME_REGEXP, 'a..ee'
    assert_match WhoisServerCore::DOMAIN_NAME_REGEXP, 'ab.ee'
  end
end
