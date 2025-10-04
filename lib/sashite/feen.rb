# frozen_string_literal: true

require_relative "feen/dumper"
require_relative "feen/parser"

module Sashite
  # FEEN (Forsyth–Edwards Enhanced Notation) module provides parsing and dumping
  # functionality for board game positions.
  #
  # FEEN is a universal, rule-agnostic notation for representing board game positions.
  # It extends traditional FEN to support multiple game systems, cross-style games,
  # multi-dimensional boards, and captured pieces.
  #
  # A FEEN string consists of three space-separated fields:
  # 1. Piece placement: Board configuration using EPIN notation
  # 2. Pieces in hand: Captured pieces held by each player
  # 3. Style-turn: Game styles and active player
  #
  # @see https://sashite.dev/specs/feen/1.0.0/
  module Feen
    # Dump a Position object into its canonical FEEN string representation.
    #
    # Generates a deterministic FEEN string from a position object. The same
    # position will always produce the same canonical string, ensuring
    # position equality can be tested via string comparison.
    #
    # @param position [Position] A position object with placement, hands, and styles
    # @return [String] Canonical FEEN notation string
    #
    # @example Dump a position to FEEN
    #   feen_string = Sashite::Feen.dump(position)
    #   # => "+rnbq+kbn+r/+p+p+p+p+p+p+p+p/8/8/8/8/+P+P+P+P+P+P+P+P/+RNBQ+KBN+R / C/c"
    #
    # @example Round-trip parsing and dumping
    #   original = "+rnbq+kbn+r/+p+p+p+p+p+p+p+p/8/8/8/8/+P+P+P+P+P+P+P+P/+RNBQ+KBN+R / C/c"
    #   position = Sashite::Feen.parse(original)
    #   Sashite::Feen.dump(position) == original  # => true
    def self.dump(position)
      Dumper.dump(position)
    end

    # Parse a FEEN string into an immutable Position object.
    #
    # This method parses the three FEEN fields and constructs an immutable position
    # object with placement, hands, and styles components.
    #
    # @param string [String] A FEEN notation string with three space-separated fields
    # @return [Position] Immutable position object
    # @raise [Error::Syntax] If the FEEN structure is malformed
    # @raise [Error::Piece] If EPIN notation is invalid
    # @raise [Error::Style] If SIN notation is invalid
    # @raise [Error::Count] If piece counts are invalid
    # @raise [Error::Validation] For other semantic violations
    #
    # @example Parse a chess starting position
    #   position = Sashite::Feen.parse("+rnbq+kbn+r/+p+p+p+p+p+p+p+p/8/8/8/8/+P+P+P+P+P+P+P+P/+RNBQ+KBN+R / C/c")
    #   position.placement  # => Placement object (board configuration)
    #   position.hands      # => Hands object (pieces in hand)
    #   position.styles     # => Styles object (style-turn information)
    #
    # @example Parse a shogi position with captured pieces
    #   position = Sashite::Feen.parse("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL P/p S/s")
    def self.parse(string)
      Parser.parse(string)
    end
  end
end
