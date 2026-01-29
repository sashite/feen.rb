# frozen_string_literal: true

module Sashite
  module Feen
    # Constants for FEEN (Field Expression Encoding Notation).
    #
    # FEEN encodes board positions using three space-separated fields:
    # Piece Placement, Hands, and Style-Turn.
    module Constants
      # Maximum allowed string length for a FEEN string.
      MAX_STRING_LENGTH = 4096

      # Maximum number of board dimensions supported.
      MAX_DIMENSIONS = 3

      # Maximum index value per dimension.
      MAX_INDEX_VALUE = 255

      # Field separator (ASCII space).
      FIELD_SEPARATOR = " "

      # Segment separator within Piece Placement and Hands fields.
      SEGMENT_SEPARATOR = "/"
    end
  end
end
