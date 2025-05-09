# frozen_string_literal: true

require_relative File.join("parser", "games_turn")
require_relative File.join("parser", "piece_placement")
require_relative File.join("parser", "pieces_in_hand")

module Feen
  # Module responsible for parsing FEEN notation strings into internal data structures.
  # FEEN (Format for Encounter & Entertainment Notation) is a compact, canonical, and rule-agnostic
  # textual format for representing static board positions in two-player piece-placement games.
  module Parser
    # Regular expression pattern for matching a valid FEEN string structure
    # Captures exactly three non-space components separated by single spaces
    FEEN_PATTERN = /\A([^\s]+)\s([^\s]+)\s([^\s]+)\z/

    # Error message for invalid FEEN format
    INVALID_FORMAT_ERROR = "Invalid FEEN format: expected exactly 3 fields separated by single spaces"

    # Parses a complete FEEN string into a structured representation
    #
    # @param feen_string [String] Complete FEEN notation string
    # @return [Hash] Hash containing the parsed position data with the following keys:
    #   - :piece_placement [Array] - Hierarchical array structure representing the board
    #   - :pieces_in_hand [Array<String>] - Pieces available for dropping onto the board
    #   - :games_turn [Array<String>] - A two-element array with [active_variant, inactive_variant]
    # @raise [ArgumentError] If the FEEN string is invalid or any component cannot be parsed
    #
    # @example Parsing a standard chess initial position
    #   feen = "rnbqk=bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK=BNR - CHESS/chess"
    #   result = Feen::Parser.parse(feen)
    #   # => {
    #   #      piece_placement: [
    #   #        ["r", "n", "b", "q", "k=", "b", "n", "r"],
    #   #        ["p", "p", "p", "p", "p", "p", "p", "p"],
    #   #        ["", "", "", "", "", "", "", ""],
    #   #        ["", "", "", "", "", "", "", ""],
    #   #        ["", "", "", "", "", "", "", ""],
    #   #        ["", "", "", "", "", "", "", ""],
    #   #        ["P", "P", "P", "P", "P", "P", "P", "P"],
    #   #        ["R", "N", "B", "Q", "K=", "B", "N", "R"]
    #   #      ],
    #   #      pieces_in_hand: [],
    #   #      games_turn: ["CHESS", "chess"]
    #   #    }
    #
    # @example Parsing a shogi position (from a Tempo Loss Bishop Exchange opening) with pieces in hand
    #   feen = "lnsgk2nl/1r4gs1/p1pppp1pp/1p4p2/7P1/2P6/PP1PPPP1P/1SG4R1/LN2KGSNL Bb SHOGI/shogi"
    #   result = Feen::Parser.parse(feen)
    #   # => {
    #   #      piece_placement: [
    #   #        ["l", "n", "s", "g", "k", "", "", "n", "l"],
    #   #        ["", "r", "", "", "", "", "g", "s", ""],
    #   #        ["p", "", "p", "p", "p", "p", "", "p", "p"],
    #   #        ["", "p", "", "", "", "", "p", "", ""],
    #   #        ["", "", "", "", "", "", "", "P", ""],
    #   #        ["", "", "P", "", "", "", "", "", ""],
    #   #        ["P", "P", "", "P", "P", "P", "P", "", "P"],
    #   #        ["", "S", "G", "", "", "", "", "R", ""],
    #   #        ["L", "N", "", "", "K", "G", "S", "N", "L"]
    #   #      ],
    #   #      pieces_in_hand: ["B", "b"],
    #   #      games_turn: ["SHOGI", "shogi"]
    #   #    }
    def self.parse(feen_string)
      feen_string = String(feen_string)

      # Match the FEEN string against the expected pattern
      match = FEEN_PATTERN.match(feen_string)

      # Raise an error if the format doesn't match the expected pattern
      raise ::ArgumentError, INVALID_FORMAT_ERROR unless match

      # Capture the three distinct parts
      piece_placement_string, pieces_in_hand_string, games_turn_string = match.captures

      # Parse each field using the appropriate submodule
      piece_placement = PiecePlacement.parse(piece_placement_string)
      pieces_in_hand = PiecesInHand.parse(pieces_in_hand_string)
      games_turn = GamesTurn.parse(games_turn_string)

      # Create a structured representation of the position
      {
        piece_placement:,
        pieces_in_hand:,
        games_turn:
      }
    end
  end
end
