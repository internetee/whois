require_relative '../test_helper'
require_relative '../../app/models/whois_record'

class WhoisRecordTest < Minitest::Test
  def test_deserializes_registrant
    whois_record = WhoisRecord.new(json: { registrant: 'John',
                                           registrant_disclosed_attributes: %w[one] })
    assert_equal 'John', whois_record.registrant.name
    assert_equal %w[one], whois_record.registrant.disclosed_attributes
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
end
