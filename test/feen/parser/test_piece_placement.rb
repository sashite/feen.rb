# frozen_string_literal: true

# Tests for Feen::Parser::PiecePlacement conforming to FEEN Specification v1.0.0
#
# FEEN specifies that piece placement must be parsed from format:
# - Spatial distribution of pieces across the board
# - Empty squares represented by digits 1-n for consecutive empty cells
# - Pieces denoted using PNN notation (including modifiers for pieces on the board)
# - Dimension separators: "/" for 2D, "//" for 3D, "///" for 4D, etc.
# - Supports arbitrary-dimensional board configurations
# - Returns hierarchical array structure representing the board
#
# This test assumes the existence of the following files:
# - lib/feen/parser/piece_placement.rb

require_relative "../../../lib/feen/parser/piece_placement"

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
puts "Tests for Feen::Parser::PiecePlacement"
puts

# Basic single rank cases
run_test("Single piece") do
  result = Feen::Parser::PiecePlacement.parse("K")
  expected = ["K"]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Single empty cell") do
  result = Feen::Parser::PiecePlacement.parse("1")
  expected = [""]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Multiple empty cells") do
  result = Feen::Parser::PiecePlacement.parse("4")
  expected = ["", "", "", ""]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Mixed pieces and empty cells") do
  result = Feen::Parser::PiecePlacement.parse("r2k1r")
  expected = ["r", "", "", "k", "", "r"]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("All pieces (no empty cells)") do
  result = Feen::Parser::PiecePlacement.parse("rnbq")
  expected = %w[r n b q]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("All empty cells") do
  result = Feen::Parser::PiecePlacement.parse("8")
  expected = ["", "", "", "", "", "", "", ""]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

