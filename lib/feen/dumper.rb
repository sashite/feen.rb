# frozen_string_literal: true

require_relative File.join("dumper", "games_turn")
require_relative File.join("dumper", "piece_placement")
require_relative File.join("dumper", "pieces_in_hand")

module Feen
  # Module responsible for converting internal data structures to FEEN notation strings
  module Dumper
    # Converts a complete position data structure to a FEEN string
    #
    # @param position [Hash] Hash containing the complete position data
    # @option position [Array] :piece_placement Board position data
    # @option position [Hash] :games_turn Games and turn data
    # @option position [Array<Hash>] :pieces_in_hand Pieces in hand data
    # @return [String] Complete FEEN string representation
    def self.dump(position)
      validate_position(position)

      [
        PiecePlacement.dump(position[:piece_placement]),
        GamesTurn.dump(position[:games_turn]),
        PiecesInHand.dump(position[:pieces_in_hand])
      ].join(" ")
    end

    # Validates the position data structure
    #
    # @param position [Hash] Position data to validate
    # @raise [ArgumentError] If the position data is invalid
    # @return [void]
    def self.validate_position(position)
      raise ArgumentError, "Position must be a Hash, got #{position.class}" unless position.is_a?(Hash)

      # Check for required keys
      required_keys = %i[piece_placement games_turn pieces_in_hand]
      missing_keys = required_keys - position.keys

      raise ArgumentError, "Missing required keys in position: #{missing_keys.join(', ')}" unless missing_keys.empty?

      # Validate types of values
      unless position[:piece_placement].is_a?(Array)
        raise ArgumentError, "piece_placement must be an Array, got #{position[:piece_placement].class}"
      end

      unless position[:games_turn].is_a?(Hash)
        raise ArgumentError, "games_turn must be a Hash, got #{position[:games_turn].class}"
      end

      return if position[:pieces_in_hand].is_a?(Array)

      raise ArgumentError, "pieces_in_hand must be an Array, got #{position[:pieces_in_hand].class}"
    end
  end
end
