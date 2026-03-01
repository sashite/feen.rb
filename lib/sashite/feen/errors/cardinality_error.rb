# frozen_string_literal: true

require_relative "parse_error"

module Sashite
  module Feen
    # Error raised when cardinality constraints are violated.
    #
    # Total pieces (board + hands) must not exceed total squares.
    #
    # @api public
    class CardinalityError < ParseError
      TOO_MANY_PIECES = "too many pieces for board size"

      freeze
    end
  end
end
