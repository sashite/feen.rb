# frozen_string_literal: true

module Sashite
  module Feen
    module Dumper
      # Dumper for the pieces-in-hand field (second field of FEEN).
      #
      # Converts a Hands object into its FEEN string representation,
      # encoding captured pieces held by each player in canonical sorted order.
      #
      # @see https://sashite.dev/specs/feen/1.0.0/
      module PiecesInHand
        # Player separator in pieces-in-hand field.
        PLAYER_SEPARATOR = "/"

        # Dump a Hands object into its FEEN pieces-in-hand string.
        #
        # Generates canonical representation with pieces sorted according to
        # FEEN ordering rules: by quantity (descending), base letter (ascending),
        # case (uppercase first), prefix (-, +, none), and suffix (none, ').
        #
        # @param hands [Hands] The hands object containing pieces for both players
        # @return [String] FEEN pieces-in-hand field string
        #
        # @example No pieces in hand
        #   dump(hands)
        #   # => "/"
        #
        # @example First player has pieces
        #   dump(hands)
        #   # => "2P/p"
        #
        # @example Both players have pieces
        #   dump(hands)
        #   # => "RBN/2p"
        def self.dump(hands)
          first_player_str = dump_player_pieces(hands.first_player)
          second_player_str = dump_player_pieces(hands.second_player)

          "#{first_player_str}#{PLAYER_SEPARATOR}#{second_player_str}"
        end

        # Dump pieces for a single player.
        #
        # Groups identical pieces, counts them, sorts canonically, and formats
        # with count prefix when needed (e.g., "3P" for three pawns).
        #
        # @param pieces [Array] Array of piece objects for one player
        # @return [String] Formatted piece string (empty if no pieces)
        #
        # @example Single piece types
        #   dump_player_pieces([pawn1, pawn2, pawn3, rook1])
        #   # => "3PR"
        #
        # @example Empty hand
        #   dump_player_pieces([])
        #   # => ""
        private_class_method def self.dump_player_pieces(pieces)
          return "" if pieces.empty?

          grouped = group_pieces(pieces)
          sorted = sort_grouped_pieces(grouped)
          format_pieces(sorted)
        end

        # Group identical pieces and count occurrences.
        #
        # @param pieces [Array] Array of piece objects
        # @return [Hash] Hash mapping piece strings to counts
        #
        # @example
        #   group_pieces([pawn1, pawn2, rook1])
        #   # => {"P" => 2, "R" => 1}
        private_class_method def self.group_pieces(pieces)
          pieces.group_by(&:to_s).transform_values(&:size)
        end

        # Sort grouped pieces according to FEEN canonical ordering.
        #
        # Sorting rules (in order of precedence):
        # 1. By quantity (descending) - most pieces first
        # 2. By base letter (ascending, case-insensitive)
        # 3. By case - uppercase before lowercase
        # 4. By prefix - "-", "+", then none
        # 5. By suffix - none, then "'"
        #
        # @param grouped [Hash] Hash of piece strings to counts
        # @return [Array<Array>] Sorted array of [piece_string, count] pairs
        #
        # @example
        #   sort_grouped_pieces({"p" => 2, "P" => 3, "R" => 1, "+K" => 1, "K'" => 1})
        #   # => [["+K", 1], ["K'", 1], ["P", 3], ["p", 2], ["R", 1]]
        private_class_method def self.sort_grouped_pieces(grouped)
          grouped.sort_by do |piece_str, count|
            [
              -count,                              # Quantity (descending)
              extract_base_letter(piece_str),      # Base letter (ascending)
              piece_str.match?(/[A-Z]/) ? 0 : 1,   # Case (uppercase first)
              prefix_order(piece_str),             # Prefix order
              piece_str.end_with?("'") ? 1 : 0     # Suffix order (none first)
            ]
          end
        end

        # Extract base letter from piece string (without modifiers).
        #
        # @param piece_str [String] EPIN piece string
        # @return [String] Uppercase base letter
        #
        # @example
        #   extract_base_letter("+K'")  # => "K"
        #   extract_base_letter("-p")   # => "P"
        private_class_method def self.extract_base_letter(piece_str)
          piece_str.gsub(/[+\-']/, "").upcase
        end

        # Determine prefix sorting order.
        #
        # @param piece_str [String] EPIN piece string
        # @return [Integer] Sort order (0 for "-", 1 for "+", 2 for none)
        #
        # @example
        #   prefix_order("-K")  # => 0
        #   prefix_order("+K")  # => 1
        #   prefix_order("K")   # => 2
        private_class_method def self.prefix_order(piece_str)
          return 0 if piece_str.start_with?("-")
          return 1 if piece_str.start_with?("+")

          2
        end

        # Format sorted pieces with count prefixes.
        #
        # @param sorted [Array<Array>] Sorted array of [piece_string, count] pairs
        # @return [String] Formatted piece string
        #
        # @example
        #   format_pieces([["P", 3], ["R", 1], ["p", 2]])
        #   # => "3PR2p"
        private_class_method def self.format_pieces(sorted)
          sorted.map do |piece_str, count|
            count > 1 ? "#{count}#{piece_str}" : piece_str
          end.join
        end
      end
    end
  end
end
