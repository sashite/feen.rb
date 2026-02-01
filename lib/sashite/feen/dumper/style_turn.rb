# frozen_string_literal: true

require_relative "../shared/separators"

module Sashite
  module Feen
    module Dumper
      # Serializer for FEEN Style-Turn field (Field 3).
      #
      # Converts structured style-turn data into a canonical FEEN string.
      # Format: <ACTIVE-STYLE>/<INACTIVE-STYLE>
      #
      # Input format:
      # - active: The active player's style (must respond to #to_s)
      # - inactive: The inactive player's style (must respond to #to_s)
      #
      # @example First player to move (same style)
      #   Dumper::StyleTurn.dump(active: "C", inactive: "c")
      #   # => "C/c"
      #
      # @example Second player to move (same style)
      #   Dumper::StyleTurn.dump(active: "c", inactive: "C")
      #   # => "c/C"
      #
      # @example Cross-style game
      #   Dumper::StyleTurn.dump(active: "C", inactive: "s")
      #   # => "C/s"
      #
      # @see https://sashite.dev/specs/feen/1.0.0/
      # @api private
      module StyleTurn
        # Serializes style-turn data to a FEEN string.
        #
        # @param active [#to_s] Active player's style
        # @param inactive [#to_s] Inactive player's style
        # @return [String] Canonical FEEN style-turn string
        def self.dump(active:, inactive:)
          "#{active}#{Separators::SEGMENT}#{inactive}"
        end

        freeze
      end
    end
  end
end
