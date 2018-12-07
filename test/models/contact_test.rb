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
end
