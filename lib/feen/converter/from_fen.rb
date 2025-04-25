# frozen_string_literal: true

module Feen
  module Converter
    module FromFen
      # Constants
      WHITE_TURN = "CHESS/chess"
      BLACK_TURN = "chess/CHESS"
      NO_PIECES_IN_HAND = "-"
      EN_PASSANT_NONE = "-"

      # Castling-related constants
      CASTLING_SUFFIX_BOTH = "="
      CASTLING_SUFFIX_KINGSIDE = ">"
      CASTLING_SUFFIX_QUEENSIDE = "<"
      CASTLING_SUFFIX_NONE = ""

      # Piece identifiers
      WHITE_KING = "K"
      BLACK_KING = "k"
      WHITE_PAWN = "P"
      BLACK_PAWN = "p"

      # Board indices
      WHITE_KING_STARTING_ROW = 7
      BLACK_KING_STARTING_ROW = 0

      # Converts a FEN string to a FEEN string for chess positions
      # @param fen_string [String] Standard FEN notation string for chess
      # @return [String] Equivalent FEEN notation string
      # @raise [ArgumentError] If the FEN string is invalid
      def self.call(fen_string)
        unless fen_string.is_a?(String) && !fen_string.strip.empty?
          raise ArgumentError, "FEN must be a non-empty string"
        end

        parts = fen_string.strip.split
        raise ArgumentError, "Invalid FEN format: expected at least 4 fields" unless parts.size >= 4

        placement_fen, active_color, castling, en_passant = parts[0..3]
        board = parse_board(placement_fen)

        apply_castling!(board, castling)
        apply_en_passant!(board, en_passant)

        piece_placement = format_board(board)
        games_turn = active_color == "w" ? WHITE_TURN : BLACK_TURN

        "#{piece_placement} #{games_turn} #{NO_PIECES_IN_HAND}"
      end

      # Parses the FEN piece placement into a 2D board array
      # @param fen_placement [String] FEN piece placement string
      # @return [Array<Array<String, nil>>] 2D array representing the board
      def self.parse_board(fen_placement)
        fen_placement.split("/").map do |row|
          cells = []
          row.each_char do |char|
            if /[1-8]/.match?(char)
              cells.concat([nil] * char.to_i)
            else
              cells << char
            end
          end
          cells
        end
      end

      # Applies castling rights to kings on the board
      # @param board [Array<Array<String, nil>>] 2D board array
      # @param castling [String] FEN castling rights string
      # @return [void]
      def self.apply_castling!(board, castling)
        return if castling == EN_PASSANT_NONE

        # Determine suffix for each king
        wk_suffix = determine_castling_suffix(castling.include?("K"), castling.include?("Q"))
        bk_suffix = determine_castling_suffix(castling.include?("k"), castling.include?("q"))

        # Apply the suffixes to the kings
        apply_king_suffix!(board, WHITE_KING, wk_suffix)
        apply_king_suffix!(board, BLACK_KING, bk_suffix)
      end

      # Applies a castling suffix to a king on the board
      # @param board [Array<Array<String, nil>>] 2D board array
      # @param king_char [String] King character ('K' or 'k')
      # @param suffix [String] Castling suffix to apply
      # @return [void]
      def self.apply_king_suffix!(board, king_char, suffix)
        return if suffix.empty?

        board.each_with_index do |row, r|
          row.each_with_index do |cell, c|
            board[r][c] = "#{king_char}#{suffix}" if cell == king_char
          end
        end
      end

      # Determines the appropriate castling suffix based on kingside and queenside rights
      # @param kingside [Boolean] Whether kingside castling is allowed
      # @param queenside [Boolean] Whether queenside castling is allowed
      # @return [String] The castling suffix
      def self.determine_castling_suffix(kingside, queenside)
        if kingside && queenside
          CASTLING_SUFFIX_BOTH
        elsif kingside
          CASTLING_SUFFIX_KINGSIDE
        elsif queenside
          CASTLING_SUFFIX_QUEENSIDE
        else
          CASTLING_SUFFIX_NONE
        end
      end

      # Applies en passant rights to pawns on the board
      # @param board [Array<Array<String, nil>>] 2D board array
      # @param en_passant [String] FEN en passant target square
      # @return [void]
      def self.apply_en_passant!(board, en_passant)
        return if en_passant == EN_PASSANT_NONE

        col = en_passant[0].ord - "a".ord
        row = 8 - en_passant[1].to_i

        if row == 2 # White just moved: check black pawns on row 3
          apply_en_passant_for_pawn!(board, 3, col, BLACK_PAWN)
        elsif row == 5 # Black just moved: check white pawns on row 4
          apply_en_passant_for_pawn!(board, 4, col, WHITE_PAWN)
        end
      end

      # Applies en passant rights to pawns at a specific row and column
      # @param board [Array<Array<String, nil>>] 2D board array
      # @param pawn_row [Integer] Row where pawns can capture en passant
      # @param target_col [Integer] Column of the pawn that moved two squares
      # @param pawn_char [String] Pawn character ('P' or 'p')
      # @return [void]
      def self.apply_en_passant_for_pawn!(board, pawn_row, target_col, pawn_char)
        [-1, 1].each do |dx|
          x = target_col + dx

          next unless x.between?(0, 7) && board[pawn_row][x] == pawn_char

          # Determine the en passant suffix based on relative position
          suffix = dx == -1 ? ">" : "<"
          board[pawn_row][x] = "#{pawn_char}#{suffix}"
        end
      end

      # Formats the board array back into FEN piece placement
      # @param board [Array<Array<String, nil>>] 2D board array
      # @return [String] FEN piece placement string
      def self.format_board(board)
        board.map do |row|
          format_row(row)
        end.join("/")
      end

      # Formats a row of the board into FEN notation
      # @param row [Array<String, nil>] Row of the board
      # @return [String] FEN notation for this row
      def self.format_row(row)
        row.chunk_while { |a, b| a.nil? == b.nil? }.map do |chunk|
          chunk.first.nil? ? chunk.size.to_s : chunk.join
        end.join
      end
    end
  end
end
