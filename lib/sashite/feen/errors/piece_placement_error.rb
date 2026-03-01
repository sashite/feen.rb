# frozen_string_literal: true

require_relative "parse_error"

module Sashite
  module Feen
    # Error raised when Piece Placement field (Field 1) parsing fails.
    #
    # @api public
    class PiecePlacementError < ParseError
      EMPTY                    = "piece placement is empty"
      STARTS_WITH_SEPARATOR    = "piece placement starts with separator"
      ENDS_WITH_SEPARATOR      = "piece placement ends with separator"
      EMPTY_SEGMENT            = "empty segment"
      INVALID_EMPTY_COUNT      = "invalid empty count"
      INVALID_PIECE_TOKEN      = "invalid piece token"
      CONSECUTIVE_EMPTY_COUNTS = "consecutive empty counts must be merged"
      DIMENSIONAL_COHERENCE    = "dimensional coherence violation"
      EXCEEDS_MAX_DIMENSIONS   = "exceeds maximum dimensions"
      DIMENSION_SIZE_EXCEEDED  = "dimension size exceeded"

      freeze
    end
  end
end
