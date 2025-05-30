# frozen_string_literal: true

# Tests for Feen::Dumper::PiecePlacement conforming to FEEN Specification v1.0.0
#
# FEEN specifies that piece placement must be formatted as:
# - Spatial distribution of pieces across the board
# - Empty squares compressed using digits 1-n representing consecutive empty cells
# - Pieces denoted using PNN notation (including modifiers for pieces on the board)
# - Dimension separators: "/" for 2D, "//" for 3D, "///" for 4D, etc.
# - Supports arbitrary-dimensional board configurations
# - Irregular board shapes allowed by varying cells per rank
#
# This test assumes the existence of the following files:
# - lib/feen/dumper/piece_placement.rb

require_relative "../../../lib/feen/dumper/piece_placement"

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
puts "Tests for Feen::Dumper::PiecePlacement"
puts

# Basic 2D cases
run_test("Empty board (single rank)") do
  result = Feen::Dumper::PiecePlacement.dump([[]])
  raise "Expected '', got '#{result}'" unless result == ""
end

run_test("Single empty cell") do
  result = Feen::Dumper::PiecePlacement.dump([["", "", "", ""]])
  raise "Expected '4', got '#{result}'" unless result == "4"
end

run_test("Single piece") do
  result = Feen::Dumper::PiecePlacement.dump([["K"]])
  raise "Expected 'K', got '#{result}'" unless result == "K"
end

run_test("Mixed pieces and empty cells") do
  result = Feen::Dumper::PiecePlacement.dump([["r", "", "", "k", "", "r"]])
  raise "Expected 'r2k1r', got '#{result}'" unless result == "r2k1r"
end

run_test("All pieces (no empty cells)") do
  result = Feen::Dumper::PiecePlacement.dump([%w[r n b q]])
  raise "Expected 'rnbq', got '#{result}'" unless result == "rnbq"
end

run_test("All empty cells") do
  result = Feen::Dumper::PiecePlacement.dump([["", "", "", "", "", "", "", ""]])
  raise "Expected '8', got '#{result}'" unless result == "8"
end

