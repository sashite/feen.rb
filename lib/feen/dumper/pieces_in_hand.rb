# frozen_string_literal: true

module Feen
  module Dumper
    # A module that serializes pieces in hand lists into a string.
    module PiecesInHand
      # Serialize pieces in hand lists into a string.
      #
      # @param piece_names [Array] A list of pieces in hand.
      #
      # @example Dump a list of pieces in hand
      #   dump(["S", "b", "g", "g", "g", "g", "n", "n", "n", "n", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "r", "r", "s"])
      #   # => "S,b,g*4,n*4,p*17,r*2,s"
      #
      # @example Dump an empty list of pieces in hand
      #   dump([])
      #   # => nil
      #
      # @return [String, nil] A serialized list of pieces in hand.
      def self.dump(piece_names)
        return if piece_names.empty?

        hash = piece_names.group_by(&:itself).transform_values(&:count)
        hash.map { |k, v| v > 1 ? "#{k}*#{v}" : k }.sort.join(",")
      end
    end
  end
end
