# frozen_string_literal: true

require_relative "../shared/separators"
require_relative "hand"

module Sashite
  module Feen
    module Dumper
      # Serializer for FEEN Hands field (Field 2).
      #
      # Converts structured hands data into a canonical FEEN string.
      # Format: <FIRST-HAND>/<SECOND-HAND>
      #
      # Input format:
      # - first: Array of hand items for first player
      # - second: Array of hand items for second player
      # Each item is a Hash with :piece and :count keys.
      #
      # @example Empty hands
      #   Dumper::Hands.dump(first: [], second: [])
      #   # => "/"
      #
      # @example First player has pieces
      #   Dumper::Hands.dump(
      #     first: [{ piece: "P", count: 2 }, { piece: "N", count: 1 }],
      #     second: []
      #   )
      #   # => "2PN/"
      #
      # @example Both players have pieces
      #   Dumper::Hands.dump(
      #     first: [{ piece: "B", count: 3 }],
      #     second: [{ piece: "p", count: 2 }]
      #   )
      #   # => "3B/2p"
      #
      # @see https://sashite.dev/specs/feen/1.0.0/
      # @api private
      module Hands
        # Serializes hands data to a FEEN string.
        #
        # @param first [Array<Hash>] First player's hand items
        # @param second [Array<Hash>] Second player's hand items
        # @return [String] Canonical FEEN hands string
        def self.dump(first:, second:)
          first_str = Hand.dump(first)
          second_str = Hand.dump(second)

          "#{first_str}#{Separators::SEGMENT}#{second_str}"
        end

        freeze
      end
    end
  end
end
