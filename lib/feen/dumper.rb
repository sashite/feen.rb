# frozen_string_literal: true

require_relative File.join("dumper", "games_turn")
require_relative File.join("dumper", "piece_placement")
require_relative File.join("dumper", "pieces_in_hand")

module Feen
  # Module responsible for converting internal data structures to FEEN notation strings.
  # This implements the serialization part of the FEEN (Forsyth–Edwards Enhanced Notation) format.
  module Dumper
    # Field separator used between the three main components of FEEN notation
    FIELD_SEPARATOR = " "

    # Error messages for validation
    ERRORS = {
      invalid_piece_placement_type: "Piece placement must be an Array, got %s",
      invalid_games_turn_type:      "Games turn must be an Array with exactly two elements, got %s",
      invalid_pieces_in_hand_type:  "Pieces in hand must be an Array, got %s"
    }.freeze

    # Converts position components to a complete FEEN string.
    #
    # @example Creating a FEEN string for chess initial position
    #   Feen::Dumper.dump(
    #     piece_placement: [
    #       ["r", "n", "b", "q", "k", "b", "n", "r"],
    #       ["p", "p", "p", "p", "p", "p", "p", "p"],
    #       ["", "", "", "", "", "", "", ""],
    #       ["", "", "", "", "", "", "", ""],
    #       ["", "", "", "", "", "", "", ""],
    #       ["", "", "", "", "", "", "", ""],
    #       ["P", "P", "P", "P", "P", "P", "P", "P"],
    #       ["R", "N", "B", "Q", "K", "B", "N", "R"]
    #     ],
    #     pieces_in_hand: [],
    #     games_turn: ["CHESS", "chess"]
    #   )
    #   # => "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR - CHESS/chess"
    #
    # @param piece_placement [Array] Board position data structure representing the spatial
    #                                distribution of pieces across the board, where each cell
    #                                is represented by a String (or empty string for empty cells)
    # @param pieces_in_hand [Array<String>] Pieces available for dropping onto the board,
    #                                    each represented as a single character string
    # @param games_turn [Array<String>] A two-element array where the first element is the
    #                                  active player's variant and the second is the inactive player's variant
    # @return [String] Complete FEEN string representation compliant with the specification
    # @raise [ArgumentError] If any input parameter is invalid
    # @see https://sashite.dev/documents/feen/1.0.0/ FEEN Specification v1.0.0
    def self.dump(piece_placement:, pieces_in_hand:, games_turn:)
      # Validate input types
      validate_inputs(piece_placement, games_turn, pieces_in_hand)

      # Process each component with appropriate submodule and combine into final FEEN string
      [
        PiecePlacement.dump(piece_placement),
        PiecesInHand.dump(*pieces_in_hand),
        GamesTurn.dump(*games_turn)
      ].join(FIELD_SEPARATOR)
    end

    # Validates the input parameters for type and structure
    #
    # @param piece_placement [Object] Piece placement parameter to validate
    # @param games_turn [Object] Games turn parameter to validate
    # @param pieces_in_hand [Object] Pieces in hand parameter to validate
    # @raise [ArgumentError] If any parameter is invalid
    # @return [void]
    private_class_method def self.validate_inputs(piece_placement, games_turn, pieces_in_hand)
      # Validate piece_placement is an Array
      unless piece_placement.is_a?(Array)
        raise ArgumentError, format(ERRORS[:invalid_piece_placement_type], piece_placement.class)
      end

      # Validate games_turn is an Array with exactly 2 elements
      unless games_turn.is_a?(Array) && games_turn.size == 2
        raise ArgumentError, format(ERRORS[:invalid_games_turn_type], games_turn.inspect)
      end

      # Validate pieces_in_hand is an Array
      return if pieces_in_hand.is_a?(Array)

      raise ArgumentError, format(ERRORS[:invalid_pieces_in_hand_type], pieces_in_hand.class)
    end
  end
end
