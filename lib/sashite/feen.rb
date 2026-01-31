# frozen_string_literal: true

require "sashite/epin"
require "sashite/sin"

require_relative "feen/constants"
require_relative "feen/errors"
require_relative "feen/parser"
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
  # @see https://sashite.dev/specs/feen/1.0.0/
  # @api public
  module Feen
    # Parses a FEEN string into a Position.
    #
    # @api public
    # @param feen_string [String] The FEEN string to parse
    # @return [Position] A new Position instance
    # @raise [ArgumentError] If the string is not a valid FEEN
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
    # @example Invalid input raises ArgumentError
    #   Sashite::Feen.parse("invalid")  # => raises ArgumentError
    def self.parse(feen_string)
      components = Parser.parse(feen_string)
      Position.new(**components)
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
  end
end
