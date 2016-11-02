class UnicodeValidator
  def initialize(value)
    @value = value
  end

  def valid?
    value.force_encoding('utf-8').valid_encoding?
  end

  private

  attr_reader :value
end
