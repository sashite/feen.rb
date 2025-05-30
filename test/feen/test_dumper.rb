# frozen_string_literal: true

# Tests for Feen::Dumper conforming to FEEN Specification v1.0.0
#
# FEEN Dumper orchestrates the conversion of position components to a complete FEEN string.
# It validates input types and combines the three main components:
# - Piece placement (board state)
# - Pieces in hand (captured/available pieces)
# - Games turn (active/inactive players)
#
# This test assumes the existence of the following files:
# - lib/feen/dumper.rb

require_relative "../../lib/feen/dumper"

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
puts "Tests for Feen::Dumper"
puts

# Valid complete FEEN string generation
run_test("Chess initial position") do
  piece_placement = [
    ["r", "n", "b", "q", "k", "b", "n", "r"],
    ["p", "p", "p", "p", "p", "p", "p", "p"],
    ["", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", ""],
    ["P", "P", "P", "P", "P", "P", "P", "P"],
    ["R", "N", "B", "Q", "K", "B", "N", "R"]
  ]

  result = Feen::Dumper.dump(
    piece_placement: piece_placement,
    pieces_in_hand:  [],
    games_turn:      %w[CHESS chess]
  )

  expected = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / CHESS/chess"
  raise "Expected '#{expected}', got '#{result}'" unless result == expected
end

run_test("Shogi position with pieces in hand") do
  piece_placement = [
    ["l", "n", "s", "g", "k", "g", "s", "n", "l"],
    ["", "r", "", "", "", "", "", "b", ""],
    ["p", "p", "p", "p", "p", "p", "p", "p", "p"],
    ["", "", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", "", ""],
    ["P", "P", "P", "P", "P", "P", "P", "P", "P"],
    ["", "B", "", "", "", "", "", "R", ""],
    ["L", "N", "S", "G", "K", "G", "S", "N", "L"]
  ]

  result = Feen::Dumper.dump(
    piece_placement: piece_placement,
    pieces_in_hand:  %w[B b],
    games_turn:      %w[SHOGI shogi]
  )

  expected = "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL B/b SHOGI/shogi"
  raise "Expected '#{expected}', got '#{result}'" unless result == expected
end

run_test("3D board example") do
  piece_placement = [
    [%w[r n], %w[p p]],
    [%w[R N], %w[P P]]
  ]

  result = Feen::Dumper.dump(
    piece_placement: piece_placement,
    pieces_in_hand:  [],
    games_turn:      %w[FOO bar]
  )

  expected = "rn/pp//RN/PP / FOO/bar"
  raise "Expected '#{expected}', got '#{result}'" unless result == expected
end

run_test("Complex pieces in hand") do
  piece_placement = [["k"], ["K"]]

  result = Feen::Dumper.dump(
    piece_placement: piece_placement,
    pieces_in_hand:  %w[P P P B B p],
    games_turn:      %w[GAME game]
  )

  expected = "k/K 3P2B/p GAME/game"
  raise "Expected '#{expected}', got '#{result}'" unless result == expected
end

run_test("Empty board with pieces in hand") do
  piece_placement = [["", "", "", ""]]

  result = Feen::Dumper.dump(
    piece_placement: piece_placement,
    pieces_in_hand:  %w[K k],
    games_turn:      %w[TEST test]
  )

  expected = "4 K/k TEST/test"
  raise "Expected '#{expected}', got '#{result}'" unless result == expected
end

# Error cases - invalid input types
run_test("Raises error for non-array piece_placement") do
  Feen::Dumper.dump(
    piece_placement: "not an array",
    pieces_in_hand:  [],
    games_turn:      %w[CHESS chess]
  )
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Piece placement must be an Array")
end

run_test("Raises error for non-array pieces_in_hand") do
  Feen::Dumper.dump(
    piece_placement: [["K"]],
    pieces_in_hand:  "not an array",
    games_turn:      %w[CHESS chess]
  )
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Pieces in hand must be an Array")
end

run_test("Raises error for non-array games_turn") do
  Feen::Dumper.dump(
    piece_placement: [["K"]],
    pieces_in_hand:  [],
    games_turn:      "not an array"
  )
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Games turn must be an Array")
end

run_test("Raises error for games_turn with wrong size") do
  Feen::Dumper.dump(
    piece_placement: [["K"]],
    pieces_in_hand:  [],
    games_turn:      ["CHESS"] # Missing second element
  )
  raise "Expected ArgumentError"
rescue ArgumentError => e
  unless e.message.include?("Games turn must be an Array with exactly two elements")
    raise "Wrong error message: #{e.message}"
  end
end

run_test("Raises error for games_turn with too many elements") do
  Feen::Dumper.dump(
    piece_placement: [["K"]],
    pieces_in_hand:  [],
    games_turn:      %w[CHESS chess extra]
  )
  raise "Expected ArgumentError"
rescue ArgumentError => e
  unless e.message.include?("Games turn must be an Array with exactly two elements")
    raise "Wrong error message: #{e.message}"
  end
end

# Error propagation from submodules
run_test("Propagates piece placement errors") do
  Feen::Dumper.dump(
    piece_placement: [[123]], # Invalid cell content
    pieces_in_hand:  [],
    games_turn:      %w[CHESS chess]
  )
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid cell content")
end

run_test("Propagates pieces in hand errors") do
  Feen::Dumper.dump(
    piece_placement: [["K"]],
    pieces_in_hand:  ["+P"], # Modifiers not allowed in hand
    games_turn:      %w[CHESS chess]
  )
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("cannot contain modifiers")
end

run_test("Propagates games turn errors") do
  Feen::Dumper.dump(
    piece_placement: [["K"]],
    pieces_in_hand:  [],
    games_turn:      %w[CHESS CHESS] # Same casing
  )
  raise "Expected ArgumentError"
rescue ArgumentError => e
  unless e.message.include?("One variant must be uppercase and the other lowercase")
    raise "Wrong error message: #{e.message}"
  end
end

# Field separator verification
run_test("Uses correct field separators") do
  result = Feen::Dumper.dump(
    piece_placement: [["K"]],
    pieces_in_hand:  ["P"],
    games_turn:      %w[TEST test]
  )

  # Should have exactly 2 single spaces as field separators
  parts = result.split
  raise "Expected 3 parts separated by single spaces, got #{parts.size}" unless parts.size == 3
  raise "Expected 'K P/ TEST/test', got '#{result}'" unless result == "K P/ TEST/test"
end

# Keyword arguments requirement
run_test("Requires keyword arguments") do
  # This should fail because dump expects keyword arguments
  Feen::Dumper.dump([["K"]], [], %w[TEST test])
  raise "Expected ArgumentError for missing keyword arguments"
rescue ArgumentError => e
  # Ruby will raise an error about wrong number of arguments or missing keywords
  unless e.message.include?("wrong number of arguments") || e.message.include?("missing keyword")
    raise "Wrong error type"
  end
end

puts
puts "All tests passed! ✓"
