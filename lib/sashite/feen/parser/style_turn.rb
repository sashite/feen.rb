# frozen_string_literal: true

require "sashite/sin"

require_relative "../constants"
require_relative "../errors"

module Sashite
  module Feen
    module Parser
      # Parser for FEEN Style-Turn field (Field 3).
      #
      # The Style-Turn field encodes:
      # - The native Piece Style associated with each Player Side
      # - The identity of the Active Player
      #
      # Format:
      #
      #   <ACTIVE-STYLE>/<INACTIVE-STYLE>
      #
      # Where each STYLE is a valid SIN token (exactly one ASCII letter).
      #
      # Side attribution (by case):
      # - Uppercase (A-Z): Player Side `first`
      # - Lowercase (a-z): Player Side `second`
      #
      # Turn attribution (by position):
      # - Left of `/`: Active Player
      # - Right of `/`: Inactive Player
      #
      # @api private
      #
      # @example
      #   StyleTurn.parse("C/c")
      #   # => { active: <Sin::Identifier C>, inactive: <Sin::Identifier c> }
      #
      #   StyleTurn.parse("s/S")
      #   # => { active: <Sin::Identifier s>, inactive: <Sin::Identifier S> }
      #
      # @see https://sashite.dev/specs/feen/1.0.0/
      module StyleTurn
        # Parses a FEEN Style-Turn field string.
        #
        # @param input [String] The Style-Turn field string
        # @return [Hash] A hash with :active and :inactive keys containing SIN identifiers
        # @raise [Errors::Argument] If the input is not valid
        def self.parse(input)
          validate_delimiter!(input)

          active_str, inactive_str = input.split(Constants::SEGMENT_SEPARATOR, -1)

          active = parse_style(active_str)
          inactive = parse_style(inactive_str)

          validate_opposite_case!(active, inactive)

          { active: active, inactive: inactive }
        end

        class << self
          private

          # Validates that the input contains exactly one delimiter.
          #
          # @param input [String] The input to validate
          # @raise [Errors::Argument] If delimiter is missing or duplicated
          def validate_delimiter!(input)
            return if input.count(Constants::SEGMENT_SEPARATOR) == 1

            raise Errors::Argument, Errors::Argument::Messages::INVALID_STYLE_TURN_DELIMITER
          end

          # Parses a SIN style token.
          #
          # @param str [String] The string to parse
          # @return [Sashite::Sin::Identifier] The parsed SIN identifier
          # @raise [Sashite::Sin::Errors::Argument] If SIN parsing fails
          def parse_style(str)
            ::Sashite::Sin.parse(str)
          end

          # Validates that the two style tokens have opposite case.
          #
          # @param active [Sashite::Sin::Identifier] The active player's style
          # @param inactive [Sashite::Sin::Identifier] The inactive player's style
          # @raise [Errors::Argument] If both tokens have the same case
          def validate_opposite_case!(active, inactive)
            return if active.side != inactive.side

            raise Errors::Argument, Errors::Argument::Messages::STYLE_TOKENS_SAME_CASE
          end
        end
      end
    end
  end
end
