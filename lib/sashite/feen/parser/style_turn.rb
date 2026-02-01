# frozen_string_literal: true

require "sashite/sin"

require_relative "../shared/separators"
require_relative "../errors/style_turn_error"

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
      # - Left of `/`: Active Player (to move)
      # - Right of `/`: Inactive Player (waiting)
      #
      # The two tokens MUST have opposite case, ensuring both players
      # are represented.
      #
      # @example First player to move (same style)
      #   StyleTurn.parse("C/c")
      #   # => { active: <Sin C>, inactive: <Sin c> }
      #
      # @example Second player to move (same style)
      #   StyleTurn.parse("c/C")
      #   # => { active: <Sin c>, inactive: <Sin C> }
      #
      # @example Cross-style game (Chess vs Shogi)
      #   StyleTurn.parse("C/s")
      #   # => { active: <Sin C>, inactive: <Sin s> }
      #
      # @see https://sashite.dev/specs/feen/1.0.0/
      # @api private
      module StyleTurn
        # Parses a FEEN Style-Turn field string.
        #
        # @param input [String] The Style-Turn field string
        # @return [Hash] A hash with :active and :inactive keys containing SIN identifiers
        # @raise [StyleTurnError] If the input is not valid
        def self.parse(input)
          validate_delimiter!(input)

          active_str, inactive_str = input.split(Separators::SEGMENT, -1)

          active = parse_style(active_str)
          inactive = parse_style(inactive_str)

          validate_opposite_case!(active, inactive)

          { active:, inactive: }
        end

        class << self
          private

          # Validates that the input contains exactly one delimiter.
          #
          # @param input [String] The input to validate
          # @raise [StyleTurnError] If delimiter is missing or duplicated
          def validate_delimiter!(input)
            count = input.count(Separators::SEGMENT)

            raise StyleTurnError, StyleTurnError::INVALID_DELIMITER unless count == 1
          end

          # Parses a SIN style token.
          #
          # @param str [String] The string to parse
          # @return [Sashite::Sin::Identifier] The parsed SIN identifier
          # @raise [StyleTurnError] If SIN parsing fails
          def parse_style(str)
            ::Sashite::Sin.parse(str)
          rescue ::ArgumentError
            raise StyleTurnError, StyleTurnError::INVALID_STYLE_TOKEN
          end

          # Validates that the two style tokens have opposite case.
          #
          # One must be uppercase (first player) and one must be lowercase
          # (second player) to ensure both sides are represented.
          #
          # @param active [Sashite::Sin::Identifier] The active player's style
          # @param inactive [Sashite::Sin::Identifier] The inactive player's style
          # @raise [StyleTurnError] If both tokens have the same case
          def validate_opposite_case!(active, inactive)
            return if active.side != inactive.side

            raise StyleTurnError, StyleTurnError::SAME_CASE
          end
        end

        private_class_method :validate_delimiter!,
                             :parse_style,
                             :validate_opposite_case!

        freeze
      end
    end
  end
end
