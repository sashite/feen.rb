# frozen_string_literal: true

module Sashite
  module Feen
    # Field and segment separator constants for FEEN parsing and dumping.
    #
    # FEEN uses two types of separators:
    # - Field separator (space): separates the three main FEEN fields
    # - Segment separator (slash): separates segments within fields
    #
    # @example Splitting FEEN into fields
    #   fields = feen_string.split(Separators::FIELD, -1)
    #   # => [piece_placement, hands, style_turn]
    #
    # @example Splitting hands into first/second
    #   hands = hands_field.split(Separators::SEGMENT, -1)
    #   # => [first_hand, second_hand]
    #
    # @see https://sashite.dev/specs/feen/1.0.0/
    # @api private
    module Separators
      # Separates the three FEEN fields: piece-placement, hands, style-turn.
      #
      # A valid FEEN string contains exactly two field separators,
      # resulting in exactly three fields when split.
      #
      # @return [String] ASCII space character " "
      FIELD = " "

      # Separates segments within fields.
      #
      # Used in:
      # - Piece placement: separates ranks/layers (may be repeated for dimensions)
      # - Hands: separates first player hand from second player hand
      # - Style-turn: separates active style from inactive style
      #
      # @return [String] ASCII forward slash character "/"
      SEGMENT = "/"

      freeze
    end
  end
end
