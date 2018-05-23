require 'erb'

class WhoisRecord < ActiveRecord::Base
  BLOCKED = 'Blocked'.freeze
  RESERVED = 'Reserved'.freeze
  DISCARDED = 'deleteCandidate'.freeze

  TEMPLATE_DIR = File.join(File.dirname(__FILE__), '../views/whois_record/').freeze
  DISCARDED_TEMPLATE = (TEMPLATE_DIR + "discarded.erb").freeze
  LEGAL_PERSON_TEMPLATE = (TEMPLATE_DIR + "legal_person.erb").freeze
  PRIVATE_PERSON_TEMPLATE = (TEMPLATE_DIR + "private_person.erb").freeze

  def unix_body
    file = File.new(template)
    ERB.new(file.read, nil, "-").result(binding)
  end

  def template
    if discarded_blocked_or_reserved?
      DISCARDED_TEMPLATE
    else
      private_or_legal_person_template
    end
  end

  private

  def private_person?
    json['registrant_kind'] != 'org'
  end

  def private_or_legal_person_template
    if private_person?
      PRIVATE_PERSON_TEMPLATE
    else
      LEGAL_PERSON_TEMPLATE
    end
  end

  def discarded_blocked_or_reserved?
    !(([BLOCKED, RESERVED, DISCARDED] & json['status']).empty?)
  end
end
