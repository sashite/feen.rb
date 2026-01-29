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
  # - Piece Placement: Board occupancy
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
  #   position = Sashite::Feen.parse("lnsgk^gsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGK^GSNL / S/s")
  #   position.piece_placement  # => PiecePlacement object
  #   position.hands            # => Hands object
  #   position.style_turn       # => StyleTurn object
  #
  #   # Serialize back to FEEN
  #   position.to_s  # => "lnsgk^gsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGK^GSNL / S/s"
  #
  #   # Validate a FEEN string
  #   Sashite::Feen.valid?("lnsgk^gsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGK^GSNL / S/s")  # => true
  #   Sashite::Feen.valid?("invalid")  # => false
  #
  # @see https://sashite.dev/specs/feen/1.0.0/
  module Feen
    # Parses a FEEN string into a Position.
    #
    # @param string [String] The FEEN string to parse
    # @return [Position] A new Position instance
    # @raise [Errors::Argument] If the string is not a valid FEEN
    #
    # @example
    #   Sashite::Feen.parse("lnsgk^gsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGK^GSNL / S/s")
    #   # => #<Sashite::Feen::Position lnsgk^gsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGK^GSNL / S/s>
    #
    #   Sashite::Feen.parse("invalid")
    #   # => raises Errors::Argument
    def self.parse(string)
      components = Parser.parse(string)
      Position.new(**components)
    end

    # Checks if a string is a valid FEEN notation.
    #
    # @param string [String] The string to validate
    # @return [Boolean] true if valid, false otherwise
    #
    # @example
    #   Sashite::Feen.valid?("lnsgk^gsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGK^GSNL / S/s")  # => true
    #   Sashite::Feen.valid?("k^+p4+PK^ / C/c")  # => true
    #   Sashite::Feen.valid?("invalid")  # => false
    def self.valid?(string)
      Parser.valid?(string)
    end
  end
end
