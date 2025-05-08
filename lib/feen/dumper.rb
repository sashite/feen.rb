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
    #     piece_placement: [
    #       ["r", "n", "b", "q", "k=", "b", "n", "r"],
    #       ["p", "p", "p", "p", "p", "p", "p", "p"],
    #       ["", "", "", "", "", "", "", ""],
    #       ["", "", "", "", "", "", "", ""],
    #       ["", "", "", "", "", "", "", ""],
    #       ["", "", "", "", "", "", "", ""],
    #       ["P", "P", "P", "P", "P", "P", "P", "P"],
    #       ["R", "N", "B", "Q", "K=", "B", "N", "R"]
    #     ],
    #     games_turn: ["CHESS", "chess"],
    #     pieces_in_hand: []
    #   )
    #   # => "rnbqk=bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK=BNR CHESS/chess -"
    #
    # @param piece_placement [Array] Board position data structure representing the spatial
    #                                distribution of pieces across the board, where each cell
    #                                is represented by a String (or empty string for empty cells)
    # @param games_turn [Array<String>] A two-element array where the first element is the
    #                                  active player's variant and the second is the inactive player's variant
    # @param pieces_in_hand [Array<String>] Pieces available for dropping onto the board,
    #                                    each represented as a single character string
    # @return [String] Complete FEEN string representation compliant with the specification
    # @see https://sashite.dev/documents/feen/1.0.0/ FEEN Specification v1.0.0
    def self.dump(piece_placement:, games_turn:, pieces_in_hand:)
      [
        PiecePlacement.dump(piece_placement),
        GamesTurn.dump(*games_turn),
        PiecesInHand.dump(*pieces_in_hand)
      ].join(FIELD_SEPARATOR)
    end
  end
end
