# frozen_string_literal: true

require_relative File.join("..", "piece")
require_relative File.join("pieces_in_hand", "no_pieces")
require_relative File.join("pieces_in_hand", "errors")

module Feen
  module Dumper
    # Handles conversion of pieces in hand data to FEEN notation string
    module PiecesInHand
      # Converts an array of Piece instances to a FEEN-formatted pieces in hand string
      #
      # @param pieces [Array<Piece>] Array of Piece instances
      # @return [String] FEEN-formatted pieces in hand string
      # @raise [ArgumentError] If any piece is invalid
      # @example
      #   piece1 = Feen::Piece.new("P")
      #   piece2 = Feen::Piece.new("p")
      #   piece3 = Feen::Piece.new("B")
      #   PiecesInHand.dump(piece1, piece2, piece3)
      #   # => "BPp"
      #
      #   PiecesInHand.dump
      #   # => "-"
      def self.dump(*pieces)
        # If no pieces in hand, return the standardized empty indicator
        return NoPieces if pieces.empty?

        # Validate each piece according to the FEEN specification
        validate_pieces(pieces)

        # Get the basic identifiers (without prefixes or suffixes)
        piece_identifiers = pieces.map(&:identifier)

        # Sort pieces in ASCII lexicographic order and join them
        piece_identifiers.sort.join
      end

      # Validates all pieces according to the FEEN specification
      #
      # @param pieces [Array<Object>] Array of piece candidates
      # @raise [ArgumentError] If any piece is invalid
      # @return [void]
      private_class_method def self.validate_pieces(pieces)
        return if pieces.all? { |piece| piece.is_a?(Feen::Piece) }

        raise ::ArgumentError, "All pieces must be instances of Feen::Piece"
      end
    end
  end
end
