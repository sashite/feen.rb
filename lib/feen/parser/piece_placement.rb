# frozen_string_literal: true

module Feen
  module Parser
    # The PiecePlacement class.
    #
    # @example Parse a Shogi problem board and return an array
    #   PiecePlacement.new("3,s,k,s,3/9/4,+P,4/9/7,+B,1/9/9/9/9").to_a
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
    #
    # @example Parse a Shogi problem board and return a hash
    #   PiecePlacement.new("3,s,k,s,3/9/4,+P,4/9/7,+B,1/9/9/9/9").to_h
    #   # => {
    #   #       3 => "s",
    #   #       4 => "k",
    #   #       5 => "s",
    #   #      22 => "+P",
    #   #      43 => "+B"
    #   #    }
    class PiecePlacement
      # @param piece_placement_str [String] The placement of pieces on the board.
      def initialize(piece_placement_str)
        @piece_placement_str = piece_placement_str
      end

      # @return [Array] The list of pieces on the board.
      def to_a
        @piece_placement_str
          .split(%r{[/,]+})
          .flat_map { |str| row(str) }
      end

      # @return [Hash] The index of each piece on the board.
      def to_h
        to_a
          .each_with_index
          .inject({}) do |h, (v, i)|
            next h if v.nil?

            h.merge(i => v)
          end
      end

      private

      def row(string)
        string.match?(/[0-9]+/) ? ::Array.new(Integer(string)) : string
      end
    end
  end
end
