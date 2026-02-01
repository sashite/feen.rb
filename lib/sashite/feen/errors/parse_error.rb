# frozen_string_literal: true

require_relative "../error"

module Sashite
  module Feen
    # Error raised when FEEN parsing fails at the top level.
    #
    # This error covers general parsing failures such as invalid input
    # length or incorrect field count. More specific parsing errors
    # (piece placement, hands, style-turn) have their own subclasses.
    #
    # @example Catching parse errors
    #   begin
    #     Sashite::Feen.parse(input)
    #   rescue Sashite::Feen::ParseError => e
    #     puts "Parse error: #{e.message}"
    #   end
    #
    # @see https://sashite.dev/specs/feen/1.0.0/
    # @api public
    class ParseError < Error
      # Input string exceeds maximum allowed length.
      INPUT_TOO_LONG = "input exceeds maximum length"

      # Input does not contain exactly 3 space-separated fields.
      INVALID_FIELD_COUNT = "invalid field count"

      freeze
    end
  end
end
