# frozen_string_literal: true

require_relative "../shared/separators"

module Sashite
  module Feen
    module Dumper
      # Serializer for the FEEN Style-Turn field (Field 3).
      #
      # Converts Qi::Position's styles and turn into the canonical
      # FEEN Style-Turn string:
      #
      #   <ACTIVE-STYLE>/<INACTIVE-STYLE>
      #
      # The active style (left of /) corresponds to the player whose
      # turn it is. The mapping from Qi fields is:
      #
      # - turn :first  → active = styles[:first],  inactive = styles[:second]
      # - turn :second → active = styles[:second], inactive = styles[:first]
      #
      # @example First player to move
      #   StyleTurn.dump({ first: "C", second: "c" }, :first)
      #   # => "C/c"
      #
      # @example Second player to move
      #   StyleTurn.dump({ first: "C", second: "c" }, :second)
      #   # => "c/C"
      #
      # @example Cross-style game
      #   StyleTurn.dump({ first: "C", second: "s" }, :first)
      #   # => "C/s"
      #
      # @see https://sashite.dev/specs/feen/1.0.0/
      # @api private
      module StyleTurn
        # Serializes styles and turn to a FEEN Style-Turn field string.
        #
        # @param styles [Hash] Hash with :first and :second SIN token strings
        # @param turn [Symbol] :first or :second
        # @return [String] Canonical Style-Turn field string
        def self.dump(styles, turn)
          if turn == :first
            "#{styles[:first]}#{Separators::SEGMENT}#{styles[:second]}"
          else
            "#{styles[:second]}#{Separators::SEGMENT}#{styles[:first]}"
          end
        end

        freeze
      end
    end
  end
end
