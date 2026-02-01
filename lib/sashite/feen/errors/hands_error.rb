# frozen_string_literal: true

require_relative "parse_error"

module Sashite
  module Feen
    # Error raised when Hands field (Field 2) parsing fails.
    #
    # The Hands field encodes off-board pieces held by each player.
    # This error covers delimiter issues, count validation failures,
    # and canonicalization violations.
    #
    # @example Catching hands errors
    #   begin
    #     Sashite::Feen.parse("K PP/ C/c")
    #   rescue Sashite::Feen::HandsError => e
    #     puts "Hands error: #{e.message}"
    #   end
    #
    # @see https://sashite.dev/specs/feen/1.0.0/
    # @api public
    class HandsError < ParseError
      # Field 2 missing "/" or contains multiple "/".
      INVALID_DELIMITER = "invalid hands delimiter"

      # Multiplicity is 0, 1, or has leading zeros.
      INVALID_COUNT = "invalid hand count"

      # Token is not a valid EPIN identifier.
      INVALID_PIECE_TOKEN = "invalid piece token"

      # Identical EPIN tokens not combined.
      NOT_AGGREGATED = "hand items not aggregated"

      # Items violate canonical ordering rules.
      NOT_CANONICAL = "hand items not in canonical order"

      freeze
    end
  end
end
