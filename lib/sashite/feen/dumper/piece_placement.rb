# frozen_string_literal: true

module Sashite
  module Feen
    module Dumper
      module PiecePlacement
        # Separator between ranks
        RANK_SEPARATOR = "/"

        module_function

        # Dump a Placement grid to FEEN ranks (e.g., "rnbqkbnr/pppppppp/8/...")
        #
        # @param placement [Sashite::Feen::Placement]
        # @return [String]
        def dump(placement)
          pl = _coerce_placement(placement)

          grid = pl.grid
          raise Error::Bounds, "empty grid" if grid.empty?
          raise Error::Bounds, "grid must be an Array of rows" unless grid.is_a?(Array)

          width = nil
          dumped_rows = grid.each_with_index.map do |row, r_idx|
            raise Error::Bounds, "row #{r_idx + 1} must be an Array, got #{row.class}" unless row.is_a?(Array)

            width ||= row.length
            raise Error::Bounds, "row #{r_idx + 1} has zero width" if width.zero?

            if row.length != width
              raise Error::Bounds,
                    "inconsistent row width at row #{r_idx + 1} (expected #{width}, got #{row.length})"
            end

            _dump_row(row, r_idx)
          end

          dumped_rows.join(RANK_SEPARATOR)
        end

        # -- internals ---------------------------------------------------------

        # Accept nil (and legacy "") as empty cells
        def _empty_cell?(cell)
          cell.nil? || cell == ""
        end
        private_class_method :_empty_cell?

        def _dump_row(row, r_idx)
          out = +""
          empty_run = 0

          row.each_with_index do |cell, c_idx|
            if _empty_cell?(cell)
              empty_run += 1
              next
            end

            if empty_run.positive?
              out << empty_run.to_s
              empty_run = 0
            end

            begin
              out << ::Sashite::Epin.dump(cell)
            rescue StandardError => e
              raise Error::Piece,
                    "invalid EPIN value at (row #{r_idx + 1}, col #{c_idx + 1}): #{e.message}"
            end
          end

          out << empty_run.to_s if empty_run.positive?
          out
        end
        private_class_method :_dump_row

        def _coerce_placement(obj)
          return obj if obj.is_a?(Placement)

          raise TypeError, "expected Sashite::Feen::Placement, got #{obj.class}"
        end
        private_class_method :_coerce_placement
      end
    end
  end
end
