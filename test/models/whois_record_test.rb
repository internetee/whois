require_relative '../test_helper'
require_relative '../../app/models/whois_record'

class WhoisRecordTest < Minitest::Test
  def test_deserializes_registrant
    whois_record = WhoisRecord.new(json: { registrant: 'John',
                                           email: 'owner@privatedomain.test',
                                           phone: '+555.555',
                                           registrant_disclosed_attributes: %w[one],
                                           registrant_publishable: false })

    assert_equal 'John', whois_record.registrant.name
    assert_equal 'owner@privatedomain.test', whois_record.registrant.email
    assert_equal '+555.555', whois_record.registrant.phone
    assert_equal %w[one], whois_record.registrant.disclosed_attributes
    refute whois_record.registrant.registrant_publishable
  end

  def test_deserializes_admin_contacts
    whois_record = WhoisRecord.new(json: { admin_contacts: [{ name: 'Jack',
                                                              disclosed_attributes: %w[one] }] })

    contact = whois_record.admin_contacts.first
    assert_equal 'Jack', contact.name
    assert_equal %w[one], contact.disclosed_attributes
  end

  def test_deserializes_tech_contacts
    whois_record = WhoisRecord.new(json: { tech_contacts: [{ name: 'Jack',
                                                             disclosed_attributes: %w[one] }] })

    contact = whois_record.tech_contacts.first
    assert_equal 'Jack', contact.name
    assert_equal %w[one], contact.disclosed_attributes
  end

  def test_returns_inactive_record_unix_body_when_domain_is_at_auction
    @whois_record = WhoisRecord.new(name: 'shop.test', json: { name: 'shop.test',
                                                               status: [WhoisRecord::AT_AUCTION] })

    expected_output = begin
      "\n" \
      "Estonia .ee Top Level Domain WHOIS server\n" \
      "\n" \
      "Domain:\n" \
      "name:                  shop.test\n" \
      "status:                AtAuction\n" \
      "\n" \
      "\n" \
      "Estonia .ee Top Level Domain WHOIS server\n" \
      "More information at http://internet.ee\n" \
      ""
    end

    assert_equal expected_output, @whois_record.unix_body
  end

  def test_returns_inactive_record_unix_body_when_domain_is_pending_registration
    @whois_record = WhoisRecord.new(name: 'shop.test',
                                    json: { name: 'shop.test',
                                            status: [WhoisRecord::PENDING_REGISTRATION] })

    expected_output = begin
      "\n"\
      "Estonia .ee Top Level Domain WHOIS server\n" \
      "\n" \
      "Domain:\n" \
      "name:                  shop.test\n" \
      "status:                PendingRegistration\n" \
      "\n" \
      "\n" \
      "Estonia .ee Top Level Domain WHOIS server\n" \
      "More information at http://internet.ee\n" \
      ""
    end

    assert_equal expected_output, @whois_record.unix_body
  end

  def test_reserved_record_is_active_if_registered
    @whois_record = WhoisRecord.new(name: 'shop.test',
      json: { name: 'shop.test',
              registered: Time.now,
              status: [WhoisRecord::RESERVED] })
    assert @whois_record.active?
  end

  def test_reserved_record_is_inactive_if_unregistered
    @whois_record = WhoisRecord.new(name: 'shop.test',
      json: { name: 'shop.test',
              status: [WhoisRecord::RESERVED] })
    assert !@whois_record.active?
  end

  def test_disputed_record_is_active_if_registered
    @whois_record = WhoisRecord.new(name: 'shop.test',
      json: { name: 'shop.test',
              registered: Time.now,
              status: [WhoisRecord::DISPUTED] })
    assert @whois_record.active?
  end

  def test_disputed_record_is_inactive_if_unregistered
    @whois_record = WhoisRecord.new(name: 'shop.test',
      json: { name: 'shop.test',
              status: [WhoisRecord::DISPUTED] })
    assert !@whois_record.active?
  end

  def test_special_ee_second_level_domains
    special_domains = %w[pri.ee fie.ee med.ee com.ee]
    special_domains.each do |domain|
      @whois_record = WhoisRecord.new(name: domain, json: { name: domain, status: ['Blocked'] })

      output = @whois_record.unix_body

      assert_match(/Estonia .ee Top Level Domain WHOIS server/, output)
      assert_match(/Domain:/, output)
      assert_match(/name:\s+#{domain}/, output)
      assert_match(/status:\s+Blocked/, output)
      assert_match(/More information at http:\/\/internet\.ee/, output)
    end
  end

end
