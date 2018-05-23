require_relative '../test_helper'
require_relative '../../app/validators/unicode_validator'

class UnicodeValidatorTest < Minitest::Test
  def test_domain_name_in_utf8_is_valid
    value = 'äri.ee'.encode('utf-8')
    validator = UnicodeValidator.new(value)

    assert(validator.valid?)
  end

  def test_domain_name_not_in_utf8_is_not_valid
    value = 'äri.ee'.encode('iso-8859-1')
    validator = UnicodeValidator.new(value)

    refute(validator.valid?)
  end
end
