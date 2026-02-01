# frozen_string_literal: true

require_relative "parse_error"

module Sashite
  module Feen
    # Error raised when Piece Placement field (Field 1) parsing fails.
    #
    # The Piece Placement field encodes board structure and occupancy.
    # This error covers syntax errors, canonicalization violations,
    # and dimensional coherence failures.
    #
    # @example Catching piece placement errors
    #   begin
    #     Sashite::Feen.parse("/K / C/c")
    #   rescue Sashite::Feen::PiecePlacementError => e
    #     puts "Piece placement error: #{e.message}"
    #   end
    #
    # @see https://sashite.dev/specs/feen/1.0.0/
    # @api public
    class PiecePlacementError < ParseError
      # Field 1 is an empty string.
      EMPTY = "piece placement is empty"

      # Field 1 begins with a separator character.
      STARTS_WITH_SEPARATOR = "piece placement starts with separator"

      # Field 1 ends with a separator character.
      ENDS_WITH_SEPARATOR = "piece placement ends with separator"

      # A segment between separators contains no tokens.
      EMPTY_SEGMENT = "empty segment"

      # Empty count is zero or has leading zeros.
      INVALID_EMPTY_COUNT = "invalid empty count"

      # Token is not a valid EPIN identifier.
      INVALID_PIECE_TOKEN = "invalid piece token"

      # Adjacent empty counts should be merged into one.
      CONSECUTIVE_EMPTY_COUNTS = "consecutive empty counts must be merged"

      # Separator of length N found without N-1 separators in segments.
      DIMENSIONAL_COHERENCE = "dimensional coherence violation"

      # Board has more than 3 dimensions.
      EXCEEDS_MAX_DIMENSIONS = "exceeds maximum dimensions"

      # A rank or layer exceeds 255 squares.
      DIMENSION_SIZE_EXCEEDED = "dimension size exceeded"

      freeze
    end
  end
end
