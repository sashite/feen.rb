# frozen_string_literal: true

require "qi"
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

module Sashite
  # FEEN (Field Expression Encoding Notation) implementation for Ruby.
  #
  # Provides serialization and deserialization of board game positions
  # between FEEN strings and Qi::Position objects.
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
  #   # Parse a FEEN string into a Qi::Position
  #   position = Sashite::Feen.parse("lnsgk^gsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGK^GSNL / S/s")
  #   position.board   # => [["l","n","s","g","k^","g","s","n","l"], ...]
  #   position.hands   # => { first: [], second: [] }
  #   position.styles  # => { first: "S", second: "s" }
  #   position.turn    # => :first
  #
  #   # Serialize a Qi::Position to a FEEN string
  #   Sashite::Feen.dump(position)
  #   # => "lnsgk^gsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGK^GSNL / S/s"
  #
  #   # Validate a FEEN string
  #   Sashite::Feen.valid?("lnsgk^gsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGK^GSNL / S/s")  # => true
  #   Sashite::Feen.valid?("invalid")  # => false
  #
  # @see https://sashite.dev/specs/feen/1.0.0/
  # @api public
  module Feen
    # Parses a FEEN string into a Qi::Position.
    #
    # Pieces on the board are EPIN token strings; empty squares are nil.
    # Hands are flat arrays of EPIN token strings.
    # Styles are SIN token strings.
    #
    # @api public
    # @param feen_string [String] The FEEN string to parse
    # @return [Qi::Position] An immutable position object
    # @raise [ParseError] If the string is not a valid FEEN
    #
    # @example Parsing a Chess position
    #   position = Sashite::Feen.parse("-rnbqk^bn-r/+p+p+p+p+p+p+p+p/8/8/8/8/+P+P+P+P+P+P+P+P/-RNBQK^BN-R / C/c")
    #   position.board[0]  # => ["-r", "n", "b", "q", "k^", "b", "n", "-r"]
    #   position.turn      # => :first
    #
    # @example Parsing a Shogi position
    #   position = Sashite::Feen.parse("lnsgk^gsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGK^GSNL / S/s")
    #   position.styles  # => { first: "S", second: "s" }
    #
    # @example Invalid input raises ParseError
    #   Sashite::Feen.parse("invalid")  # => raises ParseError
    def self.parse(feen_string)
      Parser.parse(feen_string)
    end

    # Reports whether a string is a valid FEEN position.
    #
    # @api public
    # @param feen_string [String] The string to validate
    # @return [Boolean] true if valid, false otherwise
    #
    # @example Valid positions
    #   Sashite::Feen.valid?("-rnbqk^bn-r/+p+p+p+p+p+p+p+p/8/8/8/8/+P+P+P+P+P+P+P+P/-RNBQK^BN-R / C/c")  # => true
    #   Sashite::Feen.valid?("8/8/8/8/8/8/8/8 / C/c")  # => true (empty board)
    #   Sashite::Feen.valid?("k^+p4+PK^ / C/c")        # => true (1D board)
    #
    # @example Invalid positions
    #   Sashite::Feen.valid?("invalid")          # => false
    #   Sashite::Feen.valid?("rkr//PPPP / G/g")  # => false (dimensional coherence)
    #   Sashite::Feen.valid?(nil)                # => false
    def self.valid?(feen_string)
      Parser.valid?(feen_string)
    end

    # Serializes a Qi::Position to a canonical FEEN string.
    #
    # Board pieces must be valid EPIN token strings (or nil for empty squares).
    # Style values must be valid SIN token strings.
    #
    # @api public
    # @param position [Qi::Position] The position to serialize
    # @return [String] Canonical FEEN string
    #
    # @example Round-trip serialization
    #   position = Sashite::Feen.parse("8/8/8/8/8/8/8/8 / C/c")
    #   Sashite::Feen.dump(position)  # => "8/8/8/8/8/8/8/8 / C/c"
    #
    # @example Dumping a manually built position
    #   position = Qi.new(
    #     [["K^", nil, nil, nil, nil, nil, nil, "k^"]],
    #     { first: [], second: [] },
    #     { first: "C", second: "c" },
    #     :first
    #   )
    #   Sashite::Feen.dump(position)  # => "K^6k^ / C/c"
    def self.dump(position)
      Dumper.dump(position)
    end
  end
end
