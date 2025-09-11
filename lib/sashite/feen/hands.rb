# frozen_string_literal: true

module Sashite
  module Feen
    # Immutable multiset of pieces-in-hand, keyed by EPIN value (as returned by Sashite::Epin.parse)
    class Hands
      attr_reader :map

      # @param map [Hash<any, Integer>] counts per EPIN value
      def initialize(map)
        raise TypeError, "hands map must be a Hash, got #{map.class}" unless map.is_a?(Hash)

        # Coerce counts to Integer and validate
        coerced = {}
        map.each do |k, v|
          c = Integer(v)
          raise Error::Count, "hand count must be >= 0, got #{c}" if c.negative?
          next if c.zero? # normalize: skip zeros

          coerced[k] = c
        end

        # Freeze shallowly (keys may already be complex frozen EPIN values)
        @map = coerced.each_with_object({}) { |(k, v), h| h[k] = v }.freeze
        freeze
      end

      # Convenience
      def empty?
        @map.empty?
      end

      def each(&)
        @map.each(&)
      end
    end
  end
end
