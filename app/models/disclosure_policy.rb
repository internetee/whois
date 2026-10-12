# frozen_string_literal: true

require 'time'

# Activation switch for the new .ee disclosure policy
# (https://github.com/internetee/registry/issues/2969).
#
# DISCLOSURE_POLICY_ACTIVE_FROM must be an ISO 8601 timestamp with an offset,
# e.g. "2027-01-18T00:00:00+02:00". It is parsed once when this file is loaded:
# unset/blank keeps the legacy behaviour, a malformed value fails the boot.
module DisclosurePolicy
  ENV_VARIABLE = 'DISCLOSURE_POLICY_ACTIVE_FROM'
  OFFSET_SUFFIX = /(Z|[+-]\d{2}(:?\d{2})?)\z/

  class << self
    # Test seam: assign a Time (or nil) directly instead of setting ENV.
    attr_accessor :active_from

    def active?(now = Time.now)
      !active_from.nil? && now >= active_from
    end

    # Re-parses ENV[ENV_VARIABLE]. Called once at load; tests use it to
    # restore the env-driven state after overriding +active_from+.
    def reset!
      @active_from = parse(ENV[ENV_VARIABLE])
    end

    private

    def parse(value)
      return if value.nil? || value.strip.empty?

      value = value.strip
      raise ArgumentError unless value.match?(OFFSET_SUFFIX)

      Time.iso8601(value)
    rescue ArgumentError
      raise ArgumentError,
            "#{ENV_VARIABLE} must be an ISO 8601 timestamp with an offset " \
            "(e.g. 2027-01-18T00:00:00+02:00), got: #{value.inspect}"
    end
  end

  reset!
end
