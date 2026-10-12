require 'erb'
require_relative 'contact'
require_relative 'disclosure_policy'

class WhoisRecord < ActiveRecord::Base
  BLOCKED = 'Blocked'.freeze
  RESERVED = 'Reserved'.freeze
  DISCARDED = 'deleteCandidate'.freeze
  AT_AUCTION = 'AtAuction'.freeze
  PENDING_REGISTRATION = 'PendingRegistration'.freeze
  DISPUTED = 'Disputed'.freeze

  WEBBASED_WHOIS_MASK = 'Not Disclosed - Visit www.internet.ee for webbased WHOIS'.freeze

  TEMPLATE_DIR = File.join(File.dirname(__FILE__), '../views/whois_record/').freeze
  TEMPLATE_INACTIVE = "#{TEMPLATE_DIR}inactive.erb".freeze
  LEGAL_PERSON_TEMPLATE = "#{TEMPLATE_DIR}legal_person.erb".freeze
  PRIVATE_PERSON_TEMPLATE = "#{TEMPLATE_DIR}private_person.erb".freeze
  PUBLIC_TEMPLATE = "#{TEMPLATE_DIR}public.erb".freeze

  INACTIVE_STATUSES = [BLOCKED, DISCARDED, AT_AUCTION, PENDING_REGISTRATION].freeze

  def unix_body
    file = File.new(template)
    ERB.new(file.read, trim_mode: '-').result(binding)
  end

  def template
    if active?
      DisclosurePolicy.active? ? PUBLIC_TEMPLATE : private_or_legal_person_template
    else
      TEMPLATE_INACTIVE
    end
  end

  def registrant
    deserialize_registrant
  end

  def admin_contacts
    json['admin_contacts'].map { |serialized_contact| deserialize_contact(serialized_contact) }
  end

  def tech_contacts
    json['tech_contacts'].map { |serialized_contact| deserialize_contact(serialized_contact) }
  end

  def active?
    return false if json['registered'].nil?

    (json['status'] & INACTIVE_STATUSES).empty?
  end

  # New disclosure policy (internetee/registry#2969), public.erb helpers.

  def registrant_type
    private_person? ? 'priv' : 'org'
  end

  def registrant_name_mask
    private_person? ? 'Private Person' : WEBBASED_WHOIS_MASK
  end

  def registrant_field_mask
    private_person? ? 'Not Disclosed' : WEBBASED_WHOIS_MASK
  end

  # Org tech contacts are shown at the detailed (webbased) level, so hidden
  # fields point there; other contacts are never revealed there.
  def tech_contact_mask(contact)
    contact.organization? ? WEBBASED_WHOIS_MASK : 'Not Disclosed'
  end

  private

  def deserialize_registrant
    Contact.new(name: json['registrant'],
                email: json['email'],
                phone: json['phone'],
                disclosed_attributes: json['registrant_disclosed_attributes'],
                registrant_publishable: json['registrant_publishable'],
                system_disclosed_attributes: json['registrant_system_disclosed_attributes'])
  end

  def deserialize_contact(serialized_contact)
    Contact.new(name: serialized_contact['name'],
                email: serialized_contact['email'],
                phone: serialized_contact['phone'],
                disclosed_attributes: serialized_contact['disclosed_attributes'],
                contact_publishable: serialized_contact['contact_publishable'],
                kind: serialized_contact['kind'])
  end

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
end
