# frozen_string_literal: true

require "sashite/sin"

require_relative "../shared/ascii"
require_relative "../shared/separators"
require_relative "../errors/style_turn_error"

module Sashite
  module Feen
    module Parser
      # Parser for the FEEN Style-Turn field (Field 3).
      #
      # Format:
      #
      #   <ACTIVE-STYLE>/<INACTIVE-STYLE>
      #
      # Where each STYLE is a valid SIN token (exactly one ASCII letter).
      # The two tokens MUST be of opposite case:
      # - Uppercase → first player's style
      # - Lowercase → second player's style
      #
      # Turn is determined by position: the left token is the active player.
      #
      # Provides a dual-path API:
      # - {.safe_parse} returns nil on invalid input (no exceptions)
      # - {.parse} raises {StyleTurnError} on invalid input
      #
      # @example Parsing first player to move
      #   StyleTurn.safe_parse("C/c")
      #   # => { styles: { first: "C", second: "c" }, turn: :first }
      #
      # @example Parsing second player to move
      #   StyleTurn.safe_parse("c/C")
      #   # => { styles: { first: "C", second: "c" }, turn: :second }
      #
      # @example Invalid input
      #   StyleTurn.safe_parse("C/C")
      #   # => nil
      #
      # @see https://sashite.dev/specs/feen/1.0.0/
      # @api private
      module StyleTurn
        # Parses a Style-Turn field string, returning nil on failure.
        #
        # @param input [String] The Style-Turn field string
        # @return [Hash{Symbol => Object}, nil]
        #   { styles: { first: String, second: String }, turn: Symbol } or nil
        def self.safe_parse(input)
          # Must contain exactly one "/" delimiter
          slash_pos = nil
          i = 0

          while i < input.bytesize
            if input.getbyte(i) == Ascii::SLASH
              return nil unless slash_pos.nil?

              slash_pos = i
            end

            i += 1
          end

          return nil if slash_pos.nil?

          active_str = input.byteslice(0, slash_pos)
          inactive_str = input.byteslice(slash_pos + 1, input.bytesize - slash_pos - 1)

          # Both tokens must be valid SIN identifiers
          return nil unless ::Sashite::Sin.valid?(active_str)
          return nil unless ::Sashite::Sin.valid?(inactive_str)

          active_byte = active_str.getbyte(0)
          inactive_byte = inactive_str.getbyte(0)

          # Must be opposite case
          active_upper = Ascii.uppercase?(active_byte)
          inactive_upper = Ascii.uppercase?(inactive_byte)

          return nil if active_upper == inactive_upper

          if active_upper
            # Active is uppercase → first player to move
            { styles: { first: active_str, second: inactive_str }, turn: :first }
          else
            # Active is lowercase → second player to move
            { styles: { first: inactive_str, second: active_str }, turn: :second }
          end
        end

        # Parses a Style-Turn field string, raising on failure.
        #
        # @param input [String] The Style-Turn field string
        # @return [Hash{Symbol => Object}]
        #   { styles: { first: String, second: String }, turn: Symbol }
        # @raise [StyleTurnError] If the input is not valid
        def self.parse(input)
          result = safe_parse(input)
          return result unless result.nil?

          # Re-validate to produce the specific error message
          raise_specific_error!(input)
        end

        class << self
          private

          # Re-validates input to determine the specific error to raise.
          #
          # This method is only called on the error path (after safe_parse
          # returned nil), so its cost is acceptable.
          #
          # @param input [String] The invalid input
          # @raise [StyleTurnError] Always raises with a specific message
          def raise_specific_error!(input)
            # Check delimiter
            parts = input.split(Separators::SEGMENT, -1)

            unless parts.size == 2
              raise StyleTurnError, StyleTurnError::INVALID_DELIMITER
            end

            active_str, inactive_str = parts

            # Check each token
            unless ::Sashite::Sin.valid?(active_str)
              raise StyleTurnError, StyleTurnError::INVALID_STYLE_TOKEN
            end

            unless ::Sashite::Sin.valid?(inactive_str)
              raise StyleTurnError, StyleTurnError::INVALID_STYLE_TOKEN
            end

            # Must be opposite case
            raise StyleTurnError, StyleTurnError::SAME_CASE
          end
        end

        private_class_method :raise_specific_error!

        freeze
      end
    end
  end
end