# Chess-like 2D board
run_test("Chess initial position") do
  board = [
    ["r", "n", "b", "q", "k", "b", "n", "r"],
    ["p", "p", "p", "p", "p", "p", "p", "p"],
    ["", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", ""],
    ["P", "P", "P", "P", "P", "P", "P", "P"],
    ["R", "N", "B", "Q", "K", "B", "N", "R"]
  ]
  result = Feen::Dumper::PiecePlacement.dump(board)
  expected = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
  raise "Expected '#{expected}', got '#{result}'" unless result == expected
end

run_test("Chess mid-game position") do
  board = [
    ["r", "n", "b", "q", "k", "b", "n", "r"],
    ["p", "p", "", "p", "p", "p", "p", "p"],
    ["", "", "", "", "", "", "", ""],
    ["", "", "p", "", "", "", "", ""],
    ["", "", "", "", "P", "", "", ""],
    ["", "", "", "", "", "N", "", ""],
    ["P", "P", "P", "P", "", "P", "P", "P"],
    ["R", "N", "B", "Q", "K", "B", "", "R"]
  ]
  result = Feen::Dumper::PiecePlacement.dump(board)
  expected = "rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R"
  raise "Expected '#{expected}', got '#{result}'" unless result == expected
end

# Pieces with PNN modifiers
run_test("Pieces with enhanced state (+)") do
  result = Feen::Dumper::PiecePlacement.dump([["+P", "+B", "k"]])
  raise "Expected '+P+Bk', got '#{result}'" unless result == "+P+Bk"
end

run_test("Pieces with diminished state (-)") do
  result = Feen::Dumper::PiecePlacement.dump([["-r", "", "-k"]])
  raise "Expected '-r1-k', got '#{result}'" unless result == "-r1-k"
end

run_test("Pieces with intermediate state (')") do
  result = Feen::Dumper::PiecePlacement.dump([["K'", "", "R'"]])
  raise "Expected 'K\\'1R\\'', got '#{result}'" unless result == "K'1R'"
end

run_test("Pieces with multiple modifiers") do
  result = Feen::Dumper::PiecePlacement.dump([["+P'", "-R'", "k"]])
  raise "Expected '+P\\'-R\\'k', got '#{result}'" unless result == "+P'-R'k"
end

# 3D boards
run_test("Simple 3D board (2x2x2)") do
  board = [
    [%w[r n], %w[p p]],
    [%w[R N], %w[P P]]
  ]
  result = Feen::Dumper::PiecePlacement.dump(board)
  expected = "rn/pp//RN/PP"
  raise "Expected '#{expected}', got '#{result}'" unless result == expected
end

run_test("3D board with empty cells") do
  board = [
    [["r", ""], ["", "p"]],
    [["", ""], ["", ""]]
  ]
  result = Feen::Dumper::PiecePlacement.dump(board)
  expected = "r1/1p//2/2"
  raise "Expected '#{expected}', got '#{result}'" unless result == expected
end

run_test("Complex 3D board") do
  board = [
    [%w[r n b], %w[q k p]],
    [["P", "R", ""], ["", "K", "Q"]],
    [["", "", ""], ["", "", ""]]
  ]
  result = Feen::Dumper::PiecePlacement.dump(board)
  expected = "rnb/qkp//PR1/1KQ//3/3"
  raise "Expected '#{expected}', got '#{result}'" unless result == expected
end

# 4D board (just to test deeper nesting)
run_test("4D board") do
  board = [
    [
      [["K"], ["P"]],
      [[""], [""]]
    ],
    [
      [["k"], ["p"]],
      [[""], [""]]
    ]
  ]
  result = Feen::Dumper::PiecePlacement.dump(board)
  expected = "K/P//1/1///k/p//1/1"
  raise "Expected '#{expected}', got '#{result}'" unless result == expected
end

# Large numbers of consecutive empty cells
run_test("Large number of empty cells") do
  empty_cells = Array.new(15, "")
  result = Feen::Dumper::PiecePlacement.dump([empty_cells])
  raise "Expected '15', got '#{result}'" unless result == "15"
end

run_test("Very large number of empty cells") do
  empty_cells = Array.new(123, "")
  result = Feen::Dumper::PiecePlacement.dump([empty_cells])
  raise "Expected '123', got '#{result}'" unless result == "123"
end

# Edge cases with trailing/leading empty cells
run_test("Leading empty cells") do
  result = Feen::Dumper::PiecePlacement.dump([["", "", "K", "R"]])
  raise "Expected '2KR', got '#{result}'" unless result == "2KR"
end

run_test("Trailing empty cells") do
  result = Feen::Dumper::PiecePlacement.dump([["K", "R", "", ""]])
  raise "Expected 'KR2', got '#{result}'" unless result == "KR2"
end

run_test("Leading and trailing empty cells") do
  result = Feen::Dumper::PiecePlacement.dump([["", "K", ""]])
  raise "Expected '1K1', got '#{result}'" unless result == "1K1"
end

# Irregular shapes
run_test("Irregular board shapes") do
  board = [
    ["r", "n", "b", "q", "k", "b", "n", "r"],  # 8 cells
    ["p", "p", "p", "p", "p", "p", "p"],       # 7 cells
    ["", "", "", "", "", "", "", ""]           # 8 cells
  ]
  result = Feen::Dumper::PiecePlacement.dump(board)
  expected = "rnbqkbnr/ppppppp/8"
  raise "Expected '#{expected}', got '#{result}'" unless result == expected
end

run_test("Allow irregular board shapes (different rank sizes)") do
  result = Feen::Dumper::PiecePlacement.dump([%w[a b], ["c"]])
  expected = "ab/c"
  raise "Expected '#{expected}', got '#{result}'" unless result == expected
end

run_test("Allow complex irregular shapes") do
  board = [
    ["r", "n", "b", "q", "k", "b", "n", "r"],
    ["p", "p", "p", "p", "p", "p", "p"],
    ["", "", "", "", "", "", "", ""],
    ["", "", ""],
    ["P", "P", "P", "P", "P"]
  ]
  result = Feen::Dumper::PiecePlacement.dump(board)
  expected = "rnbqkbnr/ppppppp/8/3/PPPPP"
  raise "Expected '#{expected}', got '#{result}'" unless result == expected
end

run_test("Allow empty ranks in irregular shapes") do
  board = [
    ["k"],
    [],
    ["", "", "P"],
    ["R", "R"]
  ]
  result = Feen::Dumper::PiecePlacement.dump(board)
  expected = "k//2P/RR"
  raise "Expected '#{expected}', got '#{result}'" unless result == expected
end

run_test("Allow 3D irregular structures") do
  board = [
    [%w[r n], ["p"]],
    [["R"], %w[P P P]]
  ]
  result = Feen::Dumper::PiecePlacement.dump(board)
  expected = "rn/p//R/PPP"
  raise "Expected '#{expected}', got '#{result}'" unless result == expected
end

run_test("Distinguish irregular shapes from invalid content") do
  valid_irregular = [["K"], %w[P P], %w[R N B]]
  result = Feen::Dumper::PiecePlacement.dump(valid_irregular)
  expected = "K/PP/RNB"
  raise "Valid irregular shape should work: expected '#{expected}', got '#{result}'" unless result == expected

  begin
    Feen::Dumper::PiecePlacement.dump([["K"], [123]])
    raise "Should have raised ArgumentError for invalid cell content"
  rescue ArgumentError => e
    raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid cell content")
  end
end

run_test("Handle extreme irregular cases") do
  extreme_board = [
    Array.new(15, "p"),
    ["K"],
    [],
    Array.new(8, ""),
    ["R", "", "N"]
  ]

  result = Feen::Dumper::PiecePlacement.dump(extreme_board)
  expected = "ppppppppppppppp/K//8/R1N"
  raise "Expected '#{expected}', got '#{result}'" unless result == expected
end

# Error cases - invalid input types
run_test("Raises error for non-array input") do
  Feen::Dumper::PiecePlacement.dump("not an array")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Piece placement must be an Array")
end

run_test("Raises error for invalid cell content") do
  Feen::Dumper::PiecePlacement.dump([[123]])
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid cell content")
end

run_test("Raises error for mixed types in structure") do
  # Mix of strings and arrays at same level
  Feen::Dumper::PiecePlacement.dump(["a", ["b"]])
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid cell content: [\"b\"] (must be String)")
end

# Special Shogi examples with promoted pieces
run_test("Shogi position with promoted pieces") do
  board = [
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
  result = Feen::Dumper::PiecePlacement.dump(board)
  expected = "9/9/9/9/4+P4/9/5+B3/9/9"
  raise "Expected '#{expected}', got '#{result}'" unless result == expected
end

puts
puts "All tests passed! ✓"
