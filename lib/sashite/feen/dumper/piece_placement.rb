# frozen_string_literal: true

require_relative "../shared/separators"

module Sashite
  module Feen
    module Dumper
      # Serializer for the FEEN Piece Placement field (Field 1).
      #
      # Converts a Qi position's flat board and shape into the canonical
      # FEEN Piece Placement string with:
      # - Run-length encoding for consecutive empty squares (nil)
      # - Dimensional separators ("/" for ranks, "//" for layers, etc.)
      #
      # Operates directly on the flat board array without allocating
      # intermediate nested structures.
      #
      # == Examples by dimensionality
      #
      # - 1D shape [4]:       board = ["K^", nil, nil, "k^"]       → "K^2k^"
      # - 2D shape [8, 8]:    board = [nil]*64                     → "8/8/8/8/8/8/8/8"
      # - 3D shape [2, 2, 2]: board = ["a","b","c","d","A","B","C","D"] → "ab/cd//AB/CD"
      #
      # @see https://sashite.dev/specs/feen/1.0.0/
      # @api private
      module PiecePlacement
        # Serializes a flat board to a FEEN Piece Placement field string.
        #
        # @param board [Array<String, nil>] Flat board array (row-major order)
        # @param shape [Array<Integer>] Board dimensions (e.g. [8, 8])
        # @return [String] Canonical Piece Placement field string
        def self.dump(board, shape)
          case shape.size
          when 1
            dump_rank(board, 0, shape[0])
          when 2
            dump_2d(board, shape[0], shape[1])
          when 3
            dump_3d(board, shape[0], shape[1], shape[2])
          end
        end

        class << self
          private

          # Serializes a 2D board (ranks separated by "/").
          #
          # @param board [Array] Flat board array
          # @param ranks [Integer] Number of ranks
          # @param files [Integer] Number of files per rank
          # @return [String] Serialized string
          def dump_2d(board, ranks, files)
            result = String.new
            offset = 0

            ranks.times do |i|
              result << Separators::SEGMENT if i > 0
              dump_rank_into(result, board, offset, files)
              offset += files
            end

            result
          end

          # Serializes a 3D board (ranks separated by "/", layers by "//").
          #
          # @param board [Array] Flat board array
          # @param layers [Integer] Number of layers
          # @param ranks [Integer] Number of ranks per layer
          # @param files [Integer] Number of files per rank
          # @return [String] Serialized string
          def dump_3d(board, layers, ranks, files)
            result = String.new
            offset = 0

            layers.times do |li|
              if li > 0
                result << Separators::SEGMENT
                result << Separators::SEGMENT
              end

              ranks.times do |ri|
                result << Separators::SEGMENT if ri > 0
                dump_rank_into(result, board, offset, files)
                offset += files
              end
            end

            result
          end

          # Serializes a single rank with run-length encoding, returning a new string.
          #
          # Used for 1D boards (top-level call).
          #
          # @param board [Array<String, nil>] Flat board array
          # @param offset [Integer] Starting index in the flat array
          # @param length [Integer] Number of squares in this rank
          # @return [String] Serialized rank string
          def dump_rank(board, offset, length)
            result = String.new
            dump_rank_into(result, board, offset, length)
            result
          end

          # Appends a run-length-encoded rank directly into an existing buffer.
          #
          # @param result [String] Buffer to append to
          # @param board [Array<String, nil>] Flat board array
          # @param offset [Integer] Starting index in the flat array
          # @param length [Integer] Number of squares in this rank
          # @return [void]
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
                             :dump_rank,
                             :dump_rank_into

        freeze
      end
    end
  end
end
