# frozen_string_literal: true

require_relative "parse_error"

module Sashite
  module Feen
    # Error raised when Hands field (Field 2) parsing fails.
    #
    # @api public
    class HandsError < ParseError
      INVALID_DELIMITER   = "invalid hands delimiter"
      INVALID_COUNT       = "invalid hand count"
      INVALID_PIECE_TOKEN = "invalid piece token"
      NOT_AGGREGATED      = "hand items not aggregated"
      NOT_CANONICAL       = "hand items not in canonical order"

      freeze
    end
  end
end
