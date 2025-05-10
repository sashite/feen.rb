# frozen_string_literal: true

module Feen
  module Dumper
    module PiecesInHand
      Errors = {
        invalid_type: "Piece at index: %{index} must be a String, got type: %{type}",
        invalid_format: "Piece at index: %{index} has an invalid format: '%{value}'"
      }.freeze
    end
  end
end
