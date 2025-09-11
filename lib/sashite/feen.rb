# frozen_string_literal: true

# Public API for FEEN (Forsyth–Edwards Enhanced Notation)
# - Pure functions, no global state
# - Immutable value objects
# - Delegates parsing/dumping to dedicated components

require "sashite/epin"
require "sashite/sin"

require_relative "feen/error"
require_relative "feen/position"
require_relative "feen/placement"
require_relative "feen/hands"
require_relative "feen/styles"
require_relative "feen/ordering"
require_relative "feen/parser"
require_relative "feen/dumper"

module Sashite
  module Feen
    class << self
      # Parse a FEEN string into an immutable Position object.
      #
      # @param feen [String]
      # @return [Sashite::Feen::Position]
      def parse(feen)
        s = String(feen).strip
        raise Error::Syntax, "empty FEEN input" if s.empty?

        Parser.parse(s).freeze
      rescue ArgumentError => e
        # Normalise en Syntax pour surface d'erreurs plus propre
        raise Error::Syntax, e.message
      end

      # Validate a FEEN string.
      #
      # @param feen [String]
      # @return [Boolean]
      def valid?(feen)
        parse(feen)
        true
      rescue Error::Validation, Error::Syntax, Error::Piece, Error::Style, Error::Count, Error::Bounds
        false
      end

      # Dump a Position to its canonical FEEN string.
      #
      # @param position [Sashite::Feen::Position, String]  # String => parse puis dump
      # @return [String] canonical FEEN
      def dump(position)
        pos = _coerce_position(position)
        Dumper.dump(pos).dup.freeze
      end

      # Canonicalize a FEEN string (parse → dump).
      #
      # @param feen [String]
      # @return [String] canonical FEEN
      def normalize(feen)
        dump(parse(feen))
      end

      # Build a Position from its three FEEN fields.
      #
      # Each argument accepts either a String (parsed by its field parser)
      # or the corresponding value-object (Placement/Hands/Styles).
      #
      # @param piece_placement [String, Sashite::Feen::Placement]
      # @param pieces_in_hand  [String, Sashite::Feen::Hands]
      # @param style_turn      [String, Sashite::Feen::Styles]
      # @return [Sashite::Feen::Position]
      def build(piece_placement:, pieces_in_hand:, style_turn:)
        placement = _coerce_component(Placement, Parser::PiecePlacement, piece_placement)
        hands     = _coerce_component(Hands,     Parser::PiecesInHand,   pieces_in_hand)
        styles    = _coerce_component(Styles,    Parser::StyleTurn,      style_turn)

        Position.new(placement, hands, styles).freeze
      end

      private

      # -- helpers -------------------------------------------------------------

      def _coerce_position(obj)
        return obj if obj.is_a?(Position)
        return parse(obj) if obj.is_a?(String)

        raise TypeError, "expected Sashite::Feen::Position or FEEN String, got #{obj.class}"
      end

      def _coerce_component(klass, field_parser_mod, value)
        case value
        when klass
          value
        when String
          field_parser_mod.parse(value)
        else
          raise TypeError,
                "expected #{klass} or String for #{klass.name.split('::').last.downcase}, got #{value.class}"
        end
      end
    end
  end
end
