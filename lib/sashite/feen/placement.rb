# frozen_string_literal: true

module Sashite
  module Feen
    # Immutable board placement: rectangular grid of cells (nil = empty, otherwise EPIN value)
    class Placement
      attr_reader :grid, :height, :width

      # @param grid [Array<Array>]
      #   Each row is an Array; all rows must have identical length.
      def initialize(grid)
        raise TypeError, "grid must be an Array of rows, got #{grid.class}" unless grid.is_a?(Array)
        raise Error::Bounds, "grid cannot be empty" if grid.empty?
        unless grid.all?(Array)
          raise Error::Bounds, "grid must be an Array of rows (Array), got #{grid.map(&:class).inspect}"
        end

        widths = grid.map(&:length)
        width = widths.first || 0
        raise Error::Bounds, "rows cannot be empty" if width.zero?
        raise Error::Bounds, "inconsistent row width (#{widths.uniq.join(', ')})" if widths.any? { |w| w != width }

        # Deep-freeze
        @grid = grid.map { |row| row.dup.freeze }.freeze
        @height = @grid.length
        @width  = width
        freeze
      end
    end
  end
end
