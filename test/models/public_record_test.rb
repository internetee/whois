require_relative '../test_helper'
require_relative '../../app/models/whois_record'

# New disclosure policy (internetee/registry#2969): the public whois level
# rendered through app/views/whois_record/public.erb once
# DISCLOSURE_POLICY_ACTIVE_FROM is reached.
class PublicRecordTest < Minitest::Test
  DISCLAIMER = 'The information obtained through .ee WHOIS is subject to database protection ' \
               'according to the Estonian Copyright Act and international conventions. All ' \
               'rights are reserved to Estonian Internet Foundation. Search results may not be ' \
               'used for commercial,advertising, recompilation, repackaging, redistribution, ' \
               'reuse, obscuring or other similar activities. Downloading of information about ' \
               'domain names for the creation of your own database is not permitted. If any of ' \
               'the information from .ee WHOIS is transferred to a third party, it must be done ' \
               'in its entirety. This server must not be used as a backend for a search engine.'.freeze

  WEBBASED_MASK = 'Not Disclosed - Visit www.internet.ee for webbased WHOIS'.freeze

  def setup
    super
    DisclosurePolicy.active_from = Time.now - 3600
  end

  def teardown
    DisclosurePolicy.reset!
    super
  end

  def test_org_registrant_full_body_when_nothing_volunteered
    text = begin
      "The information obtained through .ee WHOIS is subject to database\n" \
      "protection according to the Estonian Copyright Act and international\n" \
      "conventions. All rights are reserved to Estonian Internet Foundation.\n" \
      "Search results may not be used for commercial,advertising, recompilation,\n" \
      "repackaging, redistribution, reuse, obscuring or other similar activities.\n" \
      "Downloading of information about domain names for the creation of your own\n" \
      "database is not permitted. If any of the information from .ee WHOIS is\n" \
      "transferred to a third party, it must be done in its entirety. This server\n" \
      "must not be used as a backend for a search engine.\n" \
      "\n" \
      "Estonia .ee Top Level Domain WHOIS server\n" \
      "\n" \
      "Domain:\n" \
      "name:       companydomain.test\n" \
      "status:     inactive\n" \
      "registered: 2018-04-25 14:10:41 +03:00\n" \
      "expire:     2018-07-25\n" \
      "\n" \
      "Registrant:\n" \
      "name:       Not Disclosed - Visit www.internet.ee for webbased WHOIS\n" \
      "type:       org\n" \
      "email:      Not Disclosed - Visit www.internet.ee for webbased WHOIS\n" \
      "phone:      Not Disclosed - Visit www.internet.ee for webbased WHOIS\n" \
      "\n" \
      "Administrative contact:\n" \
      "name:       Not Disclosed\n" \
      "email:      Not Disclosed\n" \
      "phone:      Not Disclosed\n" \
      "\n" \
      "Technical contact:\n" \
      "name:       Not Disclosed - Visit www.internet.ee for webbased WHOIS\n" \
      "email:      Not Disclosed - Visit www.internet.ee for webbased WHOIS\n" \
      "phone:      Not Disclosed - Visit www.internet.ee for webbased WHOIS\n" \
      "\n" \
      "Registrar:\n" \
      "name:       test\n" \
      "url:        https://registrar.test\n" \
      "phone:      +372.6000000\n" \
      "email:      info@registrar.test\n" \
      "address:    Street 1, Tallinn\n" \
      "\n" \
      "Name servers:\n" \
      "nserver:   ns1.test.ee 192.0.2.1 2001:db8::1\n" \
      "nserver:   ns2.test.ee\n" \
      "\n" \
      "DNSSEC:\n" \
      "dnskey:   257 3 8 AwEAAatest\n" \
      "\n" \
      "Estonia .ee Top Level Domain WHOIS server\n" \
      "More information at http://internet.ee\n" \
      ""
    end

    assert_equal text, org_record.unix_body
  end

  def test_priv_registrant_full_body_for_old_blob_without_new_keys
    text = begin
      "The information obtained through .ee WHOIS is subject to database\n" \
      "protection according to the Estonian Copyright Act and international\n" \
      "conventions. All rights are reserved to Estonian Internet Foundation.\n" \
      "Search results may not be used for commercial,advertising, recompilation,\n" \
      "repackaging, redistribution, reuse, obscuring or other similar activities.\n" \
      "Downloading of information about domain names for the creation of your own\n" \
      "database is not permitted. If any of the information from .ee WHOIS is\n" \
      "transferred to a third party, it must be done in its entirety. This server\n" \
      "must not be used as a backend for a search engine.\n" \
      "\n" \
      "Estonia .ee Top Level Domain WHOIS server\n" \
      "\n" \
      "Domain:\n" \
      "name:       privatedomain.test\n" \
      "status:     inactive\n" \
      "registered: 2018-04-25 14:10:41 +03:00\n" \
      "expire:     2018-07-25\n" \
      "\n" \
      "Registrant:\n" \
      "name:       Private Person\n" \
      "type:       priv\n" \
      "email:      Not Disclosed\n" \
      "phone:      Not Disclosed\n" \
      "\n" \
      "Administrative contact:\n" \
      "name:       Not Disclosed\n" \
      "email:      Not Disclosed\n" \
      "phone:      Not Disclosed\n" \
      "\n" \
      "Technical contact:\n" \
      "name:       Not Disclosed\n" \
      "email:      Not Disclosed\n" \
      "phone:      Not Disclosed\n" \
      "\n" \
      "Registrar:\n" \
      "name:       test\n" \
      "url:        \n" \
      "phone:      \n" \
      "\n" \
      "Name servers:\n" \
      "nserver:   ns1.test.ee\n" \
      "nserver:   ns2.test.ee\n" \
      "\n" \
      "\n" \
      "Estonia .ee Top Level Domain WHOIS server\n" \
      "More information at http://internet.ee\n" \
      ""
    end

    assert_equal text, priv_record.unix_body
  end

  def test_volunteered_registrant_attributes_are_shown
    record = org_record(registrant_publishable: true,
                        registrant_disclosed_attributes: %w[name email phone])
    body = record.unix_body

    assert_includes body, "Registrant:\nname:       Mega Corp"
    assert_includes body, "email:      owner@companydomain.test"
    assert_includes body, "phone:      +555.555"
  end

  def test_publishable_registrant_hides_attributes_not_in_disclosed_list
    record = org_record(registrant_publishable: true,
                        registrant_disclosed_attributes: %w[name])
    body = record.unix_body

    assert_includes body, "Registrant:\nname:       Mega Corp"
    assert_includes body, "email:      #{WEBBASED_MASK}"
    assert_includes body, "phone:      #{WEBBASED_MASK}"
  end

  def test_disclosed_registrant_attributes_hidden_when_not_publishable
    record = org_record(registrant_publishable: false,
                        registrant_disclosed_attributes: %w[name email phone])
    body = record.unix_body

    assert_includes body, "name:       #{WEBBASED_MASK}"
    refute_includes body, 'Mega Corp'
    refute_includes body, 'owner@companydomain.test'
    refute_includes body, '+555.555'
  end

  def test_system_disclosed_registrant_phone_stays_hidden
    record = org_record(registrant_publishable: true,
                        registrant_disclosed_attributes: %w[name email phone],
                        registrant_system_disclosed_attributes: %w[phone])
    body = record.unix_body

    assert_includes body, "Registrant:\nname:       Mega Corp"
    assert_includes body, "email:      owner@companydomain.test"
    assert_includes body, "phone:      #{WEBBASED_MASK}"
    refute_includes body, '+555.555'
  end

  # Old blobs lack registrant_system_disclosed_attributes and the
  # business-registry checker wrote 'phone' into disclosed_attributes too,
  # so consent cannot be proven: the phone stays hidden.
  def test_old_blob_registrant_phone_stays_hidden
    json = org_json.merge(registrant_publishable: true,
                          registrant_disclosed_attributes: %w[name email phone])
    json.delete(:registrant_system_disclosed_attributes)
    body = WhoisRecord.new(name: 'companydomain.test', json: json).unix_body

    assert_includes body, "Registrant:\nname:       Mega Corp"
    assert_includes body, "email:      owner@companydomain.test"
    assert_includes body, "phone:      #{WEBBASED_MASK}"
    refute_includes body, '+555.555'
  end

  def test_registrant_phone_shown_when_system_disclosed_key_present_and_empty
    record = org_record(registrant_publishable: true,
                        registrant_disclosed_attributes: %w[phone],
                        registrant_system_disclosed_attributes: [])

    assert_includes record.unix_body, "phone:      +555.555"
  end

  def test_volunteered_contact_attributes_and_mixed_contacts
    record = org_record(
      admin_contacts: [
        { name: 'Admin One', email: 'one@admin.test', phone: '+111',
          disclosed_attributes: %w[name email], contact_publishable: true, kind: 'priv' },
        { name: 'Admin Two', email: 'two@admin.test', phone: '+222',
          disclosed_attributes: %w[name], contact_publishable: false, kind: 'priv' },
      ],
      tech_contacts: [
        { name: 'Tech Org', email: 'tech@org.test', phone: '+333',
          disclosed_attributes: %w[phone], contact_publishable: true, kind: 'org' },
      ]
    )
    body = record.unix_body

    assert_includes body, "Administrative contact:\nname:       Admin One\n" \
                          "email:      one@admin.test\nphone:      Not Disclosed\n" \
                          "name:       Not Disclosed\nemail:      Not Disclosed\n" \
                          "phone:      Not Disclosed\n"
    refute_includes body, 'Admin Two'
    refute_includes body, 'two@admin.test'
    assert_includes body, "Technical contact:\nname:       #{WEBBASED_MASK}\n" \
                          "email:      #{WEBBASED_MASK}\nphone:      +333\n"
    refute_includes body, 'Tech Org'
    refute_includes body, 'tech@org.test'
  end

  def test_priv_tech_contact_uses_plain_not_disclosed_mask
    record = org_record(
      admin_contacts: [],
      tech_contacts: [
        { name: 'Tech Priv', email: 'tech@priv.test', phone: '+333',
          disclosed_attributes: %w[email], contact_publishable: true, kind: 'priv' },
      ]
    )
    body = record.unix_body

    assert_includes body, "Technical contact:\nname:       Not Disclosed\n" \
                          "email:      tech@priv.test\nphone:      Not Disclosed\n"
  end

  def test_nameserver_records_take_precedence_over_nameserver_hostnames
    record = org_record(nameserver_records: [{ hostname: 'ns1.test.ee', ipv4: %w[192.0.2.1],
                                               ipv6: %w[2001:db8::1] }],
                        nameservers: %w[ignored.test.ee])
    body = record.unix_body

    assert_includes body, "nserver:   ns1.test.ee 192.0.2.1 2001:db8::1\n"
    refute_includes body, 'ignored.test.ee'
  end

  def test_empty_nameserver_records_does_not_fall_back
    record = org_record(nameserver_records: [], nameservers: %w[ns1.test.ee])
    refute_includes record.unix_body, 'nserver:'
  end

  def test_inactive_domain_renders_inactive_template_under_active_policy
    record = WhoisRecord.new(name: 'shop.test', json: { name: 'shop.test',
                                                        status: [WhoisRecord::AT_AUCTION] })

    expected = begin
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

    assert_equal expected, record.unix_body
  end

  def test_legacy_template_used_when_policy_inactive
    DisclosurePolicy.active_from = Time.now + 3600
    body = org_record.unix_body

    assert_includes body, 'org id:'
    assert_includes body, 'changed:'
    refute_includes body, 'type:'

    DisclosurePolicy.active_from = Time.now - 3600
    body = org_record.unix_body

    refute_includes body, 'org id:'
    refute_includes body, 'changed:'
    assert_includes body, "type:       org"
  end

  private

  def org_record(overrides = {})
    WhoisRecord.new(name: 'companydomain.test', json: org_json.merge(overrides))
  end

  def priv_record
    WhoisRecord.new(name: 'privatedomain.test', json: priv_json)
  end

  def org_json
    {
      disclaimer: DISCLAIMER,
      name: 'companydomain.test',
      status: ['inactive'],
      registered: '2018-04-25T14:10:41+03:00',
      changed: '2018-04-25T14:10:41+03:00',
      expire: '2018-07-25',
      outzone: nil,
      delete: nil,
      registrant: 'Mega Corp',
      registrant_kind: 'org',
      registrant_reg_no: 123,
      registrant_ident_country_code: 'EE',
      registrant_publishable: false,
      registrant_disclosed_attributes: [],
      registrant_system_disclosed_attributes: [],
      email: 'owner@companydomain.test',
      phone: '+555.555',
      admin_contacts: [
        { name: 'Admin Contact', email: 'admin@companydomain.test', phone: '+111',
          disclosed_attributes: [], contact_publishable: false, kind: 'org' }
      ],
      tech_contacts: [
        { name: 'Tech Contact', email: 'tech@companydomain.test', phone: '+222',
          disclosed_attributes: [], contact_publishable: false, kind: 'org' }
      ],
      registrar: 'test',
      registrar_website: 'https://registrar.test',
      registrar_phone: '+372.6000000',
      registrar_email: 'info@registrar.test',
      registrar_address: 'Street 1, Tallinn',
      registrar_changed: '2018-04-25T14:10:39+03:00',
      nameserver_records: [
        { hostname: 'ns1.test.ee', ipv4: ['192.0.2.1'], ipv6: ['2001:db8::1'] },
        { hostname: 'ns2.test.ee', ipv4: [], ipv6: [] }
      ],
      nameservers: %w[ns1.test.ee ns2.test.ee],
      nameservers_changed: '2018-04-25T14:10:39+03:00',
      dnssec_keys: ['257 3 8 AwEAAatest'],
      dnssec_changed: '2018-04-25T14:10:39+03:00',
      registrant_changed: '2018-04-25T14:10:39+03:00'
    }
  end

  # Pre-regeneration blob: no nameserver_records, registrar_email,
  # registrar_address, registrant_system_disclosed_attributes and no
  # contact_publishable/kind on contacts.
  def priv_json
    {
      disclaimer: DISCLAIMER,
      name: 'privatedomain.test',
      status: ['inactive'],
      registered: '2018-04-25T14:10:41+03:00',
      changed: '2018-04-25T14:10:41+03:00',
      expire: '2018-07-25',
      registrant: 'John Smith',
      registrant_kind: 'priv',
      registrant_publishable: false,
      registrant_disclosed_attributes: [],
      email: 'owner@privatedomain.test',
      phone: '+555.555',
      admin_contacts: [
        { name: 'Admin Contact', email: 'admin@privatedomain.test',
          disclosed_attributes: [] }
      ],
      tech_contacts: [
        { name: 'Tech Contact', email: 'tech@privatedomain.test',
          disclosed_attributes: %w[name] }
      ],
      registrar: 'test',
      registrar_website: nil,
      registrar_phone: nil,
      nameservers: %w[ns1.test.ee ns2.test.ee],
      dnssec_keys: []
    }
  end
end
