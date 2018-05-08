require_relative '../test_helper'
require_relative '../../app/models/whois_record'

class DiscardedRecordTest < Minitest::Test
  def setup
    super

    create_discarded_record
  end

  def test_discarded_record_template
    text = begin
      "Estonia .ee Top Level Domain WHOIS server\n" \
      "\n" \
      "Domain:\n" \
      "name:       discarded-domain.test\n" \
      "status:     deleteCandidate\n" \
      "\n" \
      "Estonia .ee Top Level Domain WHOIS server\n" \
      "More information at http://internet.ee\n" \
      ""
    end

    assert_equal(text, @discarded_record.unix_body)
  end

  def create_discarded_record
    @discarded_record = WhoisRecord.new(
      name: 'discarded-domain.test',
      json: {
        name: 'discarded-domain.test',
        status: ['deleteCandidate']
      },
      created_at: Date.parse("2018-04-01 11:00 +0300"),
      updated_at: nil
    )
  end
end
