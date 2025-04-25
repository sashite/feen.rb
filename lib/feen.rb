# frozen_string_literal: true

require_relative File.join("feen", "converter")
require_relative File.join("feen", "dumper")
require_relative File.join("feen", "parser")

# This module provides a Ruby interface for data serialization and
# deserialization in FEEN format.
#
# @see https://sashite.dev/documents/feen/1.0.0/
module Feen
  # Dumps position params into a FEEN string.
  #
  # @param position [Hash] Hash containing the position data
  # @option position [Array] :piece_placement Board position data
  # @option position [Hash] :games_turn Games and turn data
  # @option position [Array<Hash>] :pieces_in_hand Pieces in hand data
  # @return [String] FEEN notation string
  # @raise [ArgumentError] If the position data is invalid
  # @example
  #   position = {
  #     piece_placement: [[{id: 'r'}, {id: 'n'}, {id: 'b'}, {id: 'q'}, {id: 'k'}, {id: 'b'}, {id: 'n'}, {id: 'r'}],
  #                       [{id: 'p'}, {id: 'p'}, {id: 'p'}, {id: 'p'}, {id: 'p'}, {id: 'p'}, {id: 'p'}, {id: 'p'}],
  #                       [nil, nil, nil, nil, nil, nil, nil, nil],
  #                       [nil, nil, nil, nil, nil, nil, nil, nil],
  #                       [nil, nil, nil, nil, nil, nil, nil, nil],
  #                       [nil, nil, nil, nil, nil, nil, nil, nil],
  #                       [{id: 'P'}, {id: 'P'}, {id: 'P'}, {id: 'P'}, {id: 'P'}, {id: 'P'}, {id: 'P'}, {id: 'P'}],
  #                       [{id: 'R'}, {id: 'N'}, {id: 'B'}, {id: 'Q'}, {id: 'K'}, {id: 'B'}, {id: 'N'}, {id: 'R'}]],
  #     games_turn: {
  #       active_player: 'CHESS',
  #       inactive_player: 'chess',
  #       uppercase_game: 'CHESS',
  #       lowercase_game: 'chess'
  #     },
  #     pieces_in_hand: []
  #   }
  #   Feen.dump(position) # => "rnbqk=bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK=BNR CHESS/chess -"
  def self.dump(position)
    Dumper.dump(position)
  end

  # Parses a FEEN string into position params.
  #
  # @param feen_string [String] FEEN notation string
  # @return [Hash] Hash containing the parsed position data
  # @raise [ArgumentError] If the FEEN string is invalid
  # @example
  #   feen_string = "rnbqk=bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK=BNR CHESS/chess -"
  #   Feen.parse(feen_string)
  #   # => {
  #   #      piece_placement: [[{id: 'r'}, {id: 'n'}, {id: 'b'}, {id: 'q'}, {id: 'k', suffix: '='}, {id: 'b'}, {id: 'n'}, {id: 'r'}],
  #   #                        [{id: 'p'}, {id: 'p'}, {id: 'p'}, {id: 'p'}, {id: 'p'}, {id: 'p'}, {id: 'p'}, {id: 'p'}],
  #   #                        [nil, nil, nil, nil, nil, nil, nil, nil],
  #   #                        [nil, nil, nil, nil, nil, nil, nil, nil],
  #   #                        [nil, nil, nil, nil, nil, nil, nil, nil],
  #   #                        [nil, nil, nil, nil, nil, nil, nil, nil],
  #   #                        [{id: 'P'}, {id: 'P'}, {id: 'P'}, {id: 'P'}, {id: 'P'}, {id: 'P'}, {id: 'P'}, {id: 'P'}],
  #   #                        [{id: 'R'}, {id: 'N'}, {id: 'B'}, {id: 'Q'}, {id: 'K', suffix: '='}, {id: 'B'}, {id: 'N'}, {id: 'R'}]],
  #   #      games_turn: {
  #   #        active_player: 'CHESS',
  #   #        inactive_player: 'chess',
  #   #        uppercase_game: 'CHESS',
  #   #        lowercase_game: 'chess',
  #   #        active_player_casing: :uppercase
  #   #      },
  #   #      pieces_in_hand: []
  #   #    }
  def self.parse(feen_string)
    Parser.parse(feen_string)
  end

  # Validates if the given string is a valid FEEN string
  #
  # @param feen_string [String] FEEN string to validate
  # @return [Boolean] True if the string is a valid FEEN string, false otherwise
  # @example
  #   Feen.valid?("rnbqk=bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK=BNR CHESS/chess -") # => true
  #   Feen.valid?("invalid feen string") # => false
  def self.valid?(feen_string)
    parse(feen_string)
    true
  rescue ::ArgumentError
    false
  end

  # Converts a FEN string to a FEEN string for chess positions
  #
  # @param fen_string [String] Standard FEN notation string for chess
  # @return [String] Equivalent FEEN notation string
  # @raise [ArgumentError] If the FEN string is invalid
  # @example
  #   Feen.from_fen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
  #   # => "rnbqk=bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK=BNR CHESS/chess -"
  def self.from_fen(fen_string)
    Converter.from_fen(fen_string)
  end

  # Converts a FEEN string to a FEN string for chess positions
  #
  # @param feen_string [String] FEEN notation string
  # @return [String] Equivalent FEN notation string
  # @raise [ArgumentError] If the FEEN string is invalid
  # @example
  #   Feen.to_fen("rnbqk=bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK=BNR CHESS/chess -")
  #   # => "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
  def self.to_fen(feen_string)
    Converter.to_fen(feen_string)
  end
end
