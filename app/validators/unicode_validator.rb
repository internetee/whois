# frozen_string_literal: true

class UnicodeValidator
  UTF8_ENCODING = 'UTF-8'
  HEX_PATTERN = /\\x[0-9A-Fa-f]{2}/.freeze

  private attr_reader :value

  def initialize(value)
    @value = value
  end

  def valid?
    return false unless value

    string = prepare_string(value)

    # Verify UTF-8 encoding
    if string.force_encoding(UTF8_ENCODING).valid_encoding?
      value.force_encoding(UTF8_ENCODING).valid_encoding?
    else
      false
    end
  rescue ArgumentError
    false
  end

  private

  def prepare_string(input)
    # Handle both escaped strings from whois command and direct byte sequences
    string = input.dup

    # Remove trailing \r\n if present (from whois command)
    string.chomp!

    # Unescape hex sequences if present
    unescape_hex_sequences(string)
  end

  def unescape_hex_sequences(string)
    if string.match?(HEX_PATTERN)
      string.gsub(/\\x([0-9A-Fa-f]{2})/) { ::Regexp.last_match(1).to_i(16).chr }
    else
      string
    end
  end
end
