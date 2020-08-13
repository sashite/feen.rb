# frozen_string_literal: true

module FEEN
  module Parser
    # The board class.
    class Board
      attr_reader :board

      def initialize(board)
        @board = board
      end

      def to_a
        board
          .split(/[\/,]+/)
          .flat_map { |str| row(str) }
      end

      private

      def row(string)
        string.match?(/[0-9]+/) ? Array.new(Integer(string)) : string
      end
    end
  end
end
