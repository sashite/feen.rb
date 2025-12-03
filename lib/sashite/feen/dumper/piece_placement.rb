# frozen_string_literal: true

module Sashite
  module Feen
    module Dumper
      # Dumper for the piece placement field (first field of FEEN).
      #
      # Converts a Placement object into its FEEN string representation,
      # encoding board configuration using EPIN notation with:
      # - Empty square compression (consecutive nils → numbers)
      # - Exact separator preservation (from Placement.separators)
      # - Support for any irregular board structure
      #
      # The dumper produces canonical FEEN strings that enable perfect
      # round-trip conversion (dump → parse → dump).
      #
      # @see https://sashite.dev/specs/feen/1.0.0/
      module PiecePlacement
        # Dump a Placement object into its FEEN piece placement string.
        #
        # Process:
        # 1. For 1D boards: dump single rank directly
        # 2. For multi-D boards: interleave ranks with their separators
        # 3. Compress consecutive empty squares into numbers
        # 4. Convert pieces to EPIN strings
        #
        # @param placement [Placement] The board placement object
        # @return [String] FEEN piece placement field string
        #
        # @example Chess starting position
        #   dump(placement)
        #   # => "+rnbq+k^bn+r/+p+p+p+p+p+p+p+p/8/8/8/8/+P+P+P+P+P+P+P+P/+RNBQ+K^BN+R"
        #
        # @example Empty 8x8 board
        #   dump(placement)
        #   # => "8/8/8/8/8/8/8/8"
        #
        # @example 1D board
        #   dump(placement)
        #   # => "K^2P3k^"
        #
        # @example Irregular 3D board
        #   dump(placement)
        #   # => "5/5//5/5/5"
        #
        # @example Very large board
        #   dump(placement)
        #   # => "100/100/100"
        def self.dump(placement)
          # Special case: 1D board (no separators)
          return dump_rank(placement.ranks[0]) if placement.one_dimensional?

          # Multi-dimensional: interleave ranks and separators
          dump_multi_dimensional(placement)
        end

        # Dump multi-dimensional placement.
        #
        # Alternates between ranks and separators:
        # rank[0] + sep[0] + rank[1] + sep[1] + ... + rank[n]
        #
        # @param placement [Placement] Placement object
        # @return [String] FEEN string with separators
        #
        # @example 2D board
        #   dump_multi_dimensional(placement)
        #   # => "r1/r2/r3"
        #
        # @example 3D board with mixed separators
        #   dump_multi_dimensional(placement)
        #   # => "r1/r2//r3"
        private_class_method def self.dump_multi_dimensional(placement)
          result = []

          placement.ranks.each_with_index do |rank, idx|
            # Dump the rank
            result << dump_rank(rank)

            # Add separator if not last rank
            result << placement.separators[idx] if idx < placement.separators.size
          end

          result.join
        end

        # Dump a single rank into its FEEN representation.
        #
        # Converts a rank (array of pieces and nils) into FEEN notation by:
        # 1. Converting pieces to EPIN strings (via piece.to_s)
        # 2. Compressing consecutive nils into number strings
        #
        # Algorithm:
        # - Iterate through rank squares
        # - Count consecutive nils (empty_count)
        # - When hitting a piece: flush count (if > 0), add piece
        # - At end: flush final count (if > 0)
        #
        # @param rank [Array] Array of piece objects and nils
        # @return [String] FEEN rank string
        #
        # @example Rank with pieces only
        #   dump_rank([K, Q, R, B])
        #   # => "KQRB"
        #
        # @example Rank with empty squares
        #   dump_rank([K, nil, nil, Q])
        #   # => "K2Q"
        #
        # @example Rank all empty
        #   dump_rank([nil, nil, nil, nil, nil, nil, nil, nil])
        #   # => "8"
        #
        # @example Very large empty count
        #   dump_rank(Array.new(100, nil))
        #   # => "100"
        #
        # @example Complex rank
        #   dump_rank([+K, nil, nil, -p', nil, R])
        #   # => "+K2-p'1R"
        private_class_method def self.dump_rank(rank)
          result = []
          empty_count = 0

          rank.each do |square|
            if square.nil?
              # Empty square: increment counter
              empty_count += 1
            else
              # Piece: flush empty count, add piece
              flush_empty_count!(result, empty_count)
              result << square.to_s
              empty_count = 0
            end
          end

          # Flush final empty count
          flush_empty_count!(result, empty_count)

          result.join
        end

        # Flush accumulated empty count to result array.
        #
        # If empty_count > 0, appends the number as a string.
        # This enables compression of consecutive empty squares.
        #
        # @param result [Array<String>] Result array being built
        # @param empty_count [Integer] Number of consecutive empty squares
        # @return [void]
        #
        # @example Flush count
        #   result = ["K"]
        #   flush_empty_count!(result, 5)
        #   result  # => ["K", "5"]
        #
        # @example No flush (zero count)
        #   result = ["K"]
        #   flush_empty_count!(result, 0)
        #   result  # => ["K"]
        private_class_method def self.flush_empty_count!(result, empty_count)
          result << empty_count.to_s if empty_count > 0
        end
      end
    end
  end
end
