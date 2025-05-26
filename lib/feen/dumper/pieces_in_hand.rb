# frozen_string_literal: true

require_relative File.join("pieces_in_hand", "no_pieces")
require_relative File.join("pieces_in_hand", "errors")

module Feen
  module Dumper
    # Handles conversion of pieces in hand data to FEEN notation string
    module PiecesInHand
      # Converts an array of piece identifiers to a FEEN-formatted pieces in hand string
      #
      # @param piece_chars [Array<String>] Array of piece identifiers in full PNN format
      # @return [String] FEEN-formatted pieces in hand string sorted according to FEEN specification:
      #   1. By quantity (descending)
      #   2. By complete PNN representation (alphabetically ascending)
      # @raise [ArgumentError] If any piece identifier is invalid
      # @example
      #   PiecesInHand.dump("P", "P", "P", "B", "B", "+P")
      #   # => "3P2B+P"
      #
      #   PiecesInHand.dump
      #   # => "-"
      def self.dump(*piece_chars)
        # If no pieces in hand, return the standardized empty indicator
        return NoPieces if piece_chars.empty?

        # Validate each piece character according to the FEEN specification (full PNN support)
        validated_chars = validate_piece_chars(piece_chars)

        # Count occurrences of each piece type
        piece_counts = validated_chars.tally

        # Sort according to FEEN specification:
        # 1. By quantity (descending)
        # 2. By complete PNN representation (alphabetically ascending)
        sorted_pieces = piece_counts.sort do |a, b|
          count_comparison = b[1] <=> a[1] # quantity descending
          count_comparison.zero? ? a[0] <=> b[0] : count_comparison # then alphabetical
        end

        # Format the pieces sequence with proper count prefixes
        format_pieces_sequence(sorted_pieces)
      end

      # Validates all piece characters according to FEEN specification with full PNN support
      #
      # @param piece_chars [Array<Object>] Array of piece character candidates
      # @return [Array<String>] Array of validated piece characters
      # @raise [ArgumentError] If any piece character is invalid
      private_class_method def self.validate_piece_chars(piece_chars)
        piece_chars.each_with_index.map do |char, index|
          validate_piece_char(char, index)
        end
      end

      # Validates a single piece character according to FEEN specification with full PNN support
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

        # Validate format (full PNN notation: [prefix]letter[suffix])
        # <piece> ::= <letter> | <prefix> <letter> | <letter> <suffix> | <prefix> <letter> <suffix>
        # <prefix> ::= "+" | "-"
        # <suffix> ::= "'"
        # <letter> ::= [a-zA-Z]
        unless char.match?(/\A[-+]?[a-zA-Z]'?\z/)
          raise ::ArgumentError, format(
            Errors[:invalid_format],
            index: index,
            value: char
          )
        end

        char
      end

      # Formats the pieces sequence with proper count prefixes according to FEEN specification
      #
      # @param sorted_pieces [Array<Array>] Array of [piece, count] pairs sorted according to FEEN rules
      # @return [String] Formatted pieces sequence
      private_class_method def self.format_pieces_sequence(sorted_pieces)
        sorted_pieces.map do |piece, count|
          if count == 1
            piece
          else
            "#{count}#{piece}"
          end
        end.join
      end
    end
  end
end
