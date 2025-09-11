# frozen_string_literal: true

require "sashite/sin"

module Sashite
  module Feen
    # Immutable styles descriptor for FEEN style/turn field:
    # - first_family  : one-letter SIN family (Symbol, :A..:Z)
    # - second_family : one-letter SIN family (Symbol, :A..:Z)
    # - turn          : :first or :second (uppercase on dumper for the side to move)
    class Styles
      attr_reader :first_family, :second_family, :turn

      VALID_TURNS = %i[first second].freeze

      # @param first_family  [Symbol, String, Sashite::Sin::Identifier]
      # @param second_family [Symbol, String, Sashite::Sin::Identifier]
      # @param turn          [:first, :second]
      def initialize(first_family, second_family, turn)
        @first_family  = _coerce_family(first_family)
        @second_family = _coerce_family(second_family)
        @turn = _coerce_turn(turn)
        freeze
      end

      # Helpers for dumper -----------------------------------------------------

      # Return single-letter uppercase string for first/second family
      def first_letter_uc
        _family_letter_uc(@first_family)
      end

      def second_letter_uc
        _family_letter_uc(@second_family)
      end

      private

      def _coerce_turn(t)
        raise ArgumentError, "turn must be :first or :second, got #{t.inspect}" unless VALID_TURNS.include?(t)

        t
      end

      # Accepts SIN Identifier, Symbol, or String
      # Canonical storage is a Symbol in :A..:Z (uppercase)
      def _coerce_family(x)
        family_sym =
          case x
          when ::Sashite::Sin::Identifier
            x.family
          when Symbol
            x
          else
            s = String(x)
            raise ArgumentError, "invalid SIN family #{x.inspect}" unless s.match?(/\A[A-Za-z]\z/)

            s.upcase.to_sym
          end

        raise ArgumentError, "Family must be :A..:Z, got #{family_sym.inspect}" unless (:A..:Z).cover?(family_sym)

        # Validate via SIN once (ensures family is recognized by sashite-sin)
        raise Error::Style, "Unknown SIN family #{family_sym.inspect}" unless ::Sashite::Sin.valid?(family_sym.to_s)

        family_sym
      end

      def _family_letter_uc(family_sym)
        # Build a canonical SIN identifier to get the letter; side doesn't matter for uc
        ::Sashite::Sin.identifier(family_sym, :first).to_s # uppercase
      end
    end
  end
end
