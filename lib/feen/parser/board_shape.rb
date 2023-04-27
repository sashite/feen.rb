# frozen_string_literal: true

module Feen
  module Parser
    # The BoardShape class.
    #
    # @example Parse the shape of a shogiban
    #   BoardShape.new("3sks3/9/4+P4/9/7+B1/9/9/9/9").to_a # => [9, 9]
    class BoardShape
      # @param board_str [String] The flatten board.
      def initialize(board_str, regex: /\+?[a-z]/i)
        @board_str = board_str
        @regex = regex
      end

      # @return [Array] The size of each dimension of the board.
      def to_a
        indexes(@board_str, @board_str.scan(%r{/+}).sort.fetch(-1))
      end

      private

      def indexes(string, separator)
        if separator.empty?
          last_index = string.scan(/(\d+|#{@regex})/).inject(0) do |counter, match|
            sub_string = match[0]
            number = sub_string.match?(/\d+/) ? Integer(sub_string) : 1
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
