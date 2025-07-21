# frozen_string_literal: true
require 'test_helper'

module EventMachine
  def self.run; end
  def self.start_server(*args); end
  def self.set_effective_user(*args); end
end

require_relative '../lib/whois_server'

class WhoisServerTest < ActiveSupport::TestCase
  def test_allows_one_letter_domain
    assert_match WhoisServer::DOMAIN_NAME_REGEXP, 'a.ee'
    assert_match WhoisServer::DOMAIN_NAME_REGEXP, 'õ.ee'
    assert_match WhoisServer::DOMAIN_NAME_REGEXP, '1.ee'
    refute_match WhoisServer::DOMAIN_NAME_REGEXP, 'a..ee'
    assert_match WhoisServer::DOMAIN_NAME_REGEXP, 'ab.ee'
  end
end
