# frozen_string_literal: true

require_relative File.join("pieces_in_hand", "errors")
require_relative File.join("pieces_in_hand", "no_pieces")
require_relative File.join("pieces_in_hand", "piece_count_pattern")
require_relative File.join("pieces_in_hand", "valid_format_pattern")

module Feen
  module Parser
    # Handles parsing of the pieces in hand section of a FEEN string.
    # Pieces in hand represent pieces available for dropping onto the board.
    module PiecesInHand
      # Parses the pieces in hand section of a FEEN string.
      #
      # @param pieces_in_hand_str [String] FEEN pieces in hand string
      # @return [Array<String>] Array of single-character piece identifiers in the
      #   format specified in the FEEN string (no prefixes or suffixes), expanded
      #   based on their counts and sorted in ASCII lexicographic order.
      #   Empty array if no pieces are in hand.
      # @raise [ArgumentError] If the input string is invalid
      #
      # @example Parse no pieces in hand
      #   PiecesInHand.parse("-")
      #   # => []
      #
      # @example Parse multiple pieces in hand
      #   PiecesInHand.parse("BN2Pb")
      #   # => ["B", "N", "P", "P", "b"]
      #
      # @example Parse pieces with counts
      #   PiecesInHand.parse("N5P2b")
      #   # => ["N", "P", "P", "P", "P", "P", "b", "b"]
      def self.parse(pieces_in_hand_str)
        # Validate input
        validate_input_type(pieces_in_hand_str)
        validate_format(pieces_in_hand_str)

        # Handle the no-pieces case early
        return [] if pieces_in_hand_str == NoPieces

        # Extract pieces with their counts and validate the order
        pieces_with_counts = extract_pieces_with_counts(pieces_in_hand_str)
        validate_lexicographic_order(pieces_with_counts)

        # Expand the pieces into an array and maintain lexicographic ordering
        expand_pieces(pieces_with_counts)
      end

      # Validates that the input is a non-empty string.
      #
      # @param str [String] Input string to validate
      # @raise [ArgumentError] If input is not a string or is empty
      # @return [void]
      private_class_method def self.validate_input_type(str)
        raise ::ArgumentError, format(Errors[:invalid_type], str.class) unless str.is_a?(::String)
        raise ::ArgumentError, Errors[:empty_string] if str.empty?
      end

      # Validates that the input string matches the expected format according to FEEN specification.
      #
      # @param str [String] Input string to validate
      # @raise [ArgumentError] If format is invalid
      # @return [void]
      private_class_method def self.validate_format(str)
        return if str == NoPieces || str.match?(ValidFormatPattern)

        raise ::ArgumentError, format(Errors[:invalid_format], str)
      end

      # Extracts pieces with their counts from the FEEN string.
      #
      # @param str [String] FEEN pieces in hand string
      # @return [Array<Hash>] Array of hashes with :piece and :count keys
      private_class_method def self.extract_pieces_with_counts(str)
        result = []
        position = 0

        while position < str.length
          match = str[position..].match(PieceCountPattern)
          break unless match

          count_str, piece = match.captures
          count = count_str ? count_str.to_i : 1

          # Add to our result with piece type and count
          result << { piece: piece, count: count }

          # Move position forward
          position += match[0].length
        end

        result
      end

      # Validates that pieces are in lexicographic ASCII order.
      #
      # @param pieces_with_counts [Array<Hash>] Array of pieces with their counts
      # @raise [ArgumentError] If pieces are not in lexicographic order
      # @return [void]
      private_class_method def self.validate_lexicographic_order(pieces_with_counts)
        pieces = pieces_with_counts.map { |item| item[:piece] }

        # Verify the array is sorted lexicographically
        return if pieces == pieces.sort

        raise ::ArgumentError, Errors[:sorting_error]
      end

      # Expands the pieces based on their counts into an array.
      #
      # @param pieces_with_counts [Array<Hash>] Array of pieces with their counts
      # @return [Array<String>] Array of expanded pieces
      private_class_method def self.expand_pieces(pieces_with_counts)
        pieces_with_counts.flat_map do |item|
          Array.new(item[:count], item[:piece])
        end
      end
    end
  end
end
