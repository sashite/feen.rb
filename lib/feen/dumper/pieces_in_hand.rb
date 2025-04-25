# frozen_string_literal: true

module Feen
  module Dumper
    # Handles conversion of pieces in hand data structure to FEEN notation string
    module PiecesInHand
      EMPTY_RESULT = "-"
      ERRORS = {
        invalid_piece:      "Invalid piece at index %d: must be a Hash with an :id key",
        invalid_id:         "Invalid piece ID at index %d: must be a single alphabetic character",
        prefix_not_allowed: "Prefix is not allowed for pieces in hand at index %d",
        suffix_not_allowed: "Suffix is not allowed for pieces in hand at index %d"
      }.freeze

      # Converts the internal pieces in hand representation to a FEEN string
      #
      # @param pieces_in_hand [Array<Hash>] Array of piece hashes
      # @return [String] FEEN-formatted pieces in hand string
      def self.dump(pieces_in_hand)
        # If no pieces in hand, return a single hyphen
        return EMPTY_RESULT if pieces_in_hand.nil? || pieces_in_hand.empty?

        # Validate all pieces have the required structure
        validate_pieces(pieces_in_hand)

        # Sort pieces in ASCII lexicographic order by their ID
        pieces_in_hand
          .sort_by { |piece| piece[:id] }
          .map { |piece| piece[:id] }
          .join
      end

      # Validates the structure of each piece in the array
      #
      # @param pieces [Array<Hash>] Array of piece hashes to validate
      # @raise [ArgumentError] If any piece has an invalid structure
      # @return [void]
      def self.validate_pieces(pieces)
        pieces.each_with_index do |piece, index|
          # Check basic piece structure
          raise ArgumentError, format(ERRORS[:invalid_piece], index) unless piece.is_a?(Hash) && piece.key?(:id)

          # Validate piece ID
          unless piece[:id].is_a?(String) && piece[:id].match?(/\A[a-zA-Z]\z/)
            raise ArgumentError, format(ERRORS[:invalid_id], index)
          end

          # Ensure no prefix or suffix is present
          raise ArgumentError, format(ERRORS[:prefix_not_allowed], index) if piece.key?(:prefix) && !piece[:prefix].nil?

          raise ArgumentError, format(ERRORS[:suffix_not_allowed], index) if piece.key?(:suffix) && !piece[:suffix].nil?
        end
      end
    end
  end
end
