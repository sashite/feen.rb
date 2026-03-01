# frozen_string_literal: true

require_relative "../error"

module Sashite
  module Feen
    # Error raised when FEEN parsing fails at the top level.
    #
    # Covers general failures (input length, field count). Field-specific
    # errors have their own subclasses.
    #
    # @api public
    class ParseError < Error
      INPUT_TOO_LONG      = "input exceeds maximum length"
      INVALID_FIELD_COUNT = "invalid field count"

      freeze
    end
  end
end
