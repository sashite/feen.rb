# frozen_string_literal: true

module Sashite
  module Feen
    module Dumper
      # Serializer for the FEEN Piece Placement field (Field 1).
      #
      # Converts a flat board + shape into the canonical FEEN string
      # with run-length encoding and dimensional separators.
      #
      # @api private
      module PiecePlacement
        # Serializes a flat board to a FEEN Piece Placement field string.
        #
        # @param board [Array<String, nil>] Flat board (row-major order)
        # @param shape [Array<Integer>] Board dimensions
        # @return [String] Canonical Piece Placement string
        def self.dump(board, shape)
          case shape.size
          when 1
            result = String.new
            dump_rank_into(result, board, 0, shape[0])
            result
          when 2
            dump_2d(board, shape[0], shape[1])
          when 3
            dump_3d(board, shape[0], shape[1], shape[2])
          end
        end

        class << self
          private

          def dump_2d(board, ranks, files)
            result = String.new
            offset = 0

            ranks.times do |i|
              result << "/" if i > 0
              dump_rank_into(result, board, offset, files)
              offset += files
            end

            result
          end

          def dump_3d(board, layers, ranks, files)
            result = String.new
            offset = 0

            layers.times do |li|
              result << "//" if li > 0

              ranks.times do |ri|
                result << "/" if ri > 0
                dump_rank_into(result, board, offset, files)
                offset += files
              end
            end

            result
          end

          # Appends a run-length-encoded rank into a buffer.
          def dump_rank_into(result, board, offset, length)
            empty_count = 0
            stop = offset + length

            while offset < stop
              square = board[offset]

              if square.nil?
                empty_count += 1
              else
                if empty_count > 0
                  result << empty_count.to_s
                  empty_count = 0
                end

                result << square
              end

              offset += 1
            end

            result << empty_count.to_s if empty_count > 0
          end
        end

        private_class_method :dump_2d,
                             :dump_3d,
                             :dump_rank_into

        freeze
      end
    end
  end
end
