# frozen_string_literal: true

module Sashite
  module Feen
    module Errors
      class Argument < ::ArgumentError
        # Centralized error messages for FEEN parsing and validation.
        #
        # EPIN-related errors (invalid piece tokens) and SIN-related errors
        # (invalid style tokens) are propagated from their respective dependencies.
        #
        # @example
        #   raise Errors::Argument, Messages::EMPTY_INPUT
        module Messages
          # =================================================================
          # General input errors
          # =================================================================

          EMPTY_INPUT = "empty input"
          INPUT_TOO_LONG = "input too long"
          INVALID_FIELD_COUNT = "invalid field count"

          # =================================================================
          # Piece Placement errors (Field 1)
          # =================================================================

          PIECE_PLACEMENT_STARTS_WITH_SEPARATOR = "piece placement starts with separator"
          PIECE_PLACEMENT_ENDS_WITH_SEPARATOR = "piece placement ends with separator"
          INVALID_EMPTY_COUNT = "invalid empty count"

          # =================================================================
          # Hands errors (Field 2)
          # =================================================================

          INVALID_HANDS_DELIMITER = "invalid hands delimiter"
          INVALID_HAND_COUNT = "invalid hand count"

          # =================================================================
          # Style-Turn errors (Field 3)
          # =================================================================

          INVALID_STYLE_TURN_DELIMITER = "invalid style-turn delimiter"
          STYLE_TOKENS_SAME_CASE = "style tokens must have opposite case"
        end
      end
    end
  end
end
