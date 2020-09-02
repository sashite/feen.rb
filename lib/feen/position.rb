# frozen_string_literal: true

require_relative "dumper"

module FEEN
  # The position class.
  class Position
    # Players are identified by a number according to the order in which they
    # traditionally play from the starting position.
    #
    # @!attribute [r] active_side_id
    #   @return [Integer] The identifier of the player who must play.
    attr_reader :active_side_id

    # The indexes of each piece on the board.
    #
    # @!attribute [r] board
    #   @return [Hash] The indexes of each piece on the board.
    attr_reader :board

    # The shape of the board.
    #
    # @!attribute [r] indexes
    #   @return [Array] The shape of the board.
    attr_reader :indexes

    # The list of pieces in hand owned by players.
    #
    # @!attribute [r] pieces_in_hand_grouped_by_sides
    #   @return [Array] The list of pieces in hand for each side.
    attr_reader :pieces_in_hand_grouped_by_sides

    # Initialize a position.
    #
    # @param active_side_id [Integer] The identifier of the player who must play.
    # @param board [Hash] The indexes of each piece on the board.
    # @param indexes [Array] The shape of the board.
    # @param pieces_in_hand_grouped_by_sides [Array] The list of pieces in hand
    #   grouped by players.
    #
    # @example Dump a classic Tsume Shogi problem
    #   new(
    #     "active_side_id": 0,
    #     "board": {
    #       "3": "s",
    #       "4": "k" ,
    #       "5": "s",
    #       "22": "+P",
    #       "43": "+B"
    #     },
    #     "indexes": [9, 9],
    #     "pieces_in_hand_grouped_by_sides": [
    #       %w[S],
    #       %w[r r b g g g g s n n n n p p p p p p p p p p p p p p p p p]
    #     ]
    #   )
    def initialize(active_side_id:, board:, indexes:, pieces_in_hand_grouped_by_sides:)
      @active_side_id = active_side_id
      @board = board
      @indexes = indexes
      @pieces_in_hand_grouped_by_sides = pieces_in_hand_grouped_by_sides
    end

    # Returns the FEEN string of the position.
    #
    # @example Dump a FEEN
    #   to_s
    #   # => "3,s,k,s,3/9/4,+P,4/9/7,+B,1/9/9/9/9 0 S/b,g,g,g,g,n,n,n,n,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,r,r,s"
    #
    # @return [String] The FEEN string representing the position.
    def to_s
      Dumper.call(
        active_side_id: active_side_id,
        board: board,
        indexes: indexes,
        pieces_in_hand_grouped_by_sides: pieces_in_hand_grouped_by_sides
      )
    end
  end
end
