# frozen_string_literal: true

module Feen
  module Parser
    module PiecesInHand
      # Error messages for validation
      Errors = {
        invalid_type:              "Pieces in hand must be a string, got %s",
        empty_string:              "Pieces in hand string cannot be empty",
        invalid_format:            "Invalid pieces in hand format: %s",
        invalid_pnn_piece:         "Invalid PNN piece format: '%s'. Expected format: [prefix]letter[suffix] where prefix is + or -, suffix is ', and letter is a-z or A-Z",
        invalid_count:             "Invalid count format: '%s'. Count cannot be '0' or '1', use the piece without count instead",
        canonical_order_violation: "Pieces in hand must be in canonical order (by quantity descending, then alphabetically). Got: '%<actual>s', expected: '%<expected>s'"
      }.freeze
    end
  end
end
