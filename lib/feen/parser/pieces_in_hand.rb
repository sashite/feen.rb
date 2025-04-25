# frozen_string_literal: true

module Feen
  module Parser
    # Handles parsing of the pieces in hand section of a FEEN string
    module PiecesInHand
      NO_PIECES = "-"
      ERRORS = {
        invalid_type:       "Pieces in hand must be a string, got %s",
        empty_string:       "Pieces in hand string cannot be empty",
        invalid_chars:      "Invalid characters in pieces in hand: %s",
        invalid_identifier: "Invalid piece identifier at position %d"
      }.freeze

      # Parses the pieces in hand section of a FEEN string
      #
      # @param pieces_in_hand_str [String] FEEN pieces in hand string
      # @return [Array<Hash>] Array of pieces in hand
      # @raise [ArgumentError] If the input string is invalid
      def self.parse(pieces_in_hand_str)
        validate_pieces_in_hand_string(pieces_in_hand_str)

        # Handle the special case of no pieces in hand
        return [] if pieces_in_hand_str == NO_PIECES

        pieces = []
        i = 0

        while i < pieces_in_hand_str.length
          # Vérifier que le caractère est une lettre
          raise ArgumentError, format(ERRORS[:invalid_identifier], i) unless pieces_in_hand_str[i].match?(/[a-zA-Z]/)

          pieces << { id: pieces_in_hand_str[i] }
          i += 1

        end

        # Vérifier que les pièces sont triées par ordre lexicographique
        raise ArgumentError, "Pieces in hand must be in ASCII lexicographic order" unless pieces_sorted?(pieces)

        pieces
      end

      # Validates the pieces in hand string for syntax
      #
      # @param str [String] FEEN pieces in hand string
      # @raise [ArgumentError] If the string is invalid
      # @return [void]
      def self.validate_pieces_in_hand_string(str)
        raise ArgumentError, format(ERRORS[:invalid_type], str.class) unless str.is_a?(String)

        raise ArgumentError, ERRORS[:empty_string] if str.empty?

        # Check for the special case of no pieces in hand
        return if str == NO_PIECES

        # Check for valid characters (only letters)
        valid_chars = /\A[a-zA-Z]+\z/
        return if str.match?(valid_chars)

        invalid_chars = str.scan(/[^a-zA-Z]/).uniq.join(", ")
        raise ArgumentError, format(ERRORS[:invalid_chars], invalid_chars)
      end

      # Checks if pieces are sorted in ASCII lexicographic order
      #
      # @param pieces [Array<Hash>] Array of piece hashes
      # @return [Boolean] True if pieces are sorted
      def self.pieces_sorted?(pieces)
        piece_ids = pieces.map { |piece| piece[:id] }
        piece_ids == piece_ids.sort
      end
    end
  end
end
