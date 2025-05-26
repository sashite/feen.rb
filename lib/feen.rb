# frozen_string_literal: true

require_relative File.join("feen", "dumper")
require_relative File.join("feen", "parser")

# This module provides a Ruby interface for data serialization and
# deserialization in FEEN format.
#
# FEEN (Forsyth–Edwards Enhanced Notation) is a compact, canonical, and
# rule-agnostic textual format for representing static board positions
# in two-player piece-placement games.
#
# @see https://sashite.dev/documents/feen/1.0.0/
module Feen
  # Dumps position components into a FEEN string.
  #
  # @param piece_placement [Array] Board position data structure representing the spatial
  #                               distribution of pieces across the board
  # @param pieces_in_hand [Array<String>] Pieces available for dropping onto the board
  # @param games_turn [Array<String>] A two-element array where the first element is the
  #                                  active player's variant and the second is the inactive player's variant
  # @return [String] FEEN notation string
  # @raise [ArgumentError] If any parameter is invalid
  # @example
  #   piece_placement = [
  #     ["r", "n", "b", "q", "k", "b", "n", "r"],
  #     ["p", "p", "p", "p", "p", "p", "p", "p"],
  #     ["", "", "", "", "", "", "", ""],
  #     ["", "", "", "", "", "", "", ""],
  #     ["", "", "", "", "", "", "", ""],
  #     ["", "", "", "", "", "", "", ""],
  #     ["P", "P", "P", "P", "P", "P", "P", "P"],
  #     ["R", "N", "B", "Q", "K", "B", "N", "R"]
  #   ]
  #   Feen.dump(
  #     piece_placement: piece_placement,
  #     pieces_in_hand: [],
  #     games_turn: ["CHESS", "chess"]
  #   )
  #   # => "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR - CHESS/chess"
  def self.dump(piece_placement:, pieces_in_hand:, games_turn:)
    Dumper.dump(piece_placement:, pieces_in_hand:, games_turn:)
  end

  # Parses a FEEN string into position components.
  #
  # @param feen_string [String] Complete FEEN notation string
  # @return [Hash] Hash containing the parsed position data with the following keys:
  #   - :piece_placement [Array] - Hierarchical array structure representing the board
  #   - :pieces_in_hand [Array<String>] - Pieces available for dropping onto the board
  #   - :games_turn [Array<String>] - A two-element array with [active_variant, inactive_variant]
  # @raise [ArgumentError] If the FEEN string is invalid
  # @example
  #   feen_string = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR - CHESS/chess"
  #   Feen.parse(feen_string)
  #   # => {
  #   #      piece_placement: [
  #   #        ["r", "n", "b", "q", "k", "b", "n", "r"],
  #   #        ["p", "p", "p", "p", "p", "p", "p", "p"],
  #   #        ["", "", "", "", "", "", "", ""],
  #   #        ["", "", "", "", "", "", "", ""],
  #   #        ["", "", "", "", "", "", "", ""],
  #   #        ["", "", "", "", "", "", "", ""],
  #   #        ["P", "P", "P", "P", "P", "P", "P", "P"],
  #   #        ["R", "N", "B", "Q", "K", "B", "N", "R"]
  #   #      ],
  #   #      pieces_in_hand: [],
  #   #      games_turn: ["CHESS", "chess"]
  #   #    }
  def self.parse(feen_string)
    Parser.parse(feen_string)
  end

  # Safely parses a FEEN string into position components without raising exceptions.
  #
  # This method works like `parse` but returns nil instead of raising an exception
  # if the FEEN string is invalid.
  #
  # @param feen_string [String] Complete FEEN notation string
  # @return [Hash, nil] Hash containing the parsed position data or nil if parsing fails
  # @example
  #   # Valid FEEN string
  #   Feen.safe_parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR - CHESS/chess")
  #   # => {piece_placement: [...], pieces_in_hand: [...], games_turn: [...]}
  #
  #   # Invalid FEEN string
  #   Feen.safe_parse("invalid feen string")
  #   # => nil
  def self.safe_parse(feen_string)
    Parser.safe_parse(feen_string)
  end

  # Validates if the given string is a valid and canonical FEEN string
  #
  # This method performs a complete validation in two steps:
  # 1. Syntax check: Verifies the string can be parsed as FEEN
  # 2. Canonicity check: Ensures the string is in canonical form by comparing
  #    it with a freshly generated FEEN string created from its parsed components
  #
  # This approach guarantees that the string not only follows FEEN syntax
  # but is also in its most compact, canonical representation.
  #
  # @param feen_string [String] FEEN string to validate
  # @return [Boolean] True if the string is a valid and canonical FEEN string
  # @example
  #   # Canonical form
  #   Feen.valid?("lnsgk3l/5g3/p1ppB2pp/9/8B/2P6/P2PPPPPP/3K3R1/5rSNL 2g2s5PNln SHOGI/shogi") # => true
  #
  #   # Invalid syntax
  #   Feen.valid?("invalid feen string") # => false
  #
  #   # Valid syntax but non-canonical form (pieces in hand not in lexicographic order)
  #   Feen.valid?("lnsgk3l/5g3/p1ppB2pp/9/8B/2P6/P2PPPPPP/3K3R1/5rSNL N5P2gn2sl SHOGI/shogi") # => false
  def self.valid?(feen_string)
    # First check: Basic syntax validation
    begin
      parsed_data = parse(feen_string)
    rescue ::ArgumentError
      return false
    end

    # Second check: Canonicity validation through round-trip conversion
    # Generate a fresh FEEN string from the parsed data
    canonical_feen = dump(**parsed_data)

    # Compare the original string with the canonical form
    feen_string == canonical_feen
  end
end
