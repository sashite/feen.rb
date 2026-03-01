#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/parser/piece_placement"

puts
puts "=== Parser::PiecePlacement Tests ==="
puts

PiecePlacement = Sashite::Feen::Parser::PiecePlacement
PiecePlacementError = Sashite::Feen::PiecePlacementError

# ============================================================================
# 1D BOARDS
# ============================================================================

puts "1D boards:"

Test("parses single piece") do
  result = PiecePlacement.parse("K")
  raise "expected [\"K\"]" unless result == ["K"]
end

Test("parses single empty count") do
  result = PiecePlacement.parse("8")
  raise "expected 8 nils" unless result == [nil] * 8
end

Test("parses piece followed by empties") do
  result = PiecePlacement.parse("K3")
  raise "expected [\"K\", nil, nil, nil]" unless result == ["K", nil, nil, nil]
end

Test("parses empties followed by piece") do
  result = PiecePlacement.parse("3K")
  raise "expected [nil, nil, nil, \"K\"]" unless result == [nil, nil, nil, "K"]
end

Test("parses piece-empty-piece") do
  result = PiecePlacement.parse("K2Q")
  raise "wrong result" unless result == ["K", nil, nil, "Q"]
end

Test("parses multiple pieces no empties") do
  result = PiecePlacement.parse("KQR")
  raise "expected [\"K\", \"Q\", \"R\"]" unless result == ["K", "Q", "R"]
end

Test("parses piece with terminal marker") do
  result = PiecePlacement.parse("K^2k^")
  raise "wrong result" unless result == ["K^", nil, nil, "k^"]
end

Test("parses piece with state modifier") do
  result = PiecePlacement.parse("+P2-R")
  raise "wrong result" unless result == ["+P", nil, nil, "-R"]
end

Test("parses piece with derivation marker") do
  result = PiecePlacement.parse("K'2Q'")
  raise "wrong result" unless result == ["K'", nil, nil, "Q'"]
end

Test("parses fully decorated piece") do
  result = PiecePlacement.parse("+K^'")
  raise "expected [\"+K^'\"]" unless result == ["+K^'"]
end

Test("parses large empty count") do
  result = PiecePlacement.parse("255")
  raise "expected 255 nils" unless result.size == 255
  raise "all should be nil" unless result.all?(&:nil?)
end

# ============================================================================
# 2D BOARDS
# ============================================================================

puts
puts "2D boards:"

Test("parses minimal 2D board") do
  result = PiecePlacement.parse("1/1")
  raise "expected [[nil], [nil]]" unless result == [[nil], [nil]]
end

Test("parses empty 8x8 board") do
  result = PiecePlacement.parse("8/8/8/8/8/8/8/8")
  raise "expected 8 ranks" unless result.size == 8
  result.each do |rank|
    raise "expected 8 squares per rank" unless rank.size == 8
    raise "all should be nil" unless rank.all?(&:nil?)
  end
end

Test("parses Chess initial position") do
  result = PiecePlacement.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR")
  raise "expected 8 ranks" unless result.size == 8
  raise "wrong rank 1" unless result[0] == ["r", "n", "b", "q", "k", "b", "n", "r"]
  raise "wrong rank 2" unless result[1] == ["p"] * 8
  raise "wrong rank 3" unless result[2] == [nil] * 8
  raise "wrong rank 7" unless result[6] == ["P"] * 8
  raise "wrong rank 8" unless result[7] == ["R", "N", "B", "Q", "K", "B", "N", "R"]
end

Test("parses Shogi initial position") do
  result = PiecePlacement.parse("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL")
  raise "expected 9 ranks" unless result.size == 9
  raise "wrong rank 1" unless result[0] == ["l", "n", "s", "g", "k", "g", "s", "n", "l"]
  raise "wrong rank 2" unless result[1] == [nil, "r", nil, nil, nil, nil, nil, "b", nil]
  raise "wrong rank 2 size" unless result[1].size == 9
end

Test("parses Xiangqi initial position") do
  result = PiecePlacement.parse("rheagaehr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RHEAGAEHR")
  raise "expected 10 ranks" unless result.size == 10
  raise "wrong first rank" unless result[0] == ["r", "h", "e", "a", "g", "a", "e", "h", "r"]
  raise "wrong last rank" unless result[9] == ["R", "H", "E", "A", "G", "A", "E", "H", "R"]
end

Test("parses 2D board with mixed content") do
  result = PiecePlacement.parse("K7/8/8/8/8/8/8/7k")
  raise "expected 8 ranks" unless result.size == 8
  raise "wrong first square" unless result[0][0] == "K"
  raise "wrong last square" unless result[7][7] == "k"
end

Test("parses 2D board with decorated pieces") do
  result = PiecePlacement.parse("+P^'1/-r3")
  raise "expected 2 ranks" unless result.size == 2
  raise "wrong first rank" unless result[0] == ["+P^'", nil]
  raise "wrong second rank" unless result[1] == ["-r", nil, nil, nil]
end

# ============================================================================
# 3D BOARDS
# ============================================================================

puts
puts "3D boards:"

Test("parses minimal 3D board") do
  result = PiecePlacement.parse("1/1//1/1")
  raise "expected 2 layers" unless result.size == 2
  raise "expected 2 ranks per layer" unless result[0].size == 2
  raise "expected 2 ranks per layer" unless result[1].size == 2
  raise "expected [nil]" unless result[0][0] == [nil]
end

