require_relative '../test_helper'
require_relative '../../app/models/whois_record'

class PrivatePersonRecordTest < Minitest::Test
  def setup
    super

    create_private_person_record
  end

  def test_private_person_record_template
    @private_person_record.update!(json: @private_person_record.json.merge({ registrant_publishable: false }))

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
      "changed:    2018-04-25 14:10:41 +03:00\n" \
      "expire:     2018-07-25\n" \
      "outzone:    \n" \
      "delete:     \n" \
      "\n" \
      "Registrant:\n" \
      "name:       Private Person\n" \
      "email:      Not Disclosed - Visit www.internet.ee for webbased WHOIS\n" \
      "phone:      Not Disclosed - Visit www.internet.ee for webbased WHOIS\n" \
      "changed:    Not Disclosed\n" \
      "\n" \
      "Administrative contact:\n" \
      "name:       Not Disclosed\n" \
      "email:      Not Disclosed - Visit www.internet.ee for webbased WHOIS\n" \
      "changed:    Not Disclosed\n" \
      "\n" \
      "Technical contact:\n" \
      "name:       Not Disclosed\n" \
      "email:      Not Disclosed - Visit www.internet.ee for webbased WHOIS\n" \
      "changed:    Not Disclosed\n" \
      "\n" \
      "Registrar:\n" \
      "name:       test\n" \
      "url:        \n" \
      "phone:      \n" \
      "changed:    2018-04-25 14:10:39 +03:00\n" \
      "\n" \
      "\n" \
      "Estonia .ee Top Level Domain WHOIS server\n" \
      "More information at http://internet.ee\n" \
      ""
    end

    assert_equal(text, @private_person_record.unix_body)
  end

  def test_private_person_sensitive_data_when_registrant_is_publishable
    @private_person_record.update!(json: @private_person_record.json.merge({ registrant_publishable: true,
                                                                             registrant_disclosed_attributes: %w[name email phone] }))
    whois_output = @private_person_record.unix_body

    assert_includes whois_output, "Registrant:\nname:       test"
    assert_includes whois_output, "email:      owner@privatedomain.test"
    assert_includes whois_output, "phone:      +555.555"
  end

  def test_contact_names_are_visible_when_disclosed_by_owner
    @private_person_record.update!(json: @private_person_record.json
                                           .merge({ registrant: 'John',
                                                    registrant_disclosed_attributes: %w[name],
                                                    admin_contacts: [{ name: 'Jack',
                                                                       disclosed_attributes: %w[name] }],
                                                    tech_contacts: [{ name: 'William',
                                                                      disclosed_attributes: %w[name] }] }))

    whois_output = @private_person_record.unix_body
    assert_includes whois_output, "Registrant:\nname:       John"
    assert_includes whois_output, "Administrative contact:\nname:       Jack"
    assert_includes whois_output, "Technical contact:\nname:       William"
  end

  def test_contact_names_are_hidden_when_concealed_by_owner
    @private_person_record.update!(json: @private_person_record.json
                                           .merge({ registrant: 'any',
                                                    registrant_disclosed_attributes: [],
                                                    admin_contacts: [{ name: 'any',
                                                                       disclosed_attributes: [] }],
                                                    tech_contacts: [{ name: 'any',
                                                                      disclosed_attributes: [] }] }))

    whois_output = @private_person_record.unix_body
    assert_includes whois_output, "Registrant:\nname:       Private Person"
    assert_includes whois_output, "Administrative contact:\nname:       Not Disclosed"
    assert_includes whois_output, "Technical contact:\nname:       Not Disclosed"
  end

  def create_private_person_record
    @private_person_record = WhoisRecord.new(
      name: 'private-domain.test',
      json: {
        admin_contacts: [
          {
            changed: "2018-04-25T14:10:41+03:00",
            email: "admin-contact@privatedomain.test",
            name: "Admin Contact",
            disclosed_attributes: [],
          }
        ],
        changed: "2018-04-25T14:10:41+03:00",
        delete: nil,
        disclaimer: { en: "The information obtained through .ee WHOIS is subject to database protection according to the Estonian Copyright Act and international conventions. All rights are reserved to Estonian Internet Foundation. Search results may not be used for commercial,advertising, recompilation, repackaging, redistribution, reuse, obscuring or other similar activities. Downloading of information about domain names for the creation of your own database is not permitted. If any of the information from .ee WHOIS is transferred to a third party, it must be done in its entirety. This server must not be used as a backend for a search engine." },
        dnssec_changed: nil,
        dnssec_keys: [

        ],
        email: "owner@privatedomain.test",
        phone: "+555.555",
        expire: "2018-07-25",
        name: "privatedomain.test",
        nameservers: [

        ],
        nameservers_changed: nil,
        outzone: nil,
        registered: "2018-04-25T14:10:41+03:00",
        registrant: "test",
        registrant_changed: "2018-04-25T14:10:39+03:00",
        registrant_kind: "priv",
        registrar: "test",
        registrar_changed: "2018-04-25T14:10:39+03:00",
        registrar_phone: nil,
        registrar_website: nil,
        status: [
          "inactive"
        ],
        tech_contacts: [
          {
            changed: "2018-04-25T14:10:41+03:00",
            email: "tech-contact@privatedomain.test",
            name: "Tech Contact"
          }
        ]
      },
      created_at: Date.parse("2018-04-01 11:00 +0300"),
      updated_at: nil
    )
  end
end
