# frozen_string_literal: true

module Feen
  module Dumper
    # The PiecePlacement class.
    #
    # @example Dump an empty board of Xiangqi
    #   PiecePlacement.new([10, 9]).to_s # => "9/9/9/9/9/9/9/9/9/9"
    #
    # @example Dump the Xiangqi starting position board
    #   PiecePlacement.new(
    #     [10, 9],
    #     {
    #        0 => "車",
    #        1 => "馬",
    #        2 => "象",
    #        3 => "士",
    #        4 => "將",
    #        5 => "士",
    #        6 => "象",
    #        7 => "馬",
    #        8 => "車",
    #       19 => "砲",
    #       25 => "砲",
    #       27 => "卒",
    #       29 => "卒",
    #       31 => "卒",
    #       33 => "卒",
    #       35 => "卒",
    #       54 => "兵",
    #       56 => "兵",
    #       58 => "兵",
    #       60 => "兵",
    #       62 => "兵",
    #       64 => "炮",
    #       70 => "炮",
    #       81 => "俥",
    #       82 => "傌",
    #       83 => "相",
    #       84 => "仕",
    #       85 => "帥",
    #       86 => "仕",
    #       87 => "相",
    #       88 => "傌",
    #       89 => "俥"
    #     }
    #   ).to_s # => "車馬象士將士象馬車/9/1砲5砲1/卒1卒1卒1卒1卒/9/9/兵1兵1兵1兵1兵/1炮5炮1/9/俥傌相仕帥仕相傌俥"
    class PiecePlacement
      # @param indexes [Array] The shape of the board.
      # @param piece_placement [Hash] The index of each piece on the board.
      def initialize(indexes, piece_placement = {})
        @indexes = indexes
        @squares = ::Array.new(length) { |i| piece_placement.fetch(i, nil) }
      end

      # @return [String] The string representing the board.
      def to_s
        unflatten(@squares, @indexes)
      end

      private

      def length
        @indexes.inject(:*)
      end

      def unflatten(squares, remaining_indexes)
        return row(squares) if remaining_indexes.length == 1

        squares
          .each_slice(squares.length / remaining_indexes.fetch(0))
          .to_a
          .map { |sub_squares| unflatten(sub_squares, remaining_indexes[1..]) }
          .join("/" * remaining_indexes.length.pred)
      end

      def row(squares)
        squares
          .map { |square| square.nil? ? 1 : square }
          .join(",")
          .gsub(/1,[1,]*1/) { |str| str.split(",").length }
          .delete(",")
      end
    end
  end
end