Test("parses 3D empty board") do
  result = PiecePlacement.parse("4/4//4/4")
  raise "expected 2 layers" unless result.size == 2
  result.each do |layer|
    raise "expected 2 ranks per layer" unless layer.size == 2
    layer.each do |rank|
      raise "expected 4 squares per rank" unless rank.size == 4
      raise "all should be nil" unless rank.all?(&:nil?)
    end
  end
end

Test("parses 3D board with pieces") do
  result = PiecePlacement.parse("ab/cd//AB/CD")
  raise "expected 2 layers" unless result.size == 2
  raise "wrong layer 1 rank 1" unless result[0][0] == ["a", "b"]
  raise "wrong layer 1 rank 2" unless result[0][1] == ["c", "d"]
  raise "wrong layer 2 rank 1" unless result[1][0] == ["A", "B"]
  raise "wrong layer 2 rank 2" unless result[1][1] == ["C", "D"]
end

Test("parses 3D board with 3 layers") do
  result = PiecePlacement.parse("2/2//2/2//2/2")
  raise "expected 3 layers" unless result.size == 3
  result.each do |layer|
    raise "expected 2 ranks" unless layer.size == 2
  end
end

Test("parses Raumschach-like 5x5x5 board") do
  feen = (["5/5/5/5/5"] * 5).join("//")
  result = PiecePlacement.parse(feen)
  raise "expected 5 layers" unless result.size == 5
  result.each do |layer|
    raise "expected 5 ranks" unless layer.size == 5
    layer.each do |rank|
      raise "expected 5 squares" unless rank.size == 5
    end
  end
end

# ============================================================================
# RETURN STRUCTURE
# ============================================================================

puts
puts "return structure:"

Test("1D returns flat Array") do
  result = PiecePlacement.parse("K2Q")
  raise "expected Array" unless result.is_a?(Array)
  raise "should not be nested" if result[0].is_a?(Array)
end

Test("2D returns Array of Arrays") do
  result = PiecePlacement.parse("8/8")
  raise "expected Array" unless result.is_a?(Array)
  raise "expected nested Arrays" unless result[0].is_a?(Array)
  raise "should not be 3D" if result[0][0].is_a?(Array)
end

Test("3D returns Array of Array of Arrays") do
  result = PiecePlacement.parse("2/2//2/2")
  raise "expected Array" unless result.is_a?(Array)
  raise "expected nested" unless result[0].is_a?(Array)
  raise "expected 3D" unless result[0][0].is_a?(Array)
end

Test("pieces are Strings") do
  result = PiecePlacement.parse("K2Q")
  pieces = result.compact
  raise "expected all Strings" unless pieces.all? { |p| p.is_a?(String) }
end

Test("empty squares are nil") do
  result = PiecePlacement.parse("1K1")
  raise "first should be nil" unless result[0].nil?
  raise "last should be nil" unless result[2].nil?
end

# ============================================================================
# INVALID INPUTS - EMPTY / BOUNDARIES
# ============================================================================

puts
puts "invalid inputs - empty / boundaries:"

Test("raises for empty string") do
  PiecePlacement.parse("")
  raise "should have raised"
rescue PiecePlacementError
  # Expected
end

Test("raises for leading separator") do
  PiecePlacement.parse("/K")
  raise "should have raised"
rescue PiecePlacementError
  # Expected
end

Test("raises for trailing separator") do
  PiecePlacement.parse("K/")
  raise "should have raised"
rescue PiecePlacementError
  # Expected
end

# ============================================================================
# INVALID INPUTS - EMPTY COUNTS
# ============================================================================

puts
puts "invalid inputs - empty counts:"

Test("raises for zero count") do
  PiecePlacement.parse("0")
  raise "should have raised"
rescue PiecePlacementError
  # Expected
end

Test("raises for leading zeros") do
  PiecePlacement.parse("01")
  raise "should have raised"
rescue PiecePlacementError
  # Expected
end

Test("raises for leading zeros on larger number") do
  PiecePlacement.parse("007")
  raise "should have raised"
rescue PiecePlacementError
  # Expected
end

# ============================================================================
# INVALID INPUTS - PIECE TOKENS
# ============================================================================

puts
puts "invalid inputs - piece tokens:"

Test("raises for invalid character") do
  PiecePlacement.parse("@")
  raise "should have raised"
rescue PiecePlacementError
  # Expected
end

Test("raises for space in input") do
  PiecePlacement.parse("K Q")
  raise "should have raised"
rescue PiecePlacementError
  # Expected
end

# ============================================================================
# INVALID INPUTS - DIMENSIONAL COHERENCE
# ============================================================================

puts
puts "invalid inputs - dimensional coherence:"

Test("raises for // without / between") do
  PiecePlacement.parse("K//Q")
  raise "should have raised"
rescue PiecePlacementError
  # Expected
end

Test("raises for /// without // between") do
  PiecePlacement.parse("K/Q//R/S///A/B")
  raise "should have raised"
rescue PiecePlacementError
  # Expected
end

# ============================================================================
# INVALID INPUTS - DIMENSION LIMITS
# ============================================================================

puts
puts "invalid inputs - dimension limits:"

Test("raises for exceeding max dimensions") do
  PiecePlacement.parse("1/1//1/1///1/1//1/1////1")
  raise "should have raised"
rescue PiecePlacementError
  # Expected
end

Test("raises for dimension size exceeded") do
  PiecePlacement.parse("256")
  raise "should have raised"
rescue PiecePlacementError
  # Expected
end

Test("accepts max dimension size 255") do
  result = PiecePlacement.parse("255")
  raise "expected 255 nils" unless result.size == 255
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
puts "All Parser::PiecePlacement tests passed!"
puts
