# frozen_string_literal: true

require_relative "parse_error"

module Sashite
  module Feen
    # Error raised when Style-Turn field (Field 3) parsing fails.
    #
    # @api public
    class StyleTurnError < ParseError
      INVALID_DELIMITER   = "invalid style-turn delimiter"
      INVALID_STYLE_TOKEN = "invalid style token"
      SAME_CASE           = "style tokens must have opposite case"

      freeze
    end
  end
end
