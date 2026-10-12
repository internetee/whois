require_relative '../test_helper'

class DisclosurePolicyTest < Minitest::Test
  ENV_VARIABLE = 'DISCLOSURE_POLICY_ACTIVE_FROM'

  def teardown
    DisclosurePolicy.reset!
    super
  end

  def test_inactive_when_env_variable_is_unset
    with_env_variable(nil) do
      DisclosurePolicy.reset!
      assert_nil DisclosurePolicy.active_from
      refute DisclosurePolicy.active?
    end
  end

  def test_inactive_when_env_variable_is_blank
    with_env_variable('   ') do
      DisclosurePolicy.reset!
      assert_nil DisclosurePolicy.active_from
      refute DisclosurePolicy.active?
    end
  end

  def test_raises_on_malformed_value
    with_env_variable('next tuesday') do
      error = assert_raises(ArgumentError) { DisclosurePolicy.reset! }
      assert_includes error.message, ENV_VARIABLE
    end
  end

  def test_raises_when_timestamp_has_no_offset
    with_env_variable('2027-01-18T00:00:00') do
      assert_raises(ArgumentError) { DisclosurePolicy.reset! }
    end
  end

  def test_parses_iso8601_timestamp_with_offset
    with_env_variable('2027-01-18T00:00:00+02:00') do
      DisclosurePolicy.reset!
      assert_equal Time.iso8601('2027-01-18T00:00:00+02:00'), DisclosurePolicy.active_from
    end
  end

  def test_inactive_before_activation
    DisclosurePolicy.active_from = Time.iso8601('2027-01-18T00:00:00+02:00')
    refute DisclosurePolicy.active?(Time.iso8601('2027-01-17T23:59:59+02:00'))
  end

  def test_active_exactly_at_activation
    active_from = Time.iso8601('2027-01-18T00:00:00+02:00')
    DisclosurePolicy.active_from = active_from
    assert DisclosurePolicy.active?(active_from)
  end

  def test_active_after_activation
    DisclosurePolicy.active_from = Time.iso8601('2027-01-18T00:00:00+02:00')
    assert DisclosurePolicy.active?(Time.iso8601('2027-01-18T00:00:01+02:00'))
  end

  private

  def with_env_variable(value)
    previous = ENV[ENV_VARIABLE]
    value.nil? ? ENV.delete(ENV_VARIABLE) : ENV[ENV_VARIABLE] = value
    yield
  ensure
    previous.nil? ? ENV.delete(ENV_VARIABLE) : ENV[ENV_VARIABLE] = previous
  end
end
