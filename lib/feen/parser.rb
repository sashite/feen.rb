# frozen_string_literal: true

require_relative File.join("parser", "games_turn")
require_relative File.join("parser", "piece_placement")
require_relative File.join("parser", "pieces_in_hand")

module Feen
  # Module responsible for parsing FEEN notation strings into internal data structures.
  # FEEN (Forsyth-Edwards Essential Notation) is a compact, canonical, and rule-agnostic
  # textual format for representing static board positions in two-player piece-placement games.
  module Parser
    # Field separator used between the three main components of FEEN notation
    FIELD_SEPARATOR = " "

    # Parses a complete FEEN string into a structured representation
    #
    # @param feen_string [String] Complete FEEN notation string
    # @return [Hash] Hash containing the parsed position data with the following keys:
    #   - :piece_placement [Array] - Hierarchical array structure representing the board
    #   - :active_variant [String] - Identifier for the player to move and their game variant
    #   - :inactive_variant [String] - Identifier for the opponent and their game variant
    #   - :pieces_in_hand [Array] - Pieces available for dropping onto the board
    # @raise [ArgumentError] If the FEEN string is invalid or any component cannot be parsed
    #
    # @example Parsing a standard chess initial position
    #   feen = "rnbqk=bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK=BNR CHESS/chess -"
    #   result = Feen::Parser.parse(feen)
    #   # => {
    #   #      piece_placement: [[{id: 'r'}, {id: 'n'}, ...], ...],
    #   #      active_variant: "CHESS",
    #   #      inactive_variant: "chess",
    #   #      pieces_in_hand: []
    #   #    }
    #
    # @example Parsing a shogi position (from a Tempo Loss Bishop Exchange opening) with pieces in hand
    #   feen = "lnsgk2nl/1r4gs1/p1pppp1pp/1p4p2/7P1/2P6/PP1PPPP1P/1SG4R1/LN2KGSNL SHOGI/shogi Bb"
    #   result = Feen::Parser.parse(feen)
    #   # => {
    #   #      piece_placement: [[{id: 'l'}, {id: 'n'}, ...], ...],
    #   #      active_variant: "SHOGI",
    #   #      inactive_variant: "shogi",
    #   #      pieces_in_hand: ['B', 'b']
    #   #    }
    def self.parse(feen_string)
      piece_placement_string, games_turn_string, pieces_in_hand_string = String(feen_string).split(FIELD_SEPARATOR)

      # Parse each field using the appropriate submodule
      piece_placement = PiecePlacement.parse(piece_placement_string)
      games_turn_data = GamesTurn.parse(games_turn_string)
      pieces_in_hand = PiecesInHand.parse(pieces_in_hand_string)

      {
        piece_placement:,
        active_variant:   games_turn_data.fetch(:active_player),
        inactive_variant: games_turn_data.fetch(:inactive_player),
        pieces_in_hand:
      }
    end
  end
end
