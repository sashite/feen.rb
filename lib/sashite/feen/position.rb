# frozen_string_literal: true

module Sashite
  module Feen
    # Immutable aggregate for a FEEN position: placement + hands + styles
    class Position
      attr_reader :placement, :hands, :styles

      # @param placement [Sashite::Feen::Placement]
      # @param hands     [Sashite::Feen::Hands]
      # @param styles    [Sashite::Feen::Styles]
      def initialize(placement, hands, styles)
        unless placement.is_a?(Placement)
          raise TypeError, "placement must be Sashite::Feen::Placement, got #{placement.class}"
        end
        raise TypeError, "hands must be Sashite::Feen::Hands, got #{hands.class}" unless hands.is_a?(Hands)
        raise TypeError, "styles must be Sashite::Feen::Styles, got #{styles.class}" unless styles.is_a?(Styles)

        @placement = placement
        @hands     = hands
        @styles    = styles
        freeze
      end
    end
  end
end
