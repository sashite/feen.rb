# frozen_string_literal: true

module Feen
  module Parser
    module PiecesInHand
      # Handles canonical ordering validation for pieces in hand according to FEEN specification
      module CanonicalSorter
        # Validates that pieces are in canonical order according to FEEN specification:
        # 1. By quantity (descending)
        # 2. By complete PNN representation (alphabetically ascending)
        #
        # @param pieces_with_counts [Array<Hash>] Array of pieces with their counts
        # @raise [ArgumentError] If pieces are not in canonical order
        # @return [void]
        def self.validate_order(pieces_with_counts)
          return if pieces_with_counts.size <= 1

          # Create the expected canonical order
          canonical_order = sort_canonically(pieces_with_counts)

          # Compare with actual order
          pieces_with_counts.each_with_index do |piece_data, index|
            canonical_piece = canonical_order[index]

            next if piece_data[:piece] == canonical_piece[:piece] &&
                    piece_data[:count] == canonical_piece[:count]

            raise ::ArgumentError, format(
              Errors[:canonical_order_violation],
              actual:   format_pieces_sequence(pieces_with_counts),
              expected: format_pieces_sequence(canonical_order)
            )
          end
        end

        # Sorts pieces according to canonical FEEN order
        #
        # @param pieces_with_counts [Array<Hash>] Array of pieces with their counts
        # @return [Array<Hash>] Canonically sorted array
        def self.sort_canonically(pieces_with_counts)
          pieces_with_counts.sort do |a, b|
            # Primary sort: by quantity (descending)
            count_comparison = b[:count] <=> a[:count]
            next count_comparison unless count_comparison.zero?

            # Secondary sort: by complete PNN representation (alphabetically ascending)
            a[:piece] <=> b[:piece]
          end
        end

        # Formats a pieces sequence for error messages
        #
        # @param pieces_with_counts [Array<Hash>] Array of pieces with their counts
        # @return [String] Formatted string representation
        private_class_method def self.format_pieces_sequence(pieces_with_counts)
          pieces_with_counts.map do |item|
            count = item[:count]
            piece = item[:piece]

            if count == 1
              piece
            else
              "#{count}#{piece}"
            end
          end.join
        end
      end
    end
  end
end
