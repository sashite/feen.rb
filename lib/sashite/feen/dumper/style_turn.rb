# frozen_string_literal: true

require_relative "../shared/separators"

module Sashite
  module Feen
    module Dumper
      # Serializer for the FEEN Style-Turn field (Field 3).
      #
      # Converts a Qi position's style and turn accessors into the canonical
      # FEEN Style-Turn string:
      #
      #   <ACTIVE-STYLE>/<INACTIVE-STYLE>
      #
      # The active style (left of /) corresponds to the player whose
      # turn it is. The mapping from Qi accessors is:
      #
      # - turn :first  → active = first_player_style,  inactive = second_player_style
      # - turn :second → active = second_player_style, inactive = first_player_style
      #
      # @example First player to move
      #   StyleTurn.dump("C", "c", :first)
      #   # => "C/c"
      #
      # @example Second player to move
      #   StyleTurn.dump("C", "c", :second)
      #   # => "c/C"
      #
      # @example Cross-style game
      #   StyleTurn.dump("C", "s", :first)
      #   # => "C/s"
      #
      # @see https://sashite.dev/specs/feen/1.0.0/
      # @api private
      module StyleTurn
        # Serializes styles and turn to a FEEN Style-Turn field string.
        #
        # @param first_player_style [String] SIN token for the first player
        # @param second_player_style [String] SIN token for the second player
        # @param turn [Symbol] :first or :second
        # @return [String] Canonical Style-Turn field string
        def self.dump(first_player_style, second_player_style, turn)
          if turn == :first
            "#{first_player_style}#{Separators::SEGMENT}#{second_player_style}"
          else
            "#{second_player_style}#{Separators::SEGMENT}#{first_player_style}"
          end
        end

        freeze
      end
    end
  end
end
