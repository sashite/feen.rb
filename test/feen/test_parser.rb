# frozen_string_literal: true

# Tests for Feen::Parser conforming to FEEN Specification v1.0.0
#
# FEEN Parser orchestrates the parsing of complete FEEN strings into structured data.
# It validates the overall format (3 space-separated fields) and delegates parsing
# of each field to specialized submodules:
# - Piece placement (board state)
# - Pieces in hand (captured/available pieces)
# - Games turn (active/inactive players)
#
# This test assumes the existence of the following files:
# - lib/feen/parser.rb

require_relative "../../lib/feen/parser"

# Helper function to run a test and report errors
def run_test(name)
  print "  #{name}... "
  yield
  puts "✓ Success"
rescue StandardError => e
  warn "✗ Failure: #{e.message}"
  warn "    #{e.backtrace.first}"
  exit(1)
end

puts
puts "Tests for Feen::Parser"
puts

# Valid complete FEEN string parsing
run_test("Chess initial position") do
  feen_string = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / CHESS/chess"
  result = Feen::Parser.parse(feen_string)

  expected_piece_placement = [
    ["r", "n", "b", "q", "k", "b", "n", "r"],
    ["p", "p", "p", "p", "p", "p", "p", "p"],
    ["", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", ""],
    ["P", "P", "P", "P", "P", "P", "P", "P"],
    ["R", "N", "B", "Q", "K", "B", "N", "R"]
  ]

  raise "Wrong piece_placement" unless result[:piece_placement] == expected_piece_placement
  raise "Wrong pieces_in_hand" unless result[:pieces_in_hand] == []
  raise "Wrong games_turn" unless result[:games_turn] == %w[CHESS chess]
end

run_test("Shogi position with pieces in hand") do
  feen_string = "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL B/b SHOGI/shogi"
  result = Feen::Parser.parse(feen_string)

  raise "Wrong pieces_in_hand" unless result[:pieces_in_hand] == %w[B b]
  raise "Wrong games_turn" unless result[:games_turn] == %w[SHOGI shogi]
  raise "Wrong piece_placement size" unless result[:piece_placement].size == 9
end

run_test("3D board example") do
  feen_string = "rn/pp//RN/PP / FOO/bar"
  result = Feen::Parser.parse(feen_string)

  expected_piece_placement = [
    [%w[r n], %w[p p]],
    [%w[R N], %w[P P]]
  ]

  raise "Wrong piece_placement" unless result[:piece_placement] == expected_piece_placement
  raise "Wrong pieces_in_hand" unless result[:pieces_in_hand] == []
  raise "Wrong games_turn" unless result[:games_turn] == %w[FOO bar]
end

run_test("Complex pieces in hand") do
  feen_string = "k/K 3P2B/p GAME/game"
  result = Feen::Parser.parse(feen_string)

  expected_pieces_in_hand = %w[B B P P P p]

  raise "Wrong piece_placement" unless result[:piece_placement] == [["k"], ["K"]]
  raise "Wrong pieces_in_hand" unless result[:pieces_in_hand] == expected_pieces_in_hand
  raise "Wrong games_turn" unless result[:games_turn] == %w[GAME game]
end

run_test("Empty board with pieces in hand") do
  feen_string = "4 K/k TEST/test"
  result = Feen::Parser.parse(feen_string)

  raise "Wrong piece_placement" unless result[:piece_placement] == ["", "", "", ""]
  raise "Wrong pieces_in_hand" unless result[:pieces_in_hand] == %w[K k]
  raise "Wrong games_turn" unless result[:games_turn] == %w[TEST test]
end

run_test("Promoted pieces on board") do
  feen_string = "9/9/9/9/4+P4/9/5+B3/9/9 / SHOGI/shogi"
  result = Feen::Parser.parse(feen_string)

  # Check that promoted pieces are preserved
  raise "Promoted pawn not found" unless result[:piece_placement][4][4] == "+P"
  raise "Promoted bishop not found" unless result[:piece_placement][6][5] == "+B"
  raise "Wrong pieces_in_hand" unless result[:pieces_in_hand] == []
  raise "Wrong games_turn" unless result[:games_turn] == %w[SHOGI shogi]
end

# Return value structure validation
run_test("Returns hash with correct keys") do
  result = Feen::Parser.parse("K / TEST/test")

  raise "Missing :piece_placement key" unless result.key?(:piece_placement)
  raise "Missing :pieces_in_hand key" unless result.key?(:pieces_in_hand)
  raise "Missing :games_turn key" unless result.key?(:games_turn)
  raise "Too many keys" unless result.keys.size == 3
end

# Safe parse method
run_test("safe_parse returns hash for valid input") do
  result = Feen::Parser.safe_parse("K / TEST/test")

  raise "Should return hash" unless result.is_a?(Hash)
  raise "Wrong piece_placement" unless result[:piece_placement] == ["K"]
  raise "Wrong pieces_in_hand" unless result[:pieces_in_hand] == []
  raise "Wrong games_turn" unless result[:games_turn] == %w[TEST test]
end

run_test("safe_parse returns nil for invalid input") do
  result = Feen::Parser.safe_parse("invalid feen string")
  raise "Should return nil for invalid input" unless result.nil?
end

run_test("safe_parse returns nil for wrong field count") do
  result = Feen::Parser.safe_parse("K / TEST/test extra")
  raise "Should return nil for too many fields" unless result.nil?
end

# Error cases - invalid overall format
run_test("Raises error for wrong number of fields (too few)") do
  Feen::Parser.parse("K /")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid FEEN format: expected exactly 3 fields")
end

run_test("Raises error for wrong number of fields (too many)") do
  Feen::Parser.parse("K / TEST/test extra")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid FEEN format: expected exactly 3 fields")
end

run_test("Raises error for missing spaces") do
  Feen::Parser.parse("K/TEST/test")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid FEEN format: expected exactly 3 fields")
end

run_test("Raises error for multiple spaces") do
  Feen::Parser.parse("K  /  TEST/test")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid FEEN format: expected exactly 3 fields")
end

run_test("Raises error for empty string") do
  Feen::Parser.parse("")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid FEEN format: expected exactly 3 fields")
end

run_test("Raises error for whitespace only") do
  Feen::Parser.parse("   ")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid FEEN format: expected exactly 3 fields")
end

# Error propagation from submodules
run_test("Propagates piece placement errors") do
  Feen::Parser.parse("invalid@chars / TEST/test")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Should propagate piece placement error" unless e.message.include?("Invalid piece placement format")
end

run_test("Propagates pieces in hand errors") do
  Feen::Parser.parse("K +P/ TEST/test") # Modifiers not allowed in hand
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Should propagate pieces in hand error" unless e.message.eql?('Pieces in hand cannot contain modifiers: "+P"')
end

run_test("Propagates games turn errors") do
  Feen::Parser.parse("K / INVALID@FORMAT")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Should propagate games turn error" unless e.message.include?("Invalid games turn format")
end

# String conversion
run_test("Converts input to string") do
  # Should work with non-string that responds to String()
  class StringLike
    def to_s
      "K / TEST/test"
    end
  end

  result = Feen::Parser.parse(StringLike.new)
  raise "Should convert to string" unless result[:piece_placement] == ["K"]
end

# Edge cases
run_test("Handles minimal valid FEEN") do
  result = Feen::Parser.parse("K / A/b")

  raise "Wrong piece_placement" unless result[:piece_placement] == ["K"]
  raise "Wrong pieces_in_hand" unless result[:pieces_in_hand] == []
  raise "Wrong games_turn" unless result[:games_turn] == %w[A b]
end

run_test("Handles complex valid FEEN") do
  complex_feen = "lnsgkg1nl/1r7/ppp1ppppp/3p5/9/2P6/PP1PPPPPP/1B5R1/LNSGKGSNL 5P2G2L/2g2sln SHOGI/shogi"
  result = Feen::Parser.parse(complex_feen)

  raise "Should parse complex FEEN" unless result.is_a?(Hash)
  raise "Wrong keys count" unless result.keys.size == 3
  raise "Should have pieces in hand" unless result[:pieces_in_hand].size.positive?
end

puts
puts "All tests passed! ✓"
