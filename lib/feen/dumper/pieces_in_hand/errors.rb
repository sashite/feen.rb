# frozen_string_literal: true

module Feen
  module Dumper
    module PiecesInHand
      Errors = {
        invalid_type:   "Piece at index: %<index>s must be a String, got type: %<type>s",
        invalid_format: "Piece at index: %<index>s has an invalid PNN format: '%<value>s'. Expected format: [prefix]letter[suffix] where prefix is + or -, suffix is ', and letter is a-z or A-Z"
      }.freeze
    end
  end
end
