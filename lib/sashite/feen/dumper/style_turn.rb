# frozen_string_literal: true

module Sashite
  module Feen
    module Dumper
      # Serializer for the FEEN Style-Turn field (Field 3).
      #
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
            "#{first_player_style}/#{second_player_style}"
          else
            "#{second_player_style}/#{first_player_style}"
          end
        end

        freeze
      end
    end
  end
end
