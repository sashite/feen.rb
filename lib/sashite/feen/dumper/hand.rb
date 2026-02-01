# frozen_string_literal: true

module Sashite
  module Feen
    module Dumper
      # Serializer for a single hand within FEEN Hands field.
      #
      # Converts an array of hand items into a canonical FEEN string.
      # Items are expected to be already in canonical order.
      #
      # Input format:
      # - items: Array of Hashes with :piece and :count keys
      #   - :piece must respond to #to_s
      #   - :count is an Integer (1 = implicit, ≥2 = explicit prefix)
      #
      # @example Empty hand
      #   Dumper::Hand.dump([])
      #   # => ""
      #
      # @example Single piece
      #   Dumper::Hand.dump([{ piece: "P", count: 1 }])
      #   # => "P"
      #
      # @example Multiple pieces with counts
      #   Dumper::Hand.dump([
      #     { piece: "B", count: 3 },
      #     { piece: "P", count: 2 },
      #     { piece: "N", count: 1 }
      #   ])
      #   # => "3B2PN"
      #
      # @see https://sashite.dev/specs/feen/1.0.0/
      # @api private
      module Hand
        # Empty string for count = 1 (implicit).
        EMPTY_STRING = ""

        # Serializes hand items to a FEEN string.
        #
        # @param items [Array<Hash>] Hand items with :piece and :count keys
        # @return [String] Canonical FEEN hand string
        def self.dump(items)
          items.map do |item|
            dump_item(item[:piece], item[:count])
          end.join
        end

        class << self
          private

          # Serializes a single hand item.
          #
          # @param piece [#to_s] The piece identifier
          # @param count [Integer] The count (1 = no prefix, ≥2 = prefix)
          # @return [String] Serialized hand item
          def dump_item(piece, count)
            count_str = count > 1 ? count.to_s : EMPTY_STRING
            "#{count_str}#{piece}"
          end
        end

        private_class_method :dump_item

        freeze
      end
    end
  end
end
