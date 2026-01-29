# frozen_string_literal: true

require "sashite/epin"

require_relative "../constants"
require_relative "../errors"

module Sashite
  module Feen
    module Parser
      # Parser for FEEN Hands field (Field 2).
      #
      # The Hands field encodes off-board pieces held by each player:
      #
      #   <FIRST-HAND>/<SECOND-HAND>
      #
      # Each hand is a concatenation of hand items with no separators:
      #
      #   [<count>]<piece>
      #
      # Where:
      # - <piece> is a valid EPIN token
      # - <count> is an optional multiplicity (≥ 2 if present, absent = 1)
      #
      # @example
      #   Hands.parse("/")
      #   # => { first: [], second: [] }
      #
      #   Hands.parse("2P/p")
      #   # => { first: [{ piece: <Epin::Identifier P>, count: 2 }],
      #   #      second: [{ piece: <Epin::Identifier p>, count: 1 }] }
      #
      # @see https://sashite.dev/specs/feen/1.0.0/
      module Hands
        # Parses a FEEN Hands field string.
        #
        # @param input [String] The Hands field string
        # @return [Hash] A hash with :first and :second keys, each containing an array of hand items
        # @raise [Errors::Argument] If the input is not valid
        def self.parse(input)
          validate_delimiter!(input)

          first_str, second_str = input.split(Constants::SEGMENT_SEPARATOR, -1)

          {
            first:  parse_hand(first_str),
            second: parse_hand(second_str)
          }
        end

        class << self
          private

          # Validates that the input contains exactly one delimiter.
          #
          # @param input [String] The input to validate
          # @raise [Errors::Argument] If delimiter is missing or duplicated
          def validate_delimiter!(input)
            return if input.count(Constants::SEGMENT_SEPARATOR) == 1

            raise Errors::Argument, Errors::Argument::Messages::INVALID_HANDS_DELIMITER
          end

          # Parses a single hand string into an array of hand items.
          #
          # @param hand_str [String] The hand string to parse
          # @return [Array<Hash>] Array of hand items with :piece and :count keys
          def parse_hand(hand_str)
            return [] if hand_str.empty?

            items = []
            pos = 0

            while pos < hand_str.bytesize
              count, pos = extract_count(hand_str, pos)
              piece, pos = extract_piece(hand_str, pos)
              items << { piece: piece, count: count }
            end

            items
          end

          # Extracts an optional count prefix starting at pos.
          #
          # @param str [String] The string to extract from
          # @param pos [Integer] Starting position
          # @return [Array(Integer, Integer)] The count (1 if absent) and new position
          # @raise [Errors::Argument] If count is invalid
          def extract_count(str, pos)
            byte = str.getbyte(pos)
            return [1, pos] unless digit?(byte)

            start_pos = pos
            pos += 1

            # Consume remaining digits
            pos += 1 while pos < str.bytesize && digit?(str.getbyte(pos))

            count_str = str.byteslice(start_pos, pos - start_pos)
            validate_count!(count_str)

            [count_str.to_i, pos]
          end

          # Validates a count string.
          #
          # @param count_str [String] The count string to validate
          # @raise [Errors::Argument] If count is 0, 1, or has leading zeros
          def validate_count!(count_str)
            # Leading zeros are forbidden
            if count_str.bytesize > 1 && count_str.getbyte(0) == 0x30
              raise Errors::Argument, Errors::Argument::Messages::INVALID_HAND_COUNT
            end

            count = count_str.to_i

            # Count must be >= 2 when explicit
            return unless count < 2

            raise Errors::Argument, Errors::Argument::Messages::INVALID_HAND_COUNT
          end

          # Extracts and parses an EPIN token starting at pos.
          #
          # EPIN structure: [+-]?[A-Za-z]\^?'?
          #
          # @param str [String] The string to extract from
          # @param pos [Integer] Starting position
          # @return [Array(Sashite::Epin::Identifier, Integer)] The parsed EPIN and new position
          # @raise [Sashite::Epin::Errors::Argument] If EPIN parsing fails
          def extract_piece(str, pos)
            start_pos = pos
            byte = str.getbyte(pos)

            # Optional state modifier: + or -
            if byte == 0x2B || byte == 0x2D
              pos += 1
              byte = str.getbyte(pos)
            end

            # Required letter: A-Z or a-z
            if letter?(byte)
              pos += 1
              byte = str.getbyte(pos)
            end

            # Optional terminal marker: ^
            if byte == 0x5E
              pos += 1
              byte = str.getbyte(pos)
            end

            # Optional derivation marker: '
            pos += 1 if byte == 0x27

            epin_str = str.byteslice(start_pos, pos - start_pos)
            piece = ::Sashite::Epin.parse(epin_str)

            [piece, pos]
          end

          # Checks if byte is an ASCII digit (0-9).
          #
          # @param byte [Integer, nil] The byte to check
          # @return [Boolean]
          def digit?(byte)
            byte && byte >= 0x30 && byte <= 0x39
          end

          # Checks if byte is an ASCII letter (A-Z or a-z).
          #
          # @param byte [Integer, nil] The byte to check
          # @return [Boolean]
          def letter?(byte)
            byte && ((byte >= 0x41 && byte <= 0x5A) || (byte >= 0x61 && byte <= 0x7A))
          end
        end
      end
    end
  end
end
