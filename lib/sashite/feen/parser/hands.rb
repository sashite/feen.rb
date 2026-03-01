# frozen_string_literal: true

require_relative "../shared/ascii"
require_relative "../shared/separators"
require_relative "../errors/hands_error"
require_relative "hand"

module Sashite
  module Feen
    module Parser
      # Parser for the FEEN Hands field (Field 2).
      #
      # The Hands field encodes off-board pieces held by each player:
      #
      #   <FIRST-HAND>/<SECOND-HAND>
      #
      # The "/" delimiter is always present. Either hand may be empty.
      # Each hand is parsed by {Hand} into an expanded array of piece strings.
      #
      # Provides a dual-path API:
      # - {.safe_parse} returns nil on invalid input (no exceptions)
      # - {.parse} raises {HandsError} on invalid input
      #
      # @example Empty hands
      #   Hands.safe_parse("/")
      #   # => { first: [], second: [] }
      #
      # @example Hands with pieces
      #   Hands.safe_parse("2PN/p")
      #   # => { first: ["P", "P", "N"], second: ["p"] }
      #
      # @see https://sashite.dev/specs/feen/1.0.0/
      # @api private
      module Hands
        # Parses a Hands field string, returning nil on failure.
        #
        # @param input [String] The Hands field string
        # @return [Hash{Symbol => Array<String>}, nil]
        #   { first: [...], second: [...] } or nil if invalid
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

          first_str = input.byteslice(0, slash_pos)
          second_str = input.byteslice(slash_pos + 1, input.bytesize - slash_pos - 1)

          first_hand = Hand.safe_parse(first_str)
          return nil if first_hand.nil?

          second_hand = Hand.safe_parse(second_str)
          return nil if second_hand.nil?

          { first: first_hand, second: second_hand }
        end

        # Parses a Hands field string, raising on failure.
        #
        # @param input [String] The Hands field string
        # @return [Hash{Symbol => Array<String>}]
        #   { first: [...], second: [...] }
        # @raise [HandsError] If the input is not valid
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
          # Only called on the error path (after safe_parse returned nil).
          #
          # @param input [String] The invalid input
          # @raise [HandsError] Always raises with a specific message
          def raise_specific_error!(input)
            parts = input.split(Separators::SEGMENT, -1)

            unless parts.size == 2
              raise HandsError, HandsError::INVALID_DELIMITER
            end

            first_str, second_str = parts

            # Delegate to Hand.parse which raises specific errors
            Hand.parse(first_str)
            Hand.parse(second_str)
          end
        end

        private_class_method :raise_specific_error!

        freeze
      end
    end
  end
end
