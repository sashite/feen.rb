# frozen_string_literal: true

module Feen
  module Converter
    module ToFen
      # Constants for game types and formats
      WHITE_ACTIVE = "CHESS/chess"
      BLACK_ACTIVE = "chess/CHESS"

      # Constants for FEN components
      NO_EN_PASSANT = "-"
      NO_CASTLING = "-"
      HALF_MOVE_DEFAULT = "0"
      FULL_MOVE_DEFAULT = "1"

      # Castling-related constants
      WHITE_KINGSIDE = "K"
      WHITE_QUEENSIDE = "Q"
      BLACK_KINGSIDE = "k"
      BLACK_QUEENSIDE = "q"

      # En passant constants
      EN_PASSANT_WHITE_RANK = "3"
      EN_PASSANT_BLACK_RANK = "6"

      # Converts a FEEN string to a standard FEN string for chess positions
      # @param feen_string [String] FEEN notation string
      # @return [String] Standard FEN notation string
      # @raise [ArgumentError] If the FEEN string is invalid or not supported
      def self.call(feen_string)
        # Validate input
        unless feen_string.is_a?(String) && !feen_string.strip.empty?
          raise ArgumentError, "FEEN must be a non-empty string"
        end

        # Split into components
        parts = feen_string.strip.split
        raise ArgumentError, "Invalid FEEN format: expected 3 fields" unless parts.size == 3

        piece_placement, games_turn, = parts

        # Verify game type is supported
        unless [WHITE_ACTIVE, BLACK_ACTIVE].include?(games_turn)
          raise ArgumentError, "Only CHESS/chess FEEN formats are supported"
        end

        # Extract FEN components
        castling_rights = extract_castling_rights(piece_placement)
        en_passant = extract_en_passant(piece_placement)
        fen_board = convert_board_to_fen(piece_placement)
        active_color = games_turn.start_with?("CHESS") ? "w" : "b"

        # Construct FEN string
        "#{fen_board} #{active_color} #{castling_rights} #{en_passant} #{HALF_MOVE_DEFAULT} #{FULL_MOVE_DEFAULT}"
      end

      # Converts the FEEN board representation to FEN format by removing special markings
      # @param piece_placement [String] FEEN piece placement string
      # @return [String] FEN piece placement string
      def self.convert_board_to_fen(piece_placement)
        piece_placement.split("/").map do |row|
          # Remove castling suffixes from kings
          row_without_king_suffix = row.gsub(/([Kk])([=<>])/) { Regexp.last_match(1) }
          # Remove en passant suffixes from pawns
          row_without_suffixes = row_without_king_suffix.gsub(/([Pp])([<>])/) { Regexp.last_match(1) }
          # Ensure only single character pieces (in case of promoted pieces with prefixes)
          row_without_suffixes.gsub(/\d+|\w/) { |s| /\d/.match?(s) ? s : s[0] }
        end.join("/")
      end

      # Extracts castling rights from FEEN piece placement
      # @param piece_placement [String] FEEN piece placement string
      # @return [String] FEN castling rights component
      def self.extract_castling_rights(piece_placement)
        castling = ""

        # White castling rights - always in uppercase and first
        piece_placement.split("/").each do |row|
          castling += WHITE_KINGSIDE if row.include?("K>") || row.include?("K=")
          castling += WHITE_QUEENSIDE if row.include?("K<") || row.include?("K=")
        end

        # Black castling rights - always in lowercase and after white
        piece_placement.split("/").each do |row|
          castling += BLACK_KINGSIDE if row.include?("k>") || row.include?("k=")
          castling += BLACK_QUEENSIDE if row.include?("k<") || row.include?("k=")
        end

        castling.empty? ? NO_CASTLING : castling
      end

      # Extracts en passant target square from FEEN piece placement
      # @param piece_placement [String] FEEN piece placement string
      # @return [String] FEN en passant target square or "-" if none
      # @raise [ArgumentError] If multiple en passant markers are detected
      def self.extract_en_passant(piece_placement)
        rows = piece_placement.split("/")
        en_passant_targets = []

        rows.each_with_index do |row, _rank|
          file_index = 0
          char_index = 0

          while char_index < row.length
            current_char = row[char_index]

            if /[1-8]/.match?(current_char)
              # Skip empty squares
              file_index += current_char.to_i
              char_index += 1
            elsif char_index + 1 < row.length && row[char_index..(char_index + 1)] =~ /([Pp])([<>])/
              # Found a pawn with en passant marker
              pawn_type = ::Regexp.last_match(1) # 'P' or 'p'
              ::Regexp.last_match(2) # '<' or '>'

              # Calculate the file (column) letter
              file_char = ("a".ord + file_index).chr

              # Calculate the rank (row) number based on pawn type
              # For white pawn (P) on rank 4 (index 3), the target is rank 3
              # For black pawn (p) on rank 5 (index 2), the target is rank 6
              rank_num = if pawn_type == "P"
                           "3" # White pawn's en passant target is always on rank 3
                         else
                           "6" # Black pawn's en passant target is always on rank 6
                         end

              en_passant_targets << "#{file_char}#{rank_num}"

              # Move past this pawn and its suffix
              file_index += 1
              char_index += 2
            else
              # Regular piece
              file_index += 1
              char_index += 1

              # Skip any suffix attached to this piece
              char_index += 1 if char_index < row.length && row[char_index] =~ /[<>=]/
            end
          end
        end

        # Only one en passant target should be present in a valid position
        if en_passant_targets.size > 1
          raise ArgumentError, "Multiple en passant markers detected: #{en_passant_targets.join(', ')}"
        end

        en_passant_targets.first || "-"
      end
    end
  end
end
