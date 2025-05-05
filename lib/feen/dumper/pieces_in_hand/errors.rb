# frozen_string_literal: true

module Feen
  module Dumper
    module PiecesInHand
      # Error messages for validation
      Errors = {
        invalid_type:   "Piece character at index %<index>d must be a String, got %<type>s",
        invalid_format: "Piece character at index %<index>d must be a single alphabetic character, got %<value>s"
      }.freeze
    end
  end
end
