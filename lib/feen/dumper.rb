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
    # @param pieces_in_hand [Array<Hash>] Pieces available for dropping onto the board,
    #                                    each represented as a Hash with at least an :id key
    # @return [String] Complete FEEN string representation compliant with the specification
    # @see https://sashite.dev/documents/feen/1.0.0/ FEEN Specification v1.0.0
    def self.dump(piece_placement:, active_variant:, inactive_variant:, pieces_in_hand:)
      [
        PiecePlacement.dump(piece_placement),
        GamesTurn.dump(active_variant, inactive_variant),
        PiecesInHand.dump(pieces_in_hand)
      ].join(FIELD_SEPARATOR)
    end
  end
end
