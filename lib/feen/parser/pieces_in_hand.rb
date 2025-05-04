# frozen_string_literal: true

require_relative File.join("pieces_in_hand", "valid_format_pattern")
require_relative File.join("pieces_in_hand", "no_pieces")
require_relative File.join("pieces_in_hand", "errors")

module Feen
  module Parser
    # Handles parsing of the pieces in hand section of a FEEN string.
    # Pieces in hand represent pieces available for dropping onto the board.
    module PiecesInHand
      # Parses the pieces in hand section of a FEEN string.
      #
      # @param pieces_in_hand_str [String] FEEN pieces in hand string
      # @return [Array<String>] Array of piece identifiers
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

        return [] if pieces_in_hand_str == NoPieces

        pieces_in_hand_str.chars
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

      # Validates that the input string matches the expected format.
      #
      # @param str [String] Input string to validate
      # @raise [ArgumentError] If format is invalid
      # @return [void]
      private_class_method def self.validate_format(str)
        return if str.match?(ValidFormatPattern)

        raise ::ArgumentError, format(Errors[:invalid_format], str)
      end
    end
  end
end
