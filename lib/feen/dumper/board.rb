# frozen_string_literal: true

module FEEN
  module Dumper
    # The board class.
    class Board
      attr_reader :indexes

      def initialize(*indexes)
        @indexes = indexes
      end

      def call(*squares)
        slice(indexes.reverse, *squares)
      end

      private

      def slice(remaining_indexes, *squares)
        return row(*squares) if remaining_indexes.length == 1

        squares.each_slice(remaining_indexes.fetch(0)).map do |sub_squares|
          slice(remaining_indexes[1..], *sub_squares)
        end.join('/' * remaining_indexes.length.pred)
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
