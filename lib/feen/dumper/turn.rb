# frozen_string_literal: true

module FEEN
  module Dumper
    # The turn class.
    class Turn
      TOPSIDE = {
        false => 'B',
        true => 't'
      }.freeze

      # @param is_topside [Boolean] Is topside the player who must play?
      def initialize(is_topside)
        raise ::TypeError, is_topside.class.inspect unless TOPSIDE.key?(is_topside)

        @is_topside = is_topside
      end

      # @return [String] The char representing the turn.
      def to_s
        TOPSIDE.fetch(@is_topside)
      end
    end
  end
end
