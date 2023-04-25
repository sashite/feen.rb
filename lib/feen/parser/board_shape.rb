# frozen_string_literal: true

module Feen
  module Parser
    # The BoardShape class.
    #
    # @example Parse the shape of a shogiban
    #   BoardShape.new("3,s,k,s,3/9/4,+P,4/9/7,+B,1/9/9/9/9").to_a # => [9, 9]
    class BoardShape
      # @param board_str [String] The flatten board.
      def initialize(board_str)
        @board_str = board_str
      end

      # @return [Array] The size of each dimension of the board.
      def to_a
        indexes(@board_str, @board_str.scan(%r{/+}).sort.fetch(-1))
      end

      private

      def indexes(string, separator)
        if separator.empty?
          last_index = string.split(",").inject(0) do |counter, sub_string|
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
