# frozen_string_literal: true

require_relative 'inconsistent_size_error'

module FEEN
  module Dumper
    # The board class.
    class Board
      attr_reader :indexes

      def initialize(*indexes)
        @indexes = indexes
      end

      def to_s(*squares)
        raise InconsistentSizeError unless squares.length == indexes.inject(:*)

        unflatten(squares, *indexes)
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
