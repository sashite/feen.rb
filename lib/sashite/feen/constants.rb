# frozen_string_literal: true

module Sashite
  module Feen
    # Constants for FEEN (Field Expression Encoding Notation).
    #
    # These constants define implementation constraints that enable
    # bounded memory usage and safe parsing while remaining sufficient
    # for all realistic board game positions.
    #
    # @see https://sashite.dev/specs/feen/1.0.0/
    # @api public
    module Constants
      # Maximum allowed length for a FEEN string in bytes.
      # Sufficient for any realistic board position.
      MAX_STRING_LENGTH = 4_096

      # Maximum number of board dimensions supported.
      # Covers 1D, 2D, and 3D boards.
      MAX_DIMENSIONS = 3

      # Maximum size of any single dimension.
      # Fits in an 8-bit integer; covers up to 256×256×256 boards.
      MAX_DIMENSION_SIZE = 255

      # Field separator character (ASCII space).
      # Separates the three FEEN fields: piece-placement, hands, style-turn.
      FIELD_SEPARATOR = " "

      # Segment separator character (ASCII forward slash).
      # Used within piece-placement (ranks/layers) and hands (first/second).
      SEGMENT_SEPARATOR = "/"
    end
  end
end
