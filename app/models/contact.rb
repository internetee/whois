class Contact
  include ActiveModel::Model

  attr_accessor :name, :email, :phone, :disclosed_attributes, :registrant_publishable,
                :contact_publishable, :system_disclosed_attributes, :kind, :registrant

  def publishable?
    registrant_publishable
  end

  def attribute_disclosed?(attribute)
    # It is needed for compatibility with old records, which have no such key.
    # And even though `registry` app generates it for every record ([] for the ones having 0), it
    # may take some time until all WHOIS records are regenerated.
    return unless disclosed_attributes

    disclosed_attributes.include?(attribute.to_s)
  end

  # New disclosure policy gate (internetee/registry#2969): an attribute is
  # shown only when the owner explicitly marked the contact publishable AND
  # listed the attribute as disclosed. A phone present in
  # system_disclosed_attributes was matched against the business registry,
  # not volunteered by the owner.
  def volunteered?(attribute)
    return false unless publishable_for_disclosure? && attribute_disclosed?(attribute)
    return true if attribute.to_s != 'phone'

    # Old blobs predate registrant_system_disclosed_attributes and the
    # business-registry checker wrote 'phone' into disclosed_attributes too,
    # so consent cannot be proven when the key is absent. Only the registrant
    # carries the key, hence the flag.
    return false if registrant && system_disclosed_attributes.nil?

    !(system_disclosed_attributes || []).include?('phone')
  end

  def organization?
    kind == 'org'
  end

  private

  def publishable_for_disclosure?
    registrant_publishable == true || contact_publishable == true
  end
end
