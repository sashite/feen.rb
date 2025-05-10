# frozen_string_literal: true

module Feen
  module Parser
    module PiecesInHand
      # Error messages for validation
      Errors = {
        invalid_type:   "Pieces in hand must be a string, got %s",
        empty_string:   "Pieces in hand string cannot be empty",
        invalid_format: "Invalid pieces in hand format: %s",
        sorting_error:  "Pieces in hand must be in ASCII lexicographic order"
      }.freeze
    end
  end
end
