require 'test_helper'
require_relative '../../app/validators/unicode_validator'

class UnicodeValidatorTest < Minitest::Test
  def setup
    @validator = UnicodeValidator
  end

  def test_valid_ascii
    assert @validator.new('example.ee').valid?
    assert @validator.new('test123.ee').valid?
    assert @validator.new('äri.ee').valid?
  end

  def test_domain_name_in_utf8_is_valid
    value = 'äri.ee'.encode('utf-8')
    assert @validator.new(value).valid?
  end

  def test_domain_name_not_in_utf8_is_not_valid
    value = 'äri.ee'.encode('iso-8859-1')
    refute @validator.new(value).valid?
  end

  def test_invalid_utf8_sequences
    # Test with escaped backslash as received from whois command
    refute @validator.new("\\xFF.ee\r\n").valid?
    refute @validator.new("\\xFF\\xFE\\xFD.ee\r\n").valid?
    refute @validator.new("test\\xC3\\x28.ee\r\n").valid?
  end

  def test_invalid_utf8_bytes
    # Test with actual invalid bytes for direct programmatic access
    refute @validator.new("\xFF.ee").valid?
    refute @validator.new("\xFF\xFE\xFD.ee").valid?
    refute @validator.new("test\xC3\x28.ee").valid?
  end

  def test_chinese_domain_name_in_utf8_is_valid
    value = '中国.ee'
    assert @validator.new(value).valid?
  end

  def test_chinese_domain_name_not_in_utf8_is_not_valid
    value = '中国.ee'.encode('gb2312')
    refute @validator.new(value).valid?
  end

  def test_mixed_chinese_and_ascii_domain_name
    value = 'test中国123.ee'.encode('utf-8')
    assert @validator.new(value).valid?
  end
end
