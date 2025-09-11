# frozen_string_literal: true

module Sashite
  module Feen
    module Dumper
      module StyleTurn
        # Separator between turn and styles
        TURN_STYLES_SEPARATOR = ";"
        # Separator between multiple style tokens
        STYLES_SEPARATOR = ","

        module_function

        # Dump the style/turn field (e.g., "w", "b;rule1,variantX")
        #
        # Canonicalization:
        #   - styles sorted lexicographically by SIN token
        #
        # @param styles [Sashite::Feen::Styles]
        # @return [String]
        def dump(styles)
          st = _coerce_styles(styles)

          turn_str = _dump_turn(st.turn)

          return turn_str if st.list.nil? || st.list.empty?

          tokens = st.list.map do |sin_value|
            ::Sashite::Sin.dump(sin_value)
          rescue StandardError => e
            raise Error::Style, "invalid SIN value in styles: #{e.message}"
          end

          tokens.sort!
          "#{turn_str}#{TURN_STYLES_SEPARATOR}#{tokens.join(STYLES_SEPARATOR)}"
        end

        # -- internals ---------------------------------------------------------

        def _dump_turn(turn)
          case turn
          when :first  then "w"
          when :second then "b"
          else
            raise Error::Style, "invalid turn symbol #{turn.inspect}"
          end
        end
        private_class_method :_dump_turn

        def _coerce_styles(obj)
          return obj if obj.is_a?(Styles)

          raise TypeError, "expected Sashite::Feen::Styles, got #{obj.class}"
        end
        private_class_method :_coerce_styles
      end
    end
  end
end
