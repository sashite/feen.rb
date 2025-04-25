# frozen_string_literal: true

require_relative File.join("parser", "games_turn")
require_relative File.join("parser", "piece_placement")
require_relative File.join("parser", "pieces_in_hand")

module Feen
  # Module responsible for parsing FEEN notation strings into internal data structures
  module Parser
    # Parses a complete FEEN string into a structured representation
    #
    # @param feen_string [String] Complete FEEN notation string
    # @return [Hash] Hash containing the parsed position data
    # @raise [ArgumentError] If the FEEN string is invalid
    def self.parse(feen_string)
      validate_feen_string(feen_string)

      # Split the FEEN string into its three fields
      fields = feen_string.strip.split(/\s+/)

      raise ArgumentError, "Invalid FEEN format: expected 3 fields, got #{fields.size}" unless fields.size == 3

      # Parse each field using the appropriate submodule
      piece_placement = PiecePlacement.parse(fields[0])
      games_turn = GamesTurn.parse(fields[1])
      pieces_in_hand = PiecesInHand.parse(fields[2])

      # Return a structured representation of the position
      {
        piece_placement: piece_placement,
        games_turn:      games_turn,
        pieces_in_hand:  pieces_in_hand
      }
    end

    # Validates the FEEN string for basic format
    #
    # @param feen_string [String] FEEN string to validate
    # @raise [ArgumentError] If the FEEN string is fundamentally invalid
    # @return [void]
    def self.validate_feen_string(feen_string)
      raise ArgumentError, "FEEN must be a string, got #{feen_string.class}" unless feen_string.is_a?(String)

      raise ArgumentError, "FEEN string cannot be empty" if feen_string.empty?

      # Check for at least two spaces (three fields)
      return unless feen_string.count(" ") < 2

      raise ArgumentError, "Invalid FEEN format: must contain at least two spaces separating three fields"
    end
  end
end
