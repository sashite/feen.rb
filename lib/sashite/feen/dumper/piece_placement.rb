# frozen_string_literal: true

module Sashite
  module Feen
    module Dumper
      # Dumper for the piece placement field (first field of FEEN).
      #
      # Converts a Placement object into its FEEN string representation,
      # encoding board configuration using EPIN notation with empty square
      # compression and multi-dimensional separator support.
      #
      # @see https://sashite.dev/specs/feen/1.0.0/
      module PiecePlacement
        # Rank separator for 2D boards.
        RANK_SEPARATOR = "/"

        # Dump a Placement object into its FEEN piece placement string.
        #
        # Converts the board configuration into FEEN notation by processing
        # each rank, compressing consecutive empty squares into digits, and
        # joining ranks with appropriate separators for multi-dimensional boards.
        #
        # @param placement [Placement] The board placement object
        # @return [String] FEEN piece placement field string
        #
        # @example Chess starting position
        #   dump(placement)
        #   # => "+rnbq+kbn+r/+p+p+p+p+p+p+p+p/8/8/8/8/+P+P+P+P+P+P+P+P/+RNBQ+KBN+R"
        #
        # @example Empty 8x8 board
        #   dump(placement)
        #   # => "8/8/8/8/8/8/8/8"
        def self.dump(placement)
          ranks = placement.ranks.map { |rank| dump_rank(rank) }
          join_ranks(ranks, placement.dimension, placement.sections)
        end

        # Dump a single rank into its FEEN representation.
        #
        # Converts a rank (array of pieces and nils) into FEEN notation by:
        # 1. Converting pieces to EPIN strings
        # 2. Compressing consecutive nils into digit counts
        #
        # @param rank [Array] Array of piece objects and nils
        # @return [String] FEEN rank string
        #
        # @example Rank with pieces and empty squares
        #   dump_rank([piece1, nil, nil, piece2])
        #   # => "K2Q"
        private_class_method def self.dump_rank(rank)
          result = []
          empty_count = 0

          rank.each do |square|
            if square.nil?
              empty_count += 1
            else
              result << empty_count.to_s if empty_count > 0
              result << square.to_s
              empty_count = 0
            end
          end

          result << empty_count.to_s if empty_count > 0
          result.join
        end

        # Join ranks with appropriate separators for multi-dimensional boards.
        #
        # Uses section information if available, otherwise treats all ranks equally.
        #
        # @param ranks [Array<String>] Array of rank strings
        # @param dimension [Integer] Board dimensionality (default 2)
        # @param sections [Array<Integer>, nil] Section sizes for grouping
        # @return [String] Complete piece placement string
        #
        # @example 2D board
        #   join_ranks(["8", "8"], 2, nil)
        #   # => "8/8"
        #
        # @example 3D board with sections
        #   join_ranks(["5", "5", "5", "5"], 3, [2, 2])
        #   # => "5/5//5/5"
        private_class_method def self.join_ranks(ranks, dimension = 2, sections = nil)
          if dimension == 2 || sections.nil?
            # Simple 2D case or no section info
            separator = RANK_SEPARATOR * (dimension - 1)
            ranks.join(separator)
          else
            # Multi-dimensional with section info
            rank_separator = RANK_SEPARATOR
            section_separator = RANK_SEPARATOR * (dimension - 1)

            # Group ranks by sections
            result = []
            offset = 0
            sections.each do |section_size|
              section_ranks = ranks[offset, section_size]
              result << section_ranks.join(rank_separator)
              offset += section_size
            end

            result.join(section_separator)
          end
        end
      end
    end
  end
end
