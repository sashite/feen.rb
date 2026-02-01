# frozen_string_literal: true

require "sashite/epin"
require "sashite/sin"

require_relative "feen/error"
require_relative "feen/errors/parse_error"
require_relative "feen/errors/piece_placement_error"
require_relative "feen/errors/hands_error"
require_relative "feen/errors/style_turn_error"
require_relative "feen/errors/cardinality_error"
require_relative "feen/parser"
require_relative "feen/dumper"
require_relative "feen/position"

module Sashite
  # FEEN (Field Expression Encoding Notation) implementation for Ruby.
  #
  # FEEN is a rule-agnostic format for encoding board game positions
  # with three space-separated fields:
  #
  # - Piece Placement: Board structure and occupancy
  # - Hands: Off-board pieces held by each player
  # - Style-Turn: Player styles and active player
  #
  # == Format
  #
  #   <PIECE-PLACEMENT> <HANDS> <STYLE-TURN>
  #
  # == Examples
  #
  #   # Parse a FEEN string
  #   position = Sashite::Feen.parse("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s")
  #   position.piece_placement  # => PiecePlacement object
  #   position.hands            # => Hands object
  #   position.style_turn       # => StyleTurn object
  #
  #   # Serialize back to FEEN
  #   position.to_s  # => "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s"
  #
  #   # Validate a FEEN string
  #   Sashite::Feen.valid?("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s")  # => true
  #   Sashite::Feen.valid?("invalid")  # => false
  #
  #   # Dump structured data to FEEN string
  #   Sashite::Feen.dump(
  #     piece_placement: { segments: [[8], [8], ...], separators: ["/", ...] },
  #     hands: { first: [], second: [] },
  #     style_turn: { active: "C", inactive: "c" }
  #   )
  #   # => "8/8/8/8/8/8/8/8 / C/c"
  #
  # @see https://sashite.dev/specs/feen/1.0.0/
  # @api public
  module Feen
    # Parses a FEEN string into a Position.
    #
    # @api public
    # @param feen_string [String] The FEEN string to parse
    # @return [Position] A new Position instance
    # @raise [ParseError] If the string is not a valid FEEN
    #
    # @example Parsing a Chess position
    #   position = Sashite::Feen.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c")
    #   position.squares_count  # => 64
    #   position.pieces_count   # => 32
    #
    # @example Parsing a Shogi position
    #   position = Sashite::Feen.parse("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s")
    #   position.piece_placement.dimensions  # => 2
    #
    # @example Invalid input raises ParseError
    #   Sashite::Feen.parse("invalid")  # => raises ParseError
    def self.parse(feen_string)
      components = Parser.parse(feen_string)
      Position.send(:new, **components)
    end

    # Reports whether a string is a valid FEEN position.
    #
    # @api public
    # @param feen_string [String] The string to validate
    # @return [Boolean] true if valid, false otherwise
    #
    # @example Valid positions
    #   Sashite::Feen.valid?("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c")  # => true
    #   Sashite::Feen.valid?("8/8/8/8/8/8/8/8 / C/c")  # => true (empty board)
    #   Sashite::Feen.valid?("k^+p4+PK^ / C/c")        # => true (1D board)
    #
    # @example Invalid positions
    #   Sashite::Feen.valid?("invalid")        # => false
    #   Sashite::Feen.valid?("rkr//PPPP / G/g")  # => false (dimensional coherence)
    #   Sashite::Feen.valid?(nil)              # => false
    #   Sashite::Feen.valid?(123)              # => false
    def self.valid?(feen_string)
      Parser.valid?(feen_string)
    end

    # Serializes structured position data to a FEEN string.
    #
    # @api public
    # @param piece_placement [Hash] Piece placement with :segments and :separators
    # @param hands [Hash] Hands with :first and :second
    # @param style_turn [Hash] Style-turn with :active and :inactive
    # @return [String] Canonical FEEN string
    #
    # @example Dumping an empty Chess board
    #   Sashite::Feen.dump(
    #     piece_placement: {
    #       segments: [[8], [8], [8], [8], [8], [8], [8], [8]],
    #       separators: ["/", "/", "/", "/", "/", "/", "/"]
    #     },
    #     hands: { first: [], second: [] },
    #     style_turn: { active: "C", inactive: "c" }
    #   )
    #   # => "8/8/8/8/8/8/8/8 / C/c"
    #
    # @example Dumping a position with hands
    #   Sashite::Feen.dump(
    #     piece_placement: { segments: [["K", 6, "k"]], separators: [] },
    #     hands: {
    #       first: [{ piece: "P", count: 2 }],
    #       second: [{ piece: "p", count: 1 }]
    #     },
    #     style_turn: { active: "S", inactive: "s" }
    #   )
    #   # => "K6k 2P/p S/s"
    def self.dump(piece_placement:, hands:, style_turn:)
      Dumper.dump(
        piece_placement: piece_placement,
        hands:           hands,
        style_turn:      style_turn
      )
    end
  end
end
