# frozen_string_literal: true

module Feen
  # Provides methods for sanitizing and validating chess-related notation strings
  module Sanitizer
    # Cleans a FEN (Format for Encounter & Entertainment Notation) string by removing invalid castling rights
    # and en passant targets based on the current position.
    #
    # The method performs the following validations:
    # - Verifies that kings and rooks are in correct positions for castling rights
    # - Verifies that en passant captures are actually possible
    #
    # @param fen_string [String] The FEN string to clean
    # @return [String] A sanitized FEN string with invalid castling rights and en passant targets removed
    # @raise [ArgumentError] If the FEN string is malformed (less than 4 parts)
    #
    # @example Clean a valid FEN string (unchanged)
    #   fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    #   Feen::Sanitizer.clean_fen(fen) # => "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    #
    # @example Remove invalid castling rights when king has moved
    #   fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQ1BNR w KQkq - 0 1"
    #   Feen::Sanitizer.clean_fen(fen) # => "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQ1BNR w kq - 0 1"
    #
    # @example Remove invalid castling rights when rook has moved
    #   fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/1NBQKBNR w KQkq - 0 1"
    #   Feen::Sanitizer.clean_fen(fen) # => "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/1NBQKBNR w Kkq - 0 1"
    #
    # @example Remove invalid en passant target when no capturing pawn exists
    #   fen = "rnbqkbnr/pppp1ppp/8/4p3/8/8/PPPPPPPP/RNBQKBNR w KQkq e6 0 2"
    #   Feen::Sanitizer.clean_fen(fen) # => "rnbqkbnr/pppp1ppp/8/4p3/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 2"
    #
    # @example Keep valid en passant target when capturing is possible
    #   fen = "rnbqkbnr/pppp1ppp/8/3Pp3/8/8/PPP1PPPP/RNBQKBNR w KQkq e6 0 2"
    #   Feen::Sanitizer.clean_fen(fen) # => "rnbqkbnr/pppp1ppp/8/3Pp3/8/8/PPP1PPPP/RNBQKBNR w KQkq e6 0 2"
    def self.clean_fen(fen_string)
      parts = fen_string.strip.split
      return fen_string unless parts.size >= 4

      board, active_color, castling, en_passant, *rest = parts

      # Parse board into a 2D array for easier access
      board_matrix = []
      board.split("/").each do |row|
        current_row = []
        row.each_char do |c|
          if /[1-8]/.match?(c)
            c.to_i.times { current_row << nil }
          else
            current_row << c
          end
        end
        board_matrix << current_row
      end

      # Clean castling rights
      new_castling = castling.dup
      new_castling = clean_castling_rights(new_castling, board_matrix)

      # Clean en passant target
      new_en_passant = clean_en_passant_target(en_passant, board_matrix, active_color)

      ([board, active_color, new_castling, new_en_passant] + rest).join(" ")
    end

    # Validates and cleans castling rights based on the position of kings and rooks
    #
    # @param castling [String] The castling rights string from FEN
    # @param board [Array<Array<String, nil>>] 2D array representing the board
    # @return [String] Cleaned castling rights or "-" if none are valid
    # @api private
    private_class_method def self.clean_castling_rights(castling, board)
      return "-" if castling == "-"

      new_castling = castling.dup

      # White castling rights
      new_castling.gsub!(/[KQ]/, "") unless board[7][4] == "K"
      new_castling.delete!("K") unless board[7][7] == "R"
      new_castling.delete!("Q") unless board[7][0] == "R"

      # Black castling rights
      new_castling.gsub!(/[kq]/, "") unless board[0][4] == "k"
      new_castling.delete!("k") unless board[0][7] == "r"
      new_castling.delete!("q") unless board[0][0] == "r"

      new_castling.empty? ? "-" : new_castling
    end

    # Validates and cleans en passant target based on the position of pawns
    #
    # @param en_passant [String] The en passant target square from FEN
    # @param board [Array<Array<String, nil>>] 2D array representing the board
    # @param active_color [String] The active color ("w" or "b")
    # @return [String] Cleaned en passant target or "-" if invalid
    # @api private
    private_class_method def self.clean_en_passant_target(en_passant, board, active_color)
      return "-" if en_passant == "-"

      file = en_passant[0].ord - "a".ord
      rank = en_passant[1].to_i

      # Validate en passant square coordinates
      return "-" unless file.between?(0, 7) && [3, 6].include?(rank)

      # For white's move (after black pawn double advance)
      if active_color == "w" && rank == 6
        # Check for white pawns on the 5th rank (index 3) that can capture
        return en_passant if [file - 1, file + 1].any? { |f| f.between?(0, 7) && board[3][f] == "P" }
      # For black's move (after white pawn double advance)
      elsif active_color == "b" && rank == 3
        # Check for black pawns on the 4th rank (index 4) that can capture
        return en_passant if [file - 1, file + 1].any? { |f| f.between?(0, 7) && board[4][f] == "p" }
      end

      "-" # Invalid en passant square
    end
  end
end
