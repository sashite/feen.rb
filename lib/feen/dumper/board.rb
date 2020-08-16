# frozen_string_literal: true

require_relative 'inconsistent_size_error'

module FEEN
  module Dumper
    # The board class.
    #
    # @example Dump the board of Xiangqi's starting position
    #   Board.new(10, 9).to_s(
    #     "車", "馬", "象", "士", "將", "士", "象", "馬", "車",
    #     nil, nil, nil, nil, nil, nil, nil, nil, nil,
    #     nil, "砲", nil, nil, nil, nil, nil, "砲", nil,
    #     "卒", nil, "卒", nil, "卒", nil, "卒", nil, "卒",
    #     nil, nil, nil, nil, nil, nil, nil, nil, nil,
    #     nil, nil, nil, nil, nil, nil, nil, nil, nil,
    #     "兵", nil, "兵", nil, "兵", nil, "兵", nil, "兵",
    #     nil, "炮", nil, nil, nil, nil, nil, "炮", nil,
    #     nil, nil, nil, nil, nil, nil, nil, nil, nil,
    #     "俥", "傌", "相", "仕", "帥", "仕", "相", "傌", "俥"
    #   )
    #   # => "車,馬,象,士,將,士,象,馬,車/9/1,砲,5,砲,1/卒,1,卒,1,卒,1,卒,1,卒/9/9/兵,1,兵,1,兵,1,兵,1,兵/1,炮,5,炮,1/9/俥,傌,相,仕,帥,仕,相,傌,俥"
    class Board
      # @param indexes [Array] The shape of the board.
      def initialize(*indexes)
        @indexes = indexes
      end

      # @param squares [Array] The list of squares on the board.
      #
      # @return [String] The string representing the board.
      def to_s(*squares)
        raise InconsistentSizeError unless squares.length == @indexes.inject(:*)

        unflatten(squares, *@indexes)
      end

      private

      def unflatten(squares, *remaining_indexes)
        return row(*squares) if remaining_indexes.length == 1

        squares
          .each_slice(squares.length / remaining_indexes.fetch(0))
          .to_a
          .map { |sub_squares| unflatten(sub_squares, *remaining_indexes[1..]) }
          .join('/' * remaining_indexes.length.pred)
      end

      def row(*squares)
        squares
          .map { |square| square.nil? ? 1 : square }
          .join(',')
          .gsub(/1,[1,]*1/) { |str| str.split(',').length }
      end
    end
  end
end
