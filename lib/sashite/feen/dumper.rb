# frozen_string_literal: true

require_relative "dumper/piece_placement"
require_relative "dumper/pieces_in_hand"
require_relative "dumper/style_turn"

module Sashite
  module Feen
    # Dumper for FEEN (Forsyth–Edwards Enhanced Notation) positions.
    #
    # Converts a Position object into its canonical FEEN string representation
    # by delegating serialization to specialized dumpers for each component.
    #
    # @see https://sashite.dev/specs/feen/1.0.0/
    module Dumper
      # Field separator in FEEN notation.
      FIELD_SEPARATOR = " "

      # Number of fields in a FEEN string.
      FIELD_COUNT = 3

      # Dump a Position object into its canonical FEEN string representation.
      #
      # Generates a deterministic FEEN string from a position object. The same
      # position will always produce the same canonical string.
      #
      # @param position [Position] A position object with placement, hands, and styles
      # @return [String] Canonical FEEN notation string
      #
      # @example Dump a position to FEEN
      #   feen_string = Dumper.dump(position)
      #   # => "+rnbq+kbn+r/+p+p+p+p+p+p+p+p/8/8/8/8/+P+P+P+P+P+P+P+P/+RNBQ+KBN+R / C/c"
      def self.dump(position)
        fields = [
          Dumper::PiecePlacement.dump(position.placement),
          Dumper::PiecesInHand.dump(position.hands),
          Dumper::StyleTurn.dump(position.styles)
        ]

        join_fields(fields)
      end

      # Join the three FEEN fields into a single string.
      #
      # Combines the piece placement, pieces in hand, and style-turn fields
      # with the field separator.
      #
      # @param fields [Array<String>] Array of three field strings
      # @return [String] Complete FEEN string
      #
      # @example Join three fields
      #   join_fields(["rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR", "/", "C/c"])
      #   # => "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c"
      private_class_method def self.join_fields(fields)
        fields.join(FIELD_SEPARATOR)
      end
    end
  end
end
