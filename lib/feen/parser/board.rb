# frozen_string_literal: true

module FEEN
  module Parser
    # The board class.
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
