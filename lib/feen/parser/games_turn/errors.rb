# frozen_string_literal: true

module Feen
  module Parser
    module GamesTurn
      # Error messages for games turn parsing
      Errors = {
        invalid_type:   "Games turn must be a string, got %s",
        empty_string:   "Games turn string cannot be empty",
        invalid_format: "Invalid games turn format. Expected format: UPPERCASE/lowercase or lowercase/UPPERCASE"
      }.freeze
    end
  end
end
