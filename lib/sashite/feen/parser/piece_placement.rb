# frozen_string_literal: true

module Sashite
  module Feen
    module Parser
      module PiecePlacement
        module_function

        # Parse the piece placement field into a Placement value object.
        #
        # Grammar (pragmatic):
        #   placement := rank ( '/' rank | newline rank )*
        #   rank      := ( int | '.' | epin | sep )*
        #   int       := [1-9][0-9]*           # run-length of empty cells
        #   sep       := (',' | whitespace)*
        #   epin      := bracketed_epin | bare_epin
        #   bracketed_epin := '[' ... ']'      # balanced brackets
        #   bare_epin := /[A-Za-z0-9:+\-^~@']+/
        #
        # @param field [String]
        # @return [Sashite::Feen::Placement]
        def parse(field)
          src = String(field)
          raise Error::Syntax, "empty piece placement field" if src.strip.empty?

          ranks = src.split(%r{(?:/|\R)}).map(&:strip)
          raise Error::Syntax, "no ranks in piece placement" if ranks.empty?

          grid  = []
          width = nil

          ranks.each_with_index do |rank, r_idx|
            row = _parse_rank(rank, r_idx)
            width ||= row.length
            raise Error::Bounds, "rank #{r_idx + 1} has zero width" if width.zero?

            if row.length != width
              raise Error::Bounds,
                    "inconsistent rank width at rank #{r_idx + 1} (expected #{width}, got #{row.length})"
            end
            grid << row.freeze
          end

          raise Error::Bounds, "empty grid" if grid.empty?

          Placement.new(grid.freeze)
        end

        # -- internals ---------------------------------------------------------

        # Accepts:
        # - digits => run of empties
        # - '.'    => single empty
        # - '['...']' => EPIN token (balanced)
        # - bare token composed of epin-safe chars
        # - commas/whitespace ignored
        def _parse_rank(rank_str, r_idx)
          i = 0
          n = rank_str.length
          cells = []

          while i < n
            ch = rank_str[i]

            # Skip separators
            if ch == "," || ch =~ /\s/
              i += 1
              next
            end

            # Dot => single empty
            if ch == "."
              cells << nil
              i += 1
              next
            end

            # Number => run of empties
            if /\d/.match?(ch)
              j = i + 1
              j += 1 while j < n && rank_str[j] =~ /\d/
              count = rank_str[i...j].to_i
              raise Error::Count, "empty run must be >= 1 at rank #{r_idx + 1}" if count <= 0

              cells.concat([nil] * count)
              i = j
              next
            end

            # Bracketed EPIN token (balanced)
            if ch == "["
              token, j = _consume_bracketed(rank_str, i, r_idx)
              cells << _parse_epin(token, r_idx, cells.length + 1)
              i = j
              next
            end

            # Bare EPIN token
            token, j = _consume_bare(rank_str, i)
            if token.empty?
              raise Error::Piece,
                    "unexpected character #{rank_str[i].inspect} at rank #{r_idx + 1}, col #{cells.length + 1}"
            end
            cells << _parse_epin(token, r_idx, cells.length + 1)
            i = j
          end

          cells
        end
        module_function :_parse_rank
        private_class_method :_parse_rank

        # Consume a balanced bracketed token starting at index i (where str[i] == '[')
        # Returns [token_without_brackets, next_index_after_closing_bracket]
        def _consume_bracketed(str, i, r_idx)
          j = i + 1
          depth = 1
          while j < str.length && depth.positive?
            case str[j]
            when "[" then depth += 1
            when "]" then depth -= 1
            end
            j += 1
          end
          raise Error::Piece, "unterminated EPIN bracket at rank #{r_idx + 1}, index #{i}" unless depth.zero?

          [str[(i + 1)...(j - 1)], j]
        end
        private_class_method :_consume_bracketed

        # Consume a run of bare EPIN-safe characters.
        # We choose a wide, permissive class to avoid rejecting valid EPINs that include
        # promotions/suffixes: letters, digits, + : - ^ ~ @ '
        def _consume_bare(str, i)
          j = i
          # Autorisés : lettres + modificateurs (+ - : ^ ~ @ ')
          j += 1 while j < str.length && str[j] =~ /[A-Za-z:+\-^~@']/
          [str[i...j], j]
        end

        private_class_method :_consume_bare

        def _parse_epin(token, r_idx, c_idx)
          ::Sashite::Epin.parse(token)
        rescue StandardError => e
          raise Error::Piece,
                "invalid EPIN token at (rank #{r_idx + 1}, col #{c_idx}): #{token.inspect} (#{e.message})"
        end
        private_class_method :_parse_epin
      end
    end
  end
end
