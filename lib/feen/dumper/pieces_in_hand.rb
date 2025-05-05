# frozen_string_literal: true

require_relative File.join("pieces_in_hand", "no_pieces")
require_relative File.join("pieces_in_hand", "errors")

module Feen
  module Dumper
    # Handles conversion of pieces in hand data to FEEN notation string
    module PiecesInHand
      # Converts an array of piece identifiers to a FEEN-formatted pieces in hand string
      #
      # @param piece_chars [Array<String>] Array of single-character piece identifiers
      # @return [String] FEEN-formatted pieces in hand string
      # @raise [ArgumentError] If any piece identifier is invalid
      # @example
      #   PiecesInHand.dump("P", "p", "B")
      #   # => "BPp"
      #
      #   PiecesInHand.dump
      #   # => "-"
      def self.dump(*piece_chars)
        # If no pieces in hand, return the standardized empty indicator
        return NoPieces if piece_chars.empty?

        # Validate each piece character according to the FEEN specification
        validated_chars = validate_piece_chars(piece_chars)

        # Sort pieces in ASCII lexicographic order and join them
        validated_chars.sort.join
      end

      # Validates all piece characters according to FEEN specification
      #
      # @param piece_chars [Array<Object>] Array of piece character candidates
      # @return [Array<String>] Array of validated piece characters
      # @raise [ArgumentError] If any piece character is invalid
      private_class_method def self.validate_piece_chars(piece_chars)
        piece_chars.each_with_index.map do |char, index|
          validate_piece_char(char, index)
        end
      end

      # Validates a single piece character according to FEEN specification
      #
      # @param char [Object] Piece character candidate
      # @param index [Integer] Index of the character in the original array
      # @return [String] Validated piece character
      # @raise [ArgumentError] If the piece character is invalid
      private_class_method def self.validate_piece_char(char, index)
        # Validate type
        unless char.is_a?(::String)
          raise ::ArgumentError, format(
            Errors[:invalid_type],
            index: index,
            type:  char.class
          )
        end

        # Validate format (single alphabetic character)
        unless char.match?(/\A[a-zA-Z]\z/)
          raise ::ArgumentError, format(
            Errors[:invalid_format],
            index: index,
            value: char
          )
        end

        char
      end
    end
  end
end
