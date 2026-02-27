# frozen_string_literal: true

require "sashite/sin"

require_relative "../shared/ascii"
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
      # Returns a hash with :styles and :turn keys, ready for Qi::Position:
      # - :styles maps each side to its SIN token string
      # - :turn is :first or :second
      #
      # @example First player to move (same style)
      #   StyleTurn.parse("C/c")
      #   # => { styles: { first: "C", second: "c" }, turn: :first }
      #
      # @example Second player to move (same style)
      #   StyleTurn.parse("c/C")
      #   # => { styles: { first: "C", second: "c" }, turn: :second }
      #
      # @example Cross-style game (Chess vs Shogi)
      #   StyleTurn.parse("C/s")
      #   # => { styles: { first: "C", second: "s" }, turn: :first }
      #
      # @see https://sashite.dev/specs/feen/1.0.0/
      # @api private
      module StyleTurn
        # Parses a FEEN Style-Turn field string.
        #
        # @param input [String] The Style-Turn field string
        # @return [Hash] A hash with :styles (Hash) and :turn (Symbol) keys
        # @raise [StyleTurnError] If the input is not valid
        def self.parse(input)
          validate_delimiter!(input)

          active_str, inactive_str = input.split(Separators::SEGMENT, -1)

          validate_style!(active_str)
          validate_style!(inactive_str)

          active_byte = active_str.getbyte(0)
          inactive_byte = inactive_str.getbyte(0)

          validate_opposite_case!(active_byte, inactive_byte)

          if Ascii.uppercase?(active_byte)
            { styles: { first: active_str, second: inactive_str }, turn: :first }
          else
            { styles: { first: inactive_str, second: active_str }, turn: :second }
          end
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

          # Validates a SIN style token string.
          #
          # Delegates validation to the sashite-sin library.
          #
          # @param str [String] The string to validate
          # @raise [StyleTurnError] If SIN validation fails
          def validate_style!(str)
            return if ::Sashite::Sin.valid?(str)

            raise StyleTurnError, StyleTurnError::INVALID_STYLE_TOKEN
          end

          # Validates that the two style tokens have opposite case.
          #
          # One must be uppercase (first player) and one must be lowercase
          # (second player) to ensure both sides are represented.
          #
          # @param active_byte [Integer] Byte value of the active style token
          # @param inactive_byte [Integer] Byte value of the inactive style token
          # @raise [StyleTurnError] If both tokens have the same case
          def validate_opposite_case!(active_byte, inactive_byte)
            # Both uppercase or both lowercase → same case
            return unless Ascii.uppercase?(active_byte) == Ascii.uppercase?(inactive_byte)

            raise StyleTurnError, StyleTurnError::SAME_CASE
          end
        end

        private_class_method :validate_delimiter!,
                             :validate_style!,
                             :validate_opposite_case!

        freeze
      end
    end
  end
end
