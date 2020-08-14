# frozen_string_literal: true

module FEEN
  module Parser
    # The shape class.
    class Shape
      # @param board [String] The flatten board.
      def initialize(board)
        @board = board
      end

      # @return [Array] The size of each dimension of the board.
      def to_a
        indexes(@board, @board.scan(%r{/+}).sort.fetch(-1))
      end

      private

      def indexes(string, separator)
        if separator.empty?
          last_index = string.split(',').inject(0) do |counter, sub_string|
            number = sub_string.match?(/[0-9]+/) ? Integer(sub_string) : 1
            counter + number
          end

          return [last_index]
        end

        sub_strings = string.split(separator)
        [sub_strings.length] + indexes(sub_strings.fetch(0), separator[1..])
      end
    end
  end
end
