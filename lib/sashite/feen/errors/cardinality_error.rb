# frozen_string_literal: true

require_relative "parse_error"

module Sashite
  module Feen
    # Error raised when cardinality constraints are violated.
    #
    # The Game Protocol requires that the total number of pieces
    # (on board plus in hands) does not exceed the total number
    # of squares on the board.
    #
    # @example Catching cardinality errors
    #   begin
    #     Sashite::Feen.parse("K 2P/ C/c")  # 1 square, 3 pieces
    #   rescue Sashite::Feen::CardinalityError => e
    #     puts "Cardinality error: #{e.message}"
    #   end
    #
    # @see https://sashite.dev/specs/feen/1.0.0/
    # @api public
    class CardinalityError < ParseError
      # Total pieces (board + hands) exceeds total squares.
      TOO_MANY_PIECES = "too many pieces for board size"

      freeze
    end
  end
end
