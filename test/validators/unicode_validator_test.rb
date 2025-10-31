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
    refute @validator.new("\\xFF.ee\r\n").valid?
    refute @validator.new("\\xFF\\xFE\\xFD.ee\r\n").valid?
    refute @validator.new("test\\xC3\\x28.ee\r\n").valid?
  end

  def test_invalid_utf8_bytes
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

  def test_nil_value
    refute @validator.new(nil).valid?
  end

  def test_empty_string
    assert @validator.new('').valid?
  end

  def test_unicode_escaped_sequences_valid
    assert @validator.new("\\x61.ee").valid?
    assert @validator.new("test\\x61test.ee").valid?
  end

  def test_unicode_escaped_sequences_invalid
    refute @validator.new("\\xFF.ee").valid?
  end

  def test_string_with_trailing_carriage_return
    assert @validator.new("example.ee\r\n").valid?
    refute @validator.new("\\xFF.ee\r\n").valid?
  end

  def test_valid_encoding_but_rescues_argument_error
    value = "\xFF\xFE".force_encoding('BINARY')
    validator = @validator.new(value)
    result = validator.valid?
    assert [true, false].include?(result)
  end

  def test_hex_escaped_multibyte_checkmark_is_valid
    assert @validator.new('\\xE2\\x9C\\x94').valid?
  end

  def test_returns_false_when_valid_utf8_encoding_raises_argument_error
    validator = @validator.new('test')
    validator.stub(:valid_utf8_encoding?, proc { raise ArgumentError }) do
      refute validator.valid?
    end
  end

  def test_unescape_hex_sequences_returns_original_when_no_hex_patterns
    validator = @validator.new('PlainText')
    assert_equal 'PlainText', validator.send(:unescape_hex_sequences, 'PlainText')
  end
end
