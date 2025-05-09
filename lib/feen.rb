# frozen_string_literal: true

require_relative File.join("feen", "converter")
require_relative File.join("feen", "dumper")
require_relative File.join("feen", "parser")

# This module provides a Ruby interface for data serialization and
# deserialization in FEEN format.
#
# @see https://sashite.dev/documents/feen/1.0.0/
module Feen
  # Dumps position components into a FEEN string.
  #
  # @see Feen::Dumper.dump for the detailed parameters documentation
  # @return [String] FEEN notation string
  # @raise [ArgumentError] If any parameter is invalid
  # @example
  #   piece_placement = [
  #     ["r", "n", "b", "q", "k=", "b", "n", "r"],
  #     ["p", "p", "p", "p", "p", "p", "p", "p"],
  #     ["", "", "", "", "", "", "", ""],
  #     ["", "", "", "", "", "", "", ""],
  #     ["", "", "", "", "", "", "", ""],
  #     ["", "", "", "", "", "", "", ""],
  #     ["P", "P", "P", "P", "P", "P", "P", "P"],
  #     ["R", "N", "B", "Q", "K=", "B", "N", "R"]
  #   ]
  #   Feen.dump(
  #     piece_placement: piece_placement,
  #     pieces_in_hand: [],
  #     games_turn: ["CHESS", "chess"]
  #   )
  #   # => "rnbqk=bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK=BNR - CHESS/chess"
  def self.dump(...)
    Dumper.dump(...)
  end

  # Parses a FEEN string into position components.
  #
  # @see Feen::Parser.parse for the detailed parameters and return value documentation
  # @return [Hash] Hash containing the parsed position data
  # @raise [ArgumentError] If the FEEN string is invalid
  # @example
  #   feen_string = "rnbqk=bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK=BNR - CHESS/chess"
  #   Feen.parse(feen_string)
  #   # => {
  #   #      piece_placement: [
  #   #        ["r", "n", "b", "q", "k=", "b", "n", "r"],
  #   #        ["p", "p", "p", "p", "p", "p", "p", "p"],
  #   #        ["", "", "", "", "", "", "", ""],
  #   #        ["", "", "", "", "", "", "", ""],
  #   #        ["", "", "", "", "", "", "", ""],
  #   #        ["", "", "", "", "", "", "", ""],
  #   #        ["P", "P", "P", "P", "P", "P", "P", "P"],
  #   #        ["R", "N", "B", "Q", "K=", "B", "N", "R"]
  #   #      ],
  #   #      pieces_in_hand: [],
  #   #      games_turn: ["CHESS", "chess"]
  #   #    }
  def self.parse(...)
    Parser.parse(...)
  end

  # Validates if the given string is a valid FEEN string
  #
  # @see Feen.parse for parameter details
  # @return [Boolean] True if the string is a valid FEEN string, false otherwise
  # @example
  #   Feen.valid?("rnbqk=bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK=BNR - CHESS/chess") # => true
  #   Feen.valid?("invalid feen string") # => false
  def self.valid?(...)
    parse(...)
    true
  rescue ::ArgumentError
    false
  end

  # Converts a FEN string to a FEEN string for chess positions
  #
  # @see Feen::Converter::FromFen.call for parameter details
  # @return [String] Equivalent FEEN notation string
  # @raise [ArgumentError] If the FEN string is invalid
  # @example
  #   Feen.from_fen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
  #   # => "rnbqk=bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK=BNR - CHESS/chess"
  def self.from_fen(...)
    Converter.from_fen(...)
  end

  # Converts a FEEN string to a FEN string for chess positions
  #
  # @see Feen::Converter::ToFen.call for parameter details
  # @return [String] Equivalent FEN notation string
  # @raise [ArgumentError] If the FEEN string is invalid
  # @example
  #   Feen.to_fen("rnbqk=bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK=BNR - CHESS/chess")
  #   # => "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
  def self.to_fen(...)
    Converter.to_fen(...)
  end
end
