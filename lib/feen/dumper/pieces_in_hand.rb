# frozen_string_literal: true

module Feen
  module Dumper
    # Handles conversion of pieces in hand data structure to FEEN notation string
    module PiecesInHand
      EMPTY_RESULT = "-"
      ERROR_MESSAGE = "Invalid piece at index %d: must be a single alphabetic character"

      # Converts the internal pieces in hand representation to a FEEN string
      #
      # @param pieces_in_hand [Array<String>] Array of piece identifiers
      # @return [String] FEEN-formatted pieces in hand string
      def self.dump(*pieces_in_hand)
        # If no pieces in hand, return a single hyphen
        return EMPTY_RESULT if pieces_in_hand.empty?

        # Validate all pieces have the required structure
        pieces_in_hand.each_with_index do |piece, index|
          raise ArgumentError, format(ERROR_MESSAGE, index) unless piece.is_a?(String) && piece.match?(/\A[a-zA-Z]\z/)
        end

        # Sort pieces in ASCII lexicographic order and join them
        pieces_in_hand.sort.join
      end
    end
  end
end
