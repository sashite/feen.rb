# frozen_string_literal: true

module Sashite
  module Feen
    module Dumper
      # Dumper for the style-turn field (third field of FEEN).
      #
      # Converts a Styles object into its FEEN string representation,
      # encoding game styles and indicating the active player.
      #
      # @see https://sashite.dev/specs/feen/1.0.0/
      module StyleTurn
        # Style separator in style-turn field.
        STYLE_SEPARATOR = "/"

        # Dump a Styles object into its FEEN style-turn string.
        #
        # Formats the active and inactive player styles with the active
        # player's style appearing first. The case of each style identifier
        # indicates which player uses it (uppercase = first player,
        # lowercase = second player).
        #
        # @param styles [Styles] The styles object with active and inactive styles
        # @return [String] FEEN style-turn field string
        #
        # @example Chess game, white to move
        #   dump(styles)
        #   # => "C/c"
        #
        # @example Chess game, black to move
        #   dump(styles)
        #   # => "c/C"
        #
        # @example Cross-style game, first player to move
        #   dump(styles)
        #   # => "C/m"
        def self.dump(styles)
          "#{styles.active}#{STYLE_SEPARATOR}#{styles.inactive}"
        end
      end
    end
  end
end
