#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/dumper/piece_placement"

puts
puts "=== Dumper::PiecePlacement Tests ==="
puts

PP = Sashite::Feen::Dumper::PiecePlacement

# ============================================================================
# 1D BOARDS
# ============================================================================

puts "1D boards:"

Test("pieces and empties") do
  raise unless PP.dump(["K"], [1])                     == "K"
  raise unless PP.dump(["K", "Q", "R"], [3])           == "KQR"
  raise unless PP.dump([nil], [1])                     == "1"
  raise unless PP.dump(Array.new(8), [8])              == "8"
  raise unless PP.dump(["K", nil, nil, nil], [4])      == "K3"
  raise unless PP.dump([nil, nil, nil, "K"], [4])      == "3K"
  raise unless PP.dump(["K", nil, nil, "Q"], [4])      == "K2Q"
  raise unless PP.dump(["K", nil, "Q", nil, "R"], [5]) == "K1Q1R"
end

Test("EPIN decorations") do
  raise unless PP.dump(["K^", nil, nil, "k^"], [4])    == "K^2k^"
  raise unless PP.dump(["+P", nil, nil, "-R"], [4])    == "+P2-R"
  raise unless PP.dump(["+K^'"], [1])                  == "+K^'"
end

Test("large empty count") do
  raise unless PP.dump(Array.new(255), [255]) == "255"
end

# ============================================================================
# 2D BOARDS
# ============================================================================

puts
puts "2D boards:"

Test("minimal and empty boards") do
  raise unless PP.dump([nil, nil], [2, 1])     == "1/1"
  raise unless PP.dump(Array.new(64), [8, 8])  == "8/8/8/8/8/8/8/8"
end

Test("Chess initial position") do
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
  raise unless PP.dump(board, [8, 8]) == "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
end

Test("Shogi initial position") do
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
  raise unless PP.dump(board, [9, 9]) == "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL"
end

Test("corner pieces and decorated pieces") do
  board = Array.new(64); board[0] = "K"; board[63] = "k"
  raise unless PP.dump(board, [8, 8]) == "K7/8/8/8/8/8/8/7k"
  raise unless PP.dump(["+P^'", nil, nil, "-r", nil, nil], [2, 3]) == "+P^'2/-r2"
end

# ============================================================================
# 3D BOARDS
# ============================================================================

puts
puts "3D boards:"

Test("minimal, empty, and with pieces") do
  raise unless PP.dump(Array.new(4), [2, 2, 1])  == "1/1//1/1"
  raise unless PP.dump(Array.new(16), [2, 2, 4]) == "4/4//4/4"
  raise unless PP.dump(%w[a b c d A B C D], [2, 2, 2]) == "ab/cd//AB/CD"
end

Test("multiple layers") do
  raise unless PP.dump(Array.new(12), [3, 2, 2]) == "2/2//2/2//2/2"
  raise unless PP.dump(Array.new(125), [5, 5, 5]) == (["5/5/5/5/5"] * 5).join("//")
end

# ============================================================================
# RUN-LENGTH ENCODING
# ============================================================================

puts
puts "run-length encoding:"

Test("merges consecutive nils, splits across pieces") do
  raise unless PP.dump([nil, nil, nil], [3])         == "3"
  raise unless PP.dump([nil, "K", nil], [3])         == "1K1"
  raise unless PP.dump(["K", nil, nil], [3])         == "K2"
  raise unless PP.dump([nil, nil, "K"], [3])         == "2K"
  raise unless PP.dump(["K", "Q", "R", "B"], [4])   == "KQRB"
end

# ============================================================================
# RETURN TYPE & MODULE PROPERTIES
# ============================================================================

puts
puts "module properties:"

Test("returns a String, module is frozen") do
  raise unless PP.dump(["K"], [1]).is_a?(String)
  raise unless PP.frozen?
end

puts
puts "All Dumper::PiecePlacement tests passed!"
puts
