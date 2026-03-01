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

Test("dumps single piece") do
  result = PiecePlacement.dump(["K"], [1])
  raise "expected 'K'" unless result == "K"
end

Test("dumps multiple pieces") do
  result = PiecePlacement.dump(["K", "Q", "R"], [3])
  raise "expected 'KQR'" unless result == "KQR"
end

Test("dumps empty squares as count") do
  result = PiecePlacement.dump(Array.new(8), [8])
  raise "expected '8'" unless result == "8"
end

Test("dumps piece followed by empties") do
  result = PiecePlacement.dump(["K", nil, nil, nil], [4])
  raise "expected 'K3'" unless result == "K3"
end

Test("dumps empties followed by piece") do
  result = PiecePlacement.dump([nil, nil, nil, "K"], [4])
  raise "expected '3K'" unless result == "3K"
end

Test("dumps piece-empty-piece") do
  result = PiecePlacement.dump(["K", nil, nil, "Q"], [4])
  raise "expected 'K2Q'" unless result == "K2Q"
end

Test("dumps single empty square") do
  result = PiecePlacement.dump([nil], [1])
  raise "expected '1'" unless result == "1"
end

Test("dumps alternating pieces and empties") do
  result = PiecePlacement.dump(["K", nil, "Q", nil, "R"], [5])
  raise "expected 'K1Q1R'" unless result == "K1Q1R"
end

Test("dumps piece with terminal marker") do
  result = PiecePlacement.dump(["K^", nil, nil, "k^"], [4])
  raise "expected 'K^2k^'" unless result == "K^2k^"
end

Test("dumps piece with state modifier") do
  result = PiecePlacement.dump(["+P", nil, nil, "-R"], [4])
  raise "expected '+P2-R'" unless result == "+P2-R"
end

Test("dumps fully decorated piece") do
  result = PiecePlacement.dump(["+K^'"], [1])
  raise "expected '+K^''" unless result == "+K^'"
end

Test("dumps large empty count") do
  result = PiecePlacement.dump(Array.new(255), [255])
  raise "expected '255'" unless result == "255"
end

# ============================================================================
# 2D BOARDS
# ============================================================================

puts
puts "2D boards:"

Test("dumps minimal 2D board") do
  result = PiecePlacement.dump([nil, nil], [2, 1])
  raise "expected '1/1'" unless result == "1/1"
end

Test("dumps empty 8x8 board") do
  result = PiecePlacement.dump(Array.new(64), [8, 8])
  raise "expected '8/8/8/8/8/8/8/8'" unless result == "8/8/8/8/8/8/8/8"
end

Test("dumps Chess initial position") do
  board = [
    "r", "n", "b", "q", "k", "b", "n", "r",
    "p", "p", "p", "p", "p", "p", "p", "p",
    nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil,
    "P", "P", "P", "P", "P", "P", "P", "P",
    "R", "N", "B", "Q", "K", "B", "N", "R"
  ]
  result = PiecePlacement.dump(board, [8, 8])
  raise "expected Chess layout" unless result == "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
end

Test("dumps Shogi initial position") do
  board = [
    "l", "n", "s", "g", "k", "g", "s", "n", "l",
    nil, "r", nil, nil, nil, nil, nil, "b", nil,
    "p", "p", "p", "p", "p", "p", "p", "p", "p",
    nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil,
    "P", "P", "P", "P", "P", "P", "P", "P", "P",
    nil, "B", nil, nil, nil, nil, nil, "R", nil,
    "L", "N", "S", "G", "K", "G", "S", "N", "L"
  ]
  result = PiecePlacement.dump(board, [9, 9])
  raise "expected Shogi layout" unless result == "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL"
end

Test("dumps board with corner pieces") do
  board = Array.new(64)
  board[0] = "K"
  board[63] = "k"
  result = PiecePlacement.dump(board, [8, 8])
  raise "expected 'K7/8/8/8/8/8/8/7k'" unless result == "K7/8/8/8/8/8/8/7k"
end

Test("dumps board with decorated pieces") do
  board = ["+P^'", nil, nil, "-r", nil, nil]
  result = PiecePlacement.dump(board, [2, 3])
  raise "expected '+P^'2/-r2'" unless result == "+P^'2/-r2"
end

# ============================================================================
# 3D BOARDS
# ============================================================================

puts
puts "3D boards:"

Test("dumps minimal 3D board") do
  result = PiecePlacement.dump(Array.new(4), [2, 2, 1])
  raise "expected '1/1//1/1'" unless result == "1/1//1/1"
end

Test("dumps 3D empty board") do
  result = PiecePlacement.dump(Array.new(16), [2, 2, 4])
  raise "expected '4/4//4/4'" unless result == "4/4//4/4"
end

Test("dumps 3D board with pieces") do
  board = ["a", "b", "c", "d", "A", "B", "C", "D"]
  result = PiecePlacement.dump(board, [2, 2, 2])
  raise "expected 'ab/cd//AB/CD'" unless result == "ab/cd//AB/CD"
end

Test("dumps 3D board with 3 layers") do
  result = PiecePlacement.dump(Array.new(12), [3, 2, 2])
  raise "expected '2/2//2/2//2/2'" unless result == "2/2//2/2//2/2"
end

Test("dumps Raumschach-like 5x5x5 board") do
  result = PiecePlacement.dump(Array.new(125), [5, 5, 5])
  expected = (["5/5/5/5/5"] * 5).join("//")
  raise "expected Raumschach layout" unless result == expected
end

# ============================================================================
# RUN-LENGTH ENCODING
# ============================================================================

puts
puts "run-length encoding:"

Test("merges consecutive nils") do
  result = PiecePlacement.dump([nil, nil, nil], [3])
  raise "expected '3'" unless result == "3"
end

Test("does not merge nils across pieces") do
  result = PiecePlacement.dump([nil, "K", nil], [3])
  raise "expected '1K1'" unless result == "1K1"
end

Test("handles trailing nils") do
  result = PiecePlacement.dump(["K", nil, nil], [3])
  raise "expected 'K2'" unless result == "K2"
end

Test("handles leading nils") do
  result = PiecePlacement.dump([nil, nil, "K"], [3])
  raise "expected '2K'" unless result == "2K"
end

Test("handles all pieces no nils") do
  result = PiecePlacement.dump(["K", "Q", "R", "B"], [4])
  raise "expected 'KQRB'" unless result == "KQRB"
end

# ============================================================================
# RETURN TYPE
# ============================================================================

puts
puts "return type:"

Test("returns a String") do
  result = PiecePlacement.dump(["K"], [1])
  raise "expected String" unless result.is_a?(String)
end

# ============================================================================
# MODULE PROPERTIES
# ============================================================================

puts
puts "module properties:"

Test("module is frozen") do
  raise "expected frozen" unless PiecePlacement.frozen?
end

puts
puts "All Dumper::PiecePlacement tests passed!"
puts
