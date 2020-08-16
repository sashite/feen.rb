# frozen_string_literal: true

module FEEN
  module Parser
    # The board class.
    #
    # @example Parse a Shogi problem board
    #   Board.new("3,s,k,s,3/9/4,+P,4/9/7,+B,1/9/9/9/9").to_a
    #   # => [
    #   #      nil, nil, nil, "s", "k", "s", nil, nil, nil,
    #   #      nil, nil, nil, nil, nil, nil, nil, nil, nil,
    #   #      nil, nil, nil, nil, "+P", nil, nil, nil, nil,
    #   #      nil, nil, nil, nil, nil, nil, nil, nil, nil,
    #   #      nil, nil, nil, nil, nil, nil, nil, "+B", nil,
    #   #      nil, nil, nil, nil, nil, nil, nil, nil, nil,
    #   #      nil, nil, nil, nil, nil, nil, nil, nil, nil,
    #   #      nil, nil, nil, nil, nil, nil, nil, nil, nil,
    #   #      nil, nil, nil, nil, nil, nil, nil, nil, nil
    #   #    ]
    class Board
      # @param board [String] The flatten board.
      def initialize(board)
        @board = board
      end

      # @return [Array] The list of squares on the board.
      def to_a
        @board
          .split(%r{[/,]+})
          .flat_map { |str| row(str) }
      end

      private

      def row(string)
        string.match?(/[0-9]+/) ? ::Array.new(Integer(string)) : string
      end
    end
  end
end
