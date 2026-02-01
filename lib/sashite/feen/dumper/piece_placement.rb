# frozen_string_literal: true

require_relative "../shared/separators"

module Sashite
  module Feen
    module Dumper
      # Serializer for FEEN Piece Placement field (Field 1).
      #
      # Converts structured board data into a canonical FEEN string.
      # Handles canonicalization of empty counts (merging consecutive empties).
      #
      # Input format:
      # - segments: Array of Arrays containing placement tokens
      #   - Integer tokens represent empty square counts
      #   - Other tokens (pieces) must respond to #to_s
      # - separators: Array of Strings ("/" for ranks, "//" for layers, etc.)
      #
      # @example Basic usage
      #   Dumper::PiecePlacement.dump(
      #     segments: [[8], [8], [8], [8], [8], [8], [8], [8]],
      #     separators: ["/", "/", "/", "/", "/", "/", "/"]
      #   )
      #   # => "8/8/8/8/8/8/8/8"
      #
      # @example With pieces
      #   Dumper::PiecePlacement.dump(
      #     segments: [["r", "n", "b", "q", "k", "b", "n", "r"]],
      #     separators: []
      #   )
      #   # => "rnbqkbnr"
      #
      # @example Canonicalization (merges consecutive empties)
      #   Dumper::PiecePlacement.dump(
      #     segments: [[3, 2, "K", 1, 1]],
      #     separators: []
      #   )
      #   # => "5K2"
      #
      # @see https://sashite.dev/specs/feen/1.0.0/
      # @api private
      module PiecePlacement
        # Serializes piece placement data to a FEEN string.
        #
        # @param segments [Array<Array>] Board segments with tokens
        # @param separators [Array<String>] Separators between segments
        # @return [String] Canonical FEEN piece placement string
        def self.dump(segments:, separators:)
          segments.map.with_index do |segment, index|
            segment_str = dump_segment(segment)
            separator = index < separators.size ? separators[index] : ""
            "#{segment_str}#{separator}"
          end.join
        end

        class << self
          private

          # Serializes a single segment to a string.
          #
          # Canonicalizes by merging consecutive empty counts.
          #
          # @param segment [Array] Segment tokens
          # @return [String] Serialized segment
          def dump_segment(segment)
            canonicalize(segment).map(&:to_s).join
          end

          # Canonicalizes a segment by merging consecutive empty counts.
          #
          # @param segment [Array] Segment tokens
          # @return [Array] Canonicalized tokens
          def canonicalize(segment)
            result = []
            pending_empty = 0

            segment.each do |token|
              if ::Integer === token
                pending_empty += token
              else
                if pending_empty > 0
                  result << pending_empty
                  pending_empty = 0
                end
                result << token
              end
            end

            result << pending_empty if pending_empty > 0

            result
          end
        end

        private_class_method :dump_segment, :canonicalize

        freeze
      end
    end
  end
end
