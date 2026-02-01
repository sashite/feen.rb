# frozen_string_literal: true

require_relative "parse_error"

module Sashite
  module Feen
    # Error raised when Style-Turn field (Field 3) parsing fails.
    #
    # The Style-Turn field encodes player styles and the active player.
    # This error covers delimiter issues, token validation failures,
    # and case constraint violations.
    #
    # @example Catching style-turn errors
    #   begin
    #     Sashite::Feen.parse("K / C/C")
    #   rescue Sashite::Feen::StyleTurnError => e
    #     puts "Style-turn error: #{e.message}"
    #   end
    #
    # @see https://sashite.dev/specs/feen/1.0.0/
    # @api public
    class StyleTurnError < ParseError
      # Field 3 missing "/" or contains multiple "/".
      INVALID_DELIMITER = "invalid style-turn delimiter"

      # Token is not a valid SIN identifier.
      INVALID_STYLE_TOKEN = "invalid style token"

      # Both tokens uppercase or both lowercase.
      SAME_CASE = "style tokens must have opposite case"

      freeze
    end
  end
end
