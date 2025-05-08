# frozen_string_literal: true

module Feen
  module Parser
    # Handles parsing of the pieces in hand section of a FEEN string.
    # Pieces in hand represent pieces available for dropping onto the board.
    module PiecesInHand
      # Character used to represent no pieces in hand
      NO_PIECES = "-"

      # Error messages for validation
      ERRORS = {
        invalid_type:   "Pieces in hand must be a string, got %s",
        empty_string:   "Pieces in hand string cannot be empty",
        invalid_format: "Invalid pieces in hand format: %s",
        sorting_error:  "Pieces in hand must be in ASCII lexicographic order"
      }.freeze

      # Valid pattern for pieces in hand based on BNF:
      # <pieces-in-hand> ::= "-" | <piece> <pieces-in-hand>
      # <piece> ::= [a-zA-Z]
      VALID_FORMAT_PATTERN = /\A(?:-|[a-zA-Z]+)\z/

      # Parses the pieces in hand section of a FEEN string.
      #
      # @param pieces_in_hand_str [String] FEEN pieces in hand string
      # @return [Array<String>] Array of single-character piece identifiers in the
      #   format specified in the FEEN string (no prefixes or suffixes), sorted in ASCII
      #   lexicographic order. Empty array if no pieces are in hand.
      # @raise [ArgumentError] If the input string is invalid
      #
      # @example Parse no pieces in hand
      #   PiecesInHand.parse("-")
      #   # => []
      #
      # @example Parse multiple pieces in hand
      #   PiecesInHand.parse("BNPPb")
      #   # => ["B", "N", "P", "P", "b"]
      def self.parse(pieces_in_hand_str)
        validate_input_type(pieces_in_hand_str)
        validate_format(pieces_in_hand_str)

        return [] if pieces_in_hand_str == NO_PIECES

        pieces = pieces_in_hand_str.chars
        validate_pieces_order(pieces)

        pieces
      end

      # Validates that the input is a non-empty string.
      #
      # @param str [String] Input string to validate
      # @raise [ArgumentError] If input is not a string or is empty
      # @return [void]
      private_class_method def self.validate_input_type(str)
        raise ::ArgumentError, format(ERRORS[:invalid_type], str.class) unless str.is_a?(::String)
        raise ::ArgumentError, ERRORS[:empty_string] if str.empty?
      end

      # Validates that the input string matches the expected format.
      #
      # @param str [String] Input string to validate
      # @raise [ArgumentError] If format is invalid
      # @return [void]
      private_class_method def self.validate_format(str)
        return if str.match?(VALID_FORMAT_PATTERN)

        raise ::ArgumentError, format(ERRORS[:invalid_format], str)
      end

      # Validates that pieces are sorted in ASCII lexicographic order.
      #
      # @param pieces [Array<String>] Array of piece identifiers
      # @raise [ArgumentError] If pieces are not sorted
      # @return [void]
      private_class_method def self.validate_pieces_order(pieces)
        return if pieces == pieces.sort

        raise ::ArgumentError, ERRORS[:sorting_error]
      end
    end
  end
end
