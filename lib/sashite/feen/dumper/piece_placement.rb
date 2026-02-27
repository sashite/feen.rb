# frozen_string_literal: true

require_relative "../shared/separators"

module Sashite
  module Feen
    module Dumper
      # Serializer for the FEEN Piece Placement field (Field 1).
      #
      # Converts a Qi::Position board (nested Array of String/nil) into
      # the canonical FEEN Piece Placement string with:
      # - Run-length encoding for consecutive empty squares (nil)
      # - Dimensional separators ("/" for ranks, "//" for layers, etc.)
      #
      # == Board Structures
      #
      # - 1D: flat Array         → "K^2k^"
      # - 2D: Array of Arrays    → "8/8/8/8/8/8/8/8"
      # - 3D: Array³             → "ab/cd//AB/CD"
      #
      # @example 1D board
      #   PiecePlacement.dump(["K^", nil, nil, "k^"])
      #   # => "K^2k^"
      #
      # @example 2D empty board
      #   PiecePlacement.dump(Array.new(8) { Array.new(8) })
      #   # => "8/8/8/8/8/8/8/8"
      #
      # @example 3D board
      #   PiecePlacement.dump([[["a","b"],["c","d"]],[["A","B"],["C","D"]]])
      #   # => "ab/cd//AB/CD"
      #
      # @see https://sashite.dev/specs/feen/1.0.0/
      # @api private
      module PiecePlacement
        # Serializes a board array to a FEEN Piece Placement field string.
        #
        # @param board [Array] Nested board array (1D, 2D, or 3D)
        # @return [String] Canonical Piece Placement field string
        def self.dump(board)
          serialize(board, depth(board))
        end

        class << self
          private

          # Determines the dimensionality of the board.
          #
          # - 1D: board[0] is not an Array (flat list of squares)
          # - 2D: board[0] is an Array but board[0][0] is not
          # - 3D: board[0][0] is an Array
          #
          # @param board [Array] The board to inspect
          # @return [Integer] Dimensionality (1, 2, or 3)
          def depth(board)
            return 1 unless ::Array === board[0]
            return 2 unless ::Array === board[0][0]

            3
          end

          # Recursively serializes a board structure at a given dimension level.
          #
          # @param structure [Array] Board structure at current level
          # @param dim [Integer] Current dimensionality
          # @return [String] Serialized string
          def serialize(structure, dim)
            if dim == 1
              dump_rank(structure)
            else
              separator = Separators::SEGMENT * (dim - 1)

              structure.map { |sub| serialize(sub, dim - 1) }.join(separator)
            end
          end

          # Serializes a single rank (flat array of String/nil) with
          # run-length encoding for consecutive empty squares.
          #
          # @param rank [Array<String, nil>] Flat rank array
          # @return [String] Serialized rank string
          def dump_rank(rank)
            result = String.new
            empty_count = 0

            rank.each do |square|
              if square.nil?
                empty_count += 1
              else
                if empty_count > 0
                  result << empty_count.to_s
                  empty_count = 0
                end

                result << square
              end
            end

            result << empty_count.to_s if empty_count > 0

            result
          end
        end

        private_class_method :depth,
                             :serialize,
                             :dump_rank

        freeze
      end
    end
  end
end
