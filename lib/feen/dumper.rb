# frozen_string_literal: true

require_relative File.join("dumper", "games_turn")
require_relative File.join("dumper", "piece_placement")
require_relative File.join("dumper", "pieces_in_hand")

module Feen
  # Module responsible for converting internal data structures to FEEN notation strings.
  # This implements the serialization part of the FEEN (Format for Encounter & Entertainment Notation) format.
  module Dumper
    # Field separator used between the three main components of FEEN notation
    FIELD_SEPARATOR = " "

    # Converts position components to a complete FEEN string.
    #
    # @example Creating a FEEN string for chess initial position
    #   Feen::Dumper.dump(
    #     piece_placement: chess_board_array,
    #     active_variant: "CHESS",
    #     inactive_variant: "chess",
    #     pieces_in_hand: []
    #   )
    #   # => "rnbqk=bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK=BNR CHESS/chess -"
    #
    # @param piece_placement [Array] Board position data structure representing the spatial
    #                                distribution of pieces across the board
    # @param active_variant [String] Identifier for the player to move and their game variant
    # @param inactive_variant [String] Identifier for the opponent and their game variant
    # @param pieces_in_hand [Array<Piece, String>] Pieces available for dropping onto the board
    # @return [String] Complete FEEN string representation compliant with the specification
    # @see https://sashite.dev/documents/feen/1.0.0/ FEEN Specification v1.0.0
    def self.dump(piece_placement:, active_variant:, inactive_variant:, pieces_in_hand:)
      # Detect the shape of the board based on piece_placement structure
      shape = detect_board_shape(piece_placement)

      # Flatten the piece_placement into an array of Piece objects or nil
      contents = flatten_pieces(piece_placement)

      [
        PiecePlacement.dump(shape, contents),
        GamesTurn.dump(active_variant, inactive_variant),
        PiecesInHand.dump(*pieces_in_hand)
      ].join(FIELD_SEPARATOR)
    end

    # Detects the shape of the board based on the piece_placement structure
    #
    # @param piece_placement [Array] Hierarchical array structure representing the board
    # @return [Array<Integer>] Array of dimension sizes
    # @raise [ArgumentError] If the piece_placement structure is invalid
    # @api private
    private_class_method def self.detect_board_shape(piece_placement)
      dimensions = []
      current_level = piece_placement

      # Traverse the structure to determine shape
      while current_level.is_a?(Array) && !current_level.empty? && !leaf_level?(current_level)
        dimensions << current_level.size
        current_level = current_level.first
      end

      # Add the bottom dimension (rank size)
      dimensions << (current_level.is_a?(Array) ? current_level.size : 0)

      dimensions
    end

    # Checks if the current level is a leaf level (array of pieces/nil)
    #
    # @param level [Array] Current level of the hierarchy
    # @return [Boolean] True if this is a leaf level
    # @api private
    private_class_method def self.leaf_level?(level)
      level.first.nil? || level.first.is_a?(Feen::Piece) ||
      (level.first.is_a?(Hash) && level.first.key?(:id))
    end

    # Flattens the hierarchical piece_placement structure into a 1D array
    #
    # @param piece_placement [Array] Hierarchical array structure representing the board
    # @return [Array<Piece, nil>] Flattened array of pieces or nil values
    # @api private
    private_class_method def self.flatten_pieces(piece_placement)
      flat_array = []

      # Handle special cases
      return [] if piece_placement.nil? || piece_placement.empty?
      return piece_placement if leaf_level?(piece_placement)

      # Process hierarchical structure
      flatten_recursive(piece_placement, flat_array)

      # Convert Hash pieces to Piece objects if needed
      flat_array.map do |item|
        if item.is_a?(Hash) && item.key?(:id)
          Feen::Piece.new(
            item[:id],
            prefix: item[:prefix],
            suffix: item[:suffix]
          )
        else
          item
        end
      end
    end

    # Recursively flattens the hierarchical structure
    #
    # @param structure [Array] Current structure level
    # @param result [Array] Accumulator for flattened results
    # @return [void] Modifies result in place
    # @api private
    private_class_method def self.flatten_recursive(structure, result)
      if structure.is_a?(Array)
        if leaf_level?(structure)
          result.concat(structure)
        else
          structure.each { |sub| flatten_recursive(sub, result) }
        end
      else
        result << structure
      end
    end
  end
end