# Pieces with PNN modifiers
run_test("Pieces with enhanced state (+)") do
  result = Feen::Parser::PiecePlacement.parse("+P+Bk")
  expected = ["+P", "+B", "k"]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Pieces with diminished state (-)") do
  result = Feen::Parser::PiecePlacement.parse("-r1-k")
  expected = ["-r", "", "-k"]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Pieces with intermediate state (')") do
  result = Feen::Parser::PiecePlacement.parse("K'1R'")
  expected = ["K'", "", "R'"]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Pieces with multiple modifiers") do
  result = Feen::Parser::PiecePlacement.parse("+P'-R'k")
  expected = ["+P'", "-R'", "k"]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

# 2D boards (chess-like)
run_test("Chess initial position") do
  result = Feen::Parser::PiecePlacement.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR")
  expected = [
    ["r", "n", "b", "q", "k", "b", "n", "r"],
    ["p", "p", "p", "p", "p", "p", "p", "p"],
    ["", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", ""],
    ["P", "P", "P", "P", "P", "P", "P", "P"],
    ["R", "N", "B", "Q", "K", "B", "N", "R"]
  ]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Chess mid-game position") do
  result = Feen::Parser::PiecePlacement.parse("rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R")
  expected = [
    ["r", "n", "b", "q", "k", "b", "n", "r"],
    ["p", "p", "", "p", "p", "p", "p", "p"],
    ["", "", "", "", "", "", "", ""],
    ["", "", "p", "", "", "", "", ""],
    ["", "", "", "", "P", "", "", ""],
    ["", "", "", "", "", "N", "", ""],
    ["P", "P", "P", "P", "", "P", "P", "P"],
    ["R", "N", "B", "Q", "K", "B", "", "R"]
  ]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

# Shogi examples with promoted pieces
run_test("Shogi position with promoted pieces") do
  result = Feen::Parser::PiecePlacement.parse("9/9/9/9/4+P4/9/5+B3/9/9")
  expected = [
    ["", "", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", "", ""],
    ["", "", "", "", "+P", "", "", "", ""],
    ["", "", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "+B", "", "", ""],
    ["", "", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", "", ""]
  ]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

# 3D boards
run_test("Simple 3D board (2x2x2)") do
  result = Feen::Parser::PiecePlacement.parse("rn/pp//RN/PP")
  expected = [
    [%w[r n], %w[p p]],
    [%w[R N], %w[P P]]
  ]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("3D board with empty cells") do
  result = Feen::Parser::PiecePlacement.parse("r1/1p//2/2")
  expected = [
    [["r", ""], ["", "p"]],
    [["", ""], ["", ""]]
  ]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Complex 3D board") do
  result = Feen::Parser::PiecePlacement.parse("rnb/qkp//PR1/1KQ//3/3")
  expected = [
    [%w[r n b], %w[q k p]],
    [["P", "R", ""], ["", "K", "Q"]],
    [["", "", ""], ["", "", ""]]
  ]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

# 4D board
run_test("4D board") do
  result = Feen::Parser::PiecePlacement.parse("K/P///1/1////k/p///1/1")
  expected = [
    [
      [["K"], ["P"]],
      [[""], [""]]
    ],
    [
      [["k"], ["p"]],
      [[""], [""]]
    ]
  ]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

# Large numbers
run_test("Large number of empty cells") do
  result = Feen::Parser::PiecePlacement.parse("15")
  expected = Array.new(15, "")
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Very large number of empty cells") do
  result = Feen::Parser::PiecePlacement.parse("123")
  expected = Array.new(123, "")
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

# Edge cases with leading/trailing empty cells
run_test("Leading empty cells") do
  result = Feen::Parser::PiecePlacement.parse("2KR")
  expected = ["", "", "K", "R"]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Trailing empty cells") do
  result = Feen::Parser::PiecePlacement.parse("KR2")
  expected = ["K", "R", "", ""]
  raise "Expected #{expected.inspire}, got #{result.inspect}" unless result == expected
end

run_test("Leading and trailing empty cells") do
  result = Feen::Parser::PiecePlacement.parse("1K1")
  expected = ["", "K", ""]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

# Mixed case pieces
run_test("Mixed case pieces") do
  result = Feen::Parser::PiecePlacement.parse("RnBqKbNr")
  expected = %w[R n B q K b N r]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

# Irregular board shapes
run_test("Irregular board shapes") do
  result = Feen::Parser::PiecePlacement.parse("rnbqkbnr/ppppppp/8")
  expected = [
    ["r", "n", "b", "q", "k", "b", "n", "r"],  # 8 cells
    ["p", "p", "p", "p", "p", "p", "p"],       # 7 cells
    ["", "", "", "", "", "", "", ""]           # 8 cells
  ]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

# Error cases - simplified error handling
run_test("Raises error for non-string input") do
  Feen::Parser::PiecePlacement.parse(123)
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Piece placement must be a string")
end

run_test("Raises error for nil input") do
  Feen::Parser::PiecePlacement.parse(nil)
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Piece placement must be a string")
end

run_test("Raises error for array input") do
  Feen::Parser::PiecePlacement.parse(%w[r n b])
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Piece placement must be a string")
end

run_test("Raises error for empty string") do
  Feen::Parser::PiecePlacement.parse("")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Piece placement string cannot be empty")
end

# Invalid format cases - all use generic "Invalid piece placement format" message
run_test("Raises error for invalid characters") do
  Feen::Parser::PiecePlacement.parse("r@n")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid piece placement format")
end

run_test("Raises error for spaces") do
  Feen::Parser::PiecePlacement.parse("r n")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid piece placement format")
end

run_test("Raises error for trailing separator") do
  Feen::Parser::PiecePlacement.parse("rnbqkbnr/")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid piece placement format")
end

run_test("Raises error for invalid piece without letter") do
  Feen::Parser::PiecePlacement.parse("+")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid piece placement format")
end

run_test("Raises error for zero empty cells") do
  Feen::Parser::PiecePlacement.parse("0")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid piece placement format")
end

# Edge cases - minimal valid inputs
run_test("Minimal valid single piece") do
  result = Feen::Parser::PiecePlacement.parse("a")
  expected = ["a"]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Minimal valid single empty") do
  result = Feen::Parser::PiecePlacement.parse("1")
  expected = [""]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Minimal valid 2D") do
  result = Feen::Parser::PiecePlacement.parse("a/b")
  expected = [["a"], ["b"]]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Minimal valid 3D") do
  result = Feen::Parser::PiecePlacement.parse("a//b")
  expected = [["a"], ["b"]]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

puts
puts "All tests passed! ✓"
