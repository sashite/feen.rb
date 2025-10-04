# frozen_string_literal: true

require_relative "../error"
require_relative "../hands"

require "sashite/epin"

module Sashite
  module Feen
    module Parser
      # Parser for the pieces-in-hand field (second field of FEEN).
      #
      # Converts a FEEN pieces-in-hand string into a Hands object,
      # decoding captured pieces held by each player with optional
      # count prefixes.
      #
      # @see https://sashite.dev/specs/feen/1.0.0/
      module PiecesInHand
        # Player separator in pieces-in-hand field.
        PLAYER_SEPARATOR = "/"

        # Pattern to match EPIN pieces (optional state prefix, letter, optional derivation suffix).
        EPIN_PATTERN = /\A[-+]?[A-Za-z]'?\z/

        # Parse a FEEN pieces-in-hand string into a Hands object.
        #
        # @param string [String] FEEN pieces-in-hand field string
        # @return [Hands] Parsed hands object
        # @raise [Error::Syntax] If hands format is invalid
        # @raise [Error::Piece] If EPIN notation is invalid
        # @raise [Error::Count] If piece counts are invalid
        #
        # @example No pieces in hand
        #   parse("/")  # => Hands.new([], [])
        #
        # @example First player has pieces
        #   parse("2P/p")  # => Hands.new([P, P], [p])
        #
        # @example Both players have pieces
        #   parse("RBN/2p")  # => Hands.new([R, B, N], [p, p])
        def self.parse(string)
          first_str, second_str = split_players(string)

          first_player_pieces = parse_player_pieces(first_str)
          second_player_pieces = parse_player_pieces(second_str)

          Hands.new(first_player_pieces, second_player_pieces)
        end

        # Split pieces-in-hand string into first and second player parts.
        #
        # @param string [String] Pieces-in-hand field string
        # @return [Array(String, String)] First and second player strings
        # @raise [Error::Syntax] If separator is missing
        #
        # @example
        #   split_players("2P/p")  # => ["2P", "p"]
        #   split_players("/")     # => ["", ""]
        private_class_method def self.split_players(string)
          parts = string.split(PLAYER_SEPARATOR, 2)

          raise Error::Syntax, "pieces-in-hand must contain '#{PLAYER_SEPARATOR}' separator" unless parts.size == 2

          parts
        end

        # Parse pieces for a single player.
        #
        # Extracts pieces with optional count prefixes and expands them
        # into individual piece objects.
        #
        # @param string [String] Player's pieces string (e.g., "2PRB")
        # @return [Array] Array of piece objects
        # @raise [Error::Syntax] If format is invalid
        # @raise [Error::Piece] If EPIN notation is invalid
        # @raise [Error::Count] If counts are invalid
        #
        # @example Single pieces
        #   parse_player_pieces("RBN")  # => [R, B, N]
        #
        # @example With counts
        #   parse_player_pieces("3P2R")  # => [P, P, P, R, R]
        #
        # @example Empty
        #   parse_player_pieces("")  # => []
        private_class_method def self.parse_player_pieces(string)
          return [] if string.empty?

          pieces = []
          chars = string.chars
          i = 0

          while i < chars.size
            count, epin_str, consumed = extract_piece_with_count(chars, i)
            piece = parse_piece(epin_str)

            count.times { pieces << piece }
            i += consumed
          end

          pieces
        end

        # Extract a piece with optional count prefix from character array.
        #
        # Handles multi-digit counts and EPIN notation extraction.
        #
        # @param chars [Array<String>] Array of characters
        # @param start_index [Integer] Starting index
        # @return [Array(Integer, String, Integer)] Count, EPIN string, and chars consumed
        # @raise [Error::Syntax] If format is invalid
        # @raise [Error::Count] If count is invalid
        #
        # @example Single piece
        #   extract_piece_with_count(['K', 'Q'], 0)  # => [1, "K", 1]
        #
        # @example Multiple pieces
        #   extract_piece_with_count(['3', 'P', 'R'], 0)  # => [3, "P", 2]
        #
        # @example Large count
        #   extract_piece_with_count(['1', '2', 'P'], 0)  # => [12, "P", 3]
        private_class_method def self.extract_piece_with_count(chars, start_index)
          i = start_index

          # Extract optional count (may be multi-digit)
          count_chars = []
          while i < chars.size && digit?(chars[i])
            count_chars << chars[i]
            i += 1
          end

          count = if count_chars.empty?
                    1
                  else
                    count_str = count_chars.join
                    count_val = count_str.to_i
                    validate_count(count_val, count_str)
                    count_val
                  end

          # Extract EPIN piece
          if i >= chars.size
            raise Error::Syntax, "expected piece after count at position #{start_index}"
          end

          epin_str, epin_consumed = extract_epin(chars, i)
          i += epin_consumed

          consumed = i - start_index
          [count, epin_str, consumed]
        end

        # Extract EPIN notation from character array.
        #
        # Handles state prefixes (+/-), base letter, and derivation suffix (').
        #
        # @param chars [Array<String>] Array of characters
        # @param start_index [Integer] Starting index
        # @return [Array(String, Integer)] EPIN string and number of characters consumed
        # @raise [Error::Syntax] If EPIN format is incomplete
        #
        # @example Simple piece
        #   extract_epin(['K', 'Q'], 0)  # => ["K", 1]
        #
        # @example Enhanced piece with derivation
        #   extract_epin(['+', 'R', "'", 'B'], 0)  # => ["+R'", 3]
        private_class_method def self.extract_epin(chars, start_index)
          i = start_index
          piece_chars = []

          # Optional state prefix
          if i < chars.size && (chars[i] == "+" || chars[i] == "-")
            piece_chars << chars[i]
            i += 1
          end

          # Base letter (required)
          if i >= chars.size || !letter?(chars[i])
            raise Error::Syntax, "expected letter in EPIN notation at position #{start_index}"
          end

          piece_chars << chars[i]
          i += 1

          # Optional derivation suffix
          if i < chars.size && chars[i] == "'"
            piece_chars << chars[i]
            i += 1
          end

          piece_str = piece_chars.join
          consumed = i - start_index

          [piece_str, consumed]
        end

        # Check if character is a digit.
        #
        # @param char [String] Single character
        # @return [Boolean] True if character is 0-9
        private_class_method def self.digit?(char)
          char >= "0" && char <= "9"
        end

        # Check if character is a letter.
        #
        # @param char [String] Single character
        # @return [Boolean] True if character is A-Z or a-z
        private_class_method def self.letter?(char)
          (char >= "A" && char <= "Z") || (char >= "a" && char <= "z")
        end

        # Validate piece count.
        #
        # @param count [Integer] Piece count
        # @param count_str [String] Original count string for error messages
        # @raise [Error::Count] If count is invalid
        private_class_method def self.validate_count(count, count_str)
          if count < 1
            raise Error::Count, "piece count must be at least 1, got #{count_str}"
          end

          if count > 999
            raise Error::Count, "piece count too large: #{count_str}"
          end
        end

        # Parse EPIN string into a piece object.
        #
        # @param epin_str [String] EPIN notation string
        # @return [Object] Piece identifier object
        # @raise [Error::Piece] If EPIN is invalid
        #
        # @example
        #   parse_piece("K")    # => Epin::Identifier
        #   parse_piece("+R'")  # => Epin::Identifier
        private_class_method def self.parse_piece(epin_str)
          unless EPIN_PATTERN.match?(epin_str)
            raise Error::Piece, "invalid EPIN notation: #{epin_str}"
          end

          Sashite::Epin.parse(epin_str)
        rescue StandardError => e
          raise Error::Piece, "failed to parse EPIN '#{epin_str}': #{e.message}"
        end
      end
    end
  end
end
