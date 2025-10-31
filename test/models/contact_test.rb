require_relative '../test_helper'
require_relative '../../app/models/contact'

class ContactTest < Minitest::Test
  def test_attribute_disclosed
    contact = Contact.new(disclosed_attributes: %w[name])
    assert contact.attribute_disclosed?(:name)
  end

  def test_attribute_concealed
    contact = Contact.new(disclosed_attributes: %w[other])
    refute contact.attribute_disclosed?(:name)
  end

  def test_attribute_disclosed_with_string_attribute
    contact = Contact.new(disclosed_attributes: %w[name email])
    assert contact.attribute_disclosed?('name')
    assert contact.attribute_disclosed?(:email)
  end

  def test_attribute_disclosed_with_nil_disclosed_attributes
    contact = Contact.new(disclosed_attributes: nil)
    refute contact.attribute_disclosed?(:name)
  end

  def test_publishable_returns_true
    contact = Contact.new(registrant_publishable: true)
    assert contact.publishable?
  end

  def test_publishable_returns_false
    contact = Contact.new(registrant_publishable: false)
    refute contact.publishable?
  end

  def test_publishable_with_nil
    contact = Contact.new(registrant_publishable: nil)
    refute contact.publishable?
  end
end
