# frozen_string_literal: true

module Sashite
  module Feen
    module Errors
      class Argument < ::ArgumentError
        # Centralized error messages for FEEN parsing and validation.
        #
        # These messages are grouped by the FEEN field they relate to.
        # EPIN-related errors (invalid piece tokens) and SIN-related errors
        # (invalid style tokens) are propagated from their respective dependencies.
        #
        # @see https://sashite.dev/specs/feen/1.0.0/
        # @api private
        module Messages
          # =================================================================
          # General input errors
          # =================================================================

          # Input string exceeds maximum allowed length.
          INPUT_TOO_LONG = "input exceeds 4096 characters"

          # Input does not contain exactly 3 space-separated fields.
          INVALID_FIELD_COUNT = "invalid field count"

          # =================================================================
          # Piece Placement errors (Field 1)
          # =================================================================

          # Field 1 is an empty string.
          PIECE_PLACEMENT_EMPTY = "piece placement is empty"

          # Field 1 begins with a separator character.
          PIECE_PLACEMENT_STARTS_WITH_SEPARATOR = "piece placement starts with separator"

          # Field 1 ends with a separator character.
          PIECE_PLACEMENT_ENDS_WITH_SEPARATOR = "piece placement ends with separator"

          # A segment between separators contains no tokens.
          EMPTY_SEGMENT = "empty segment"

          # Empty count is zero or has leading zeros.
          INVALID_EMPTY_COUNT = "invalid empty count"

          # Token is not a valid EPIN identifier.
          INVALID_PIECE_TOKEN = "invalid piece token"

          # Adjacent empty counts should be merged into one.
          CONSECUTIVE_EMPTY_COUNTS = "consecutive empty counts must be merged"

          # Separator of length N found without N-1 separators in segments.
          DIMENSIONAL_COHERENCE_VIOLATION = "dimensional coherence violation"

          # Board has more than 3 dimensions.
          EXCEEDS_MAX_DIMENSIONS = "exceeds 3 dimensions"

          # A rank or layer exceeds 255 squares.
          DIMENSION_SIZE_EXCEEDED = "dimension size exceeds 255"

          # =================================================================
          # Hands errors (Field 2)
          # =================================================================

          # Field 2 missing "/" or contains multiple "/".
          INVALID_HANDS_DELIMITER = "invalid hands delimiter"

          # Multiplicity is 0, 1, or has leading zeros.
          INVALID_HAND_COUNT = "invalid hand count"

          # Identical EPIN tokens not combined.
          HAND_ITEMS_NOT_AGGREGATED = "hand items not aggregated"

          # Items violate canonical ordering rules.
          HAND_ITEMS_NOT_CANONICAL = "hand items not in canonical order"

          # =================================================================
          # Style-Turn errors (Field 3)
          # =================================================================

          # Field 3 missing "/" or contains multiple "/".
          INVALID_STYLE_TURN_DELIMITER = "invalid style-turn delimiter"

          # Token is not a valid SIN identifier.
          INVALID_STYLE_TOKEN = "invalid style token"

          # Both tokens uppercase or both lowercase.
          STYLE_TOKENS_SAME_CASE = "style tokens must have opposite case"

          # =================================================================
          # Cross-field validation errors
          # =================================================================

          # Total pieces (board + hands) exceeds total squares.
          TOO_MANY_PIECES = "too many pieces for board size"
        end
      end
    end
  end
end
