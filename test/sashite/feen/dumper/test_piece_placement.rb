#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/dumper/piece_placement"

puts
puts "=== Dumper::PiecePlacement Tests ==="
puts

PiecePlacement = Sashite::Feen::Dumper::PiecePlacement

# ============================================================================
# 1D BOARDS
# ============================================================================

puts "1D boards:"

run_test("dumps single piece") do
  result = PiecePlacement.dump(["K"])
  raise "expected 'K'" unless result == "K"
end

run_test("dumps multiple pieces") do
  result = PiecePlacement.dump(["K", "Q", "R"])
  raise "expected 'KQR'" unless result == "KQR"
end

run_test("dumps empty squares as count") do
  result = PiecePlacement.dump([nil, nil, nil, nil, nil, nil, nil, nil])
  raise "expected '8'" unless result == "8"
end

run_test("dumps piece followed by empties") do
  result = PiecePlacement.dump(["K", nil, nil, nil])
  raise "expected 'K3'" unless result == "K3"
end

run_test("dumps empties followed by piece") do
  result = PiecePlacement.dump([nil, nil, nil, "K"])
  raise "expected '3K'" unless result == "3K"
end

run_test("dumps piece-empty-piece") do
  result = PiecePlacement.dump(["K", nil, nil, "Q"])
  raise "expected 'K2Q'" unless result == "K2Q"
end

run_test("dumps single empty square") do
  result = PiecePlacement.dump([nil])
  raise "expected '1'" unless result == "1"
end

run_test("dumps alternating pieces and empties") do
  result = PiecePlacement.dump(["K", nil, "Q", nil, "R"])
  raise "expected 'K1Q1R'" unless result == "K1Q1R"
end

run_test("dumps piece with terminal marker") do
  result = PiecePlacement.dump(["K^", nil, nil, "k^"])
  raise "expected 'K^2k^'" unless result == "K^2k^"
end

run_test("dumps piece with state modifier") do
  result = PiecePlacement.dump(["+P", nil, nil, "-R"])
  raise "expected '+P2-R'" unless result == "+P2-R"
end

run_test("dumps fully decorated piece") do
  result = PiecePlacement.dump(["+K^'"])
  raise "expected '+K^''" unless result == "+K^'"
end

run_test("dumps large empty count") do
  board = Array.new(255)
  result = PiecePlacement.dump(board)
  raise "expected '255'" unless result == "255"
end

# ============================================================================
# 2D BOARDS
# ============================================================================

puts
puts "2D boards:"

run_test("dumps minimal 2D board") do
  result = PiecePlacement.dump([[nil], [nil]])
  raise "expected '1/1'" unless result == "1/1"
end

run_test("dumps empty 8x8 board") do
  board = Array.new(8) { Array.new(8) }
  result = PiecePlacement.dump(board)
  raise "expected '8/8/8/8/8/8/8/8'" unless result == "8/8/8/8/8/8/8/8"
end

run_test("dumps Chess initial position") do
  board = [
    ["r", "n", "b", "q", "k", "b", "n", "r"],
    ["p", "p", "p", "p", "p", "p", "p", "p"],
    Array.new(8), Array.new(8), Array.new(8), Array.new(8),
    ["P", "P", "P", "P", "P", "P", "P", "P"],
    ["R", "N", "B", "Q", "K", "B", "N", "R"]
  ]
  result = PiecePlacement.dump(board)
  raise "expected Chess layout" unless result == "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
end

run_test("dumps Shogi initial position") do
  board = [
    ["l", "n", "s", "g", "k", "g", "s", "n", "l"],
    [nil, "r", nil, nil, nil, nil, nil, "b", nil],
    ["p", "p", "p", "p", "p", "p", "p", "p", "p"],
    Array.new(9), Array.new(9), Array.new(9),
    ["P", "P", "P", "P", "P", "P", "P", "P", "P"],
    [nil, "B", nil, nil, nil, nil, nil, "R", nil],
    ["L", "N", "S", "G", "K", "G", "S", "N", "L"]
  ]
  result = PiecePlacement.dump(board)
  raise "expected Shogi layout" unless result == "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL"
end

run_test("dumps board with corner pieces") do
  board = Array.new(8) { Array.new(8) }
  board[0][0] = "K"
  board[7][7] = "k"
  result = PiecePlacement.dump(board)
  raise "expected 'K7/8/8/8/8/8/8/7k'" unless result == "K7/8/8/8/8/8/8/7k"
end

run_test("dumps board with decorated pieces") do
  board = [["+P^'", nil], ["-r", nil, nil, nil]]
  result = PiecePlacement.dump(board)
  raise "expected '+P^'1/-r3'" unless result == "+P^'1/-r3"
end

# ============================================================================
# 3D BOARDS
# ============================================================================

puts
puts "3D boards:"

run_test("dumps minimal 3D board") do
  board = [[[nil], [nil]], [[nil], [nil]]]
  result = PiecePlacement.dump(board)
  raise "expected '1/1//1/1'" unless result == "1/1//1/1"
end

run_test("dumps 3D empty board") do
  board = [
    [Array.new(4), Array.new(4)],
    [Array.new(4), Array.new(4)]
  ]
  result = PiecePlacement.dump(board)
  raise "expected '4/4//4/4'" unless result == "4/4//4/4"
end

run_test("dumps 3D board with pieces") do
  board = [
    [["a", "b"], ["c", "d"]],
    [["A", "B"], ["C", "D"]]
  ]
  result = PiecePlacement.dump(board)
  raise "expected 'ab/cd//AB/CD'" unless result == "ab/cd//AB/CD"
end

run_test("dumps 3D board with 3 layers") do
  board = [
    [Array.new(2), Array.new(2)],
    [Array.new(2), Array.new(2)],
    [Array.new(2), Array.new(2)]
  ]
  result = PiecePlacement.dump(board)
  raise "expected '2/2//2/2//2/2'" unless result == "2/2//2/2//2/2"
end

run_test("dumps Raumschach-like 5x5x5 board") do
  board = Array.new(5) { Array.new(5) { Array.new(5) } }
  result = PiecePlacement.dump(board)
  expected = (["5/5/5/5/5"] * 5).join("//")
  raise "expected Raumschach layout" unless result == expected
end

# ============================================================================
# RUN-LENGTH ENCODING
# ============================================================================

puts
puts "run-length encoding:"

run_test("merges consecutive nils") do
  result = PiecePlacement.dump([nil, nil, nil])
  raise "expected '3'" unless result == "3"
end

run_test("does not merge nils across pieces") do
  result = PiecePlacement.dump([nil, "K", nil])
  raise "expected '1K1'" unless result == "1K1"
end

run_test("handles trailing nils") do
  result = PiecePlacement.dump(["K", nil, nil])
  raise "expected 'K2'" unless result == "K2"
end

run_test("handles leading nils") do
  result = PiecePlacement.dump([nil, nil, "K"])
  raise "expected '2K'" unless result == "2K"
end

run_test("handles all pieces no nils") do
  result = PiecePlacement.dump(["K", "Q", "R", "B"])
  raise "expected 'KQRB'" unless result == "KQRB"
end

# ============================================================================
# RETURN TYPE
# ============================================================================

puts
puts "return type:"

run_test("returns a String") do
  result = PiecePlacement.dump(["K"])
  raise "expected String" unless result.is_a?(String)
end

# ============================================================================
# MODULE PROPERTIES
# ============================================================================

puts
puts "module properties:"

run_test("module is frozen") do
  raise "expected frozen" unless PiecePlacement.frozen?
end

puts
puts "All Dumper::PiecePlacement tests passed!"
puts
