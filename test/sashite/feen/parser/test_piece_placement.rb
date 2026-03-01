#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/parser/piece_placement"

puts
puts "=== Parser::PiecePlacement Tests ==="
puts

PP = Sashite::Feen::Parser::PiecePlacement
PPE = Sashite::Feen::PiecePlacementError

# ============================================================================
# SAFE_PARSE - 1D BOARDS
# ============================================================================

puts "safe_parse - 1D boards:"

Test("single piece") do
  raise unless PP.safe_parse("K") == ["K"]
end

Test("empty squares") do
  raise unless PP.safe_parse("3") == [nil, nil, nil]
  raise unless PP.safe_parse("1") == [nil]
end

Test("pieces and empties mixed") do
  raise unless PP.safe_parse("K2Q") == ["K", nil, nil, "Q"]
  raise unless PP.safe_parse("K1Q1R") == ["K", nil, "Q", nil, "R"]
end

Test("all EPIN decorations") do
  raise unless PP.safe_parse("K^")   == ["K^"]
  raise unless PP.safe_parse("+p")   == ["+p"]
  raise unless PP.safe_parse("-R")   == ["-R"]
  raise unless PP.safe_parse("+K^'") == ["+K^'"]
  raise unless PP.safe_parse("K^2k^") == ["K^", nil, nil, "k^"]
end

Test("large empty count") do
  raise unless PP.safe_parse("255").size == 255
end

# ============================================================================
# SAFE_PARSE - 2D BOARDS
# ============================================================================

puts
puts "safe_parse - 2D boards:"

Test("empty 8x8 board") do
  r = PP.safe_parse("8/8/8/8/8/8/8/8")
  raise unless r.size == 8
  raise unless r.all? { |rank| rank.size == 8 && rank.all?(&:nil?) }
end

Test("chess initial position") do
  r = PP.safe_parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR")
  raise unless r.size == 8
  raise unless r[0] == %w[r n b q k b n r]
  raise unless r[1] == %w[p p p p p p p p]
  raise unless r[2] == [nil] * 8
end

Test("shogi initial position") do
  r = PP.safe_parse("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL")
  raise unless r.size == 9
  raise unless r[0].size == 9
end

Test("xiangqi initial position") do
  r = PP.safe_parse("rheagaehr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RHEAGAEHR")
  raise unless r.size == 10
  raise unless r[0].size == 9
end

Test("minimal 2D board") do
  raise unless PP.safe_parse("K/k") == [["K"], ["k"]]
end

Test("decorated pieces in 2D") do
  raise unless PP.safe_parse("K^+p/2") == [["K^", "+p"], [nil, nil]]
end

# ============================================================================
# SAFE_PARSE - 3D BOARDS
# ============================================================================

puts
puts "safe_parse - 3D boards:"

Test("minimal 3D board") do
  r = PP.safe_parse("2/2//2/2")
  raise unless r.size == 2
  raise unless r[0].size == 2
  raise unless r[0][0].size == 2
end

Test("3D board with pieces") do
  raise unless PP.safe_parse("ab/cd//AB/CD") == [[["a","b"],["c","d"]], [["A","B"],["C","D"]]]
end

Test("3D board with 3 layers") do
  r = PP.safe_parse("2/2//2/2//2/2")
  raise unless r.size == 3
  raise unless r.all? { |l| l.size == 2 }
end

Test("raumschach-like 5x5x5") do
  r = PP.safe_parse((["5/5/5/5/5"] * 5).join("//"))
  raise unless r.size == 5
  raise unless r[0].size == 5
  raise unless r[0][0].size == 5
end

# ============================================================================
# SAFE_PARSE - INVALID INPUTS (returns nil)
# ============================================================================

puts
puts "safe_parse - invalid inputs:"

Test("structural issues return nil") do
  raise if PP.safe_parse("")      # empty
  raise if PP.safe_parse("/K")    # starts with separator
  raise if PP.safe_parse("K/")    # ends with separator
end

Test("invalid empty counts return nil") do
  raise if PP.safe_parse("01")    # leading zeros
  raise if PP.safe_parse("00")    # leading zeros
end

Test("invalid piece token returns nil") do
  raise if PP.safe_parse("@")
  raise if PP.safe_parse("+")     # modifier without letter
  raise if PP.safe_parse("-")     # modifier without letter
end

Test("exceeds max dimensions returns nil") do
  raise if PP.safe_parse("a///b") # 4D
end

Test("dimensional coherence issues return nil") do
  raise if PP.safe_parse("a//b")           # single rank in 3D layer
  raise if PP.safe_parse("a/b//c/d/e")     # unequal rank counts
  raise if PP.safe_parse("a//b/c")         # first layer 1 rank, second 2 ranks
end

Test("dimension size exceeded returns nil") do
  raise if PP.safe_parse("256")   # 256 > 255
end

# ============================================================================
# PARSE - VALID INPUTS
# ============================================================================

puts
puts "parse - valid inputs:"

Test("returns correct structures for all dimensions") do
  raise unless PP.parse("K") == ["K"]
  raise unless PP.parse("K/k") == [["K"], ["k"]]
  raise unless PP.parse("ab/cd//AB/CD") == [[["a","b"],["c","d"]], [["A","B"],["C","D"]]]
end

# ============================================================================
# PARSE - ERROR MESSAGES
# ============================================================================

puts
puts "parse - error messages:"

Test("EMPTY") do
  PP.parse(""); raise "x"
rescue PPE => e; raise unless e.message == PPE::EMPTY
end

Test("STARTS_WITH_SEPARATOR") do
  PP.parse("/K"); raise "x"
rescue PPE => e; raise unless e.message == PPE::STARTS_WITH_SEPARATOR
end

Test("ENDS_WITH_SEPARATOR") do
  PP.parse("K/"); raise "x"
rescue PPE => e; raise unless e.message == PPE::ENDS_WITH_SEPARATOR
end

Test("INVALID_EMPTY_COUNT") do
  PP.parse("01"); raise "x"
rescue PPE => e; raise unless e.message == PPE::INVALID_EMPTY_COUNT
end

Test("INVALID_PIECE_TOKEN") do
  PP.parse("@"); raise "x"
rescue PPE => e; raise unless e.message == PPE::INVALID_PIECE_TOKEN
end

Test("EXCEEDS_MAX_DIMENSIONS") do
  PP.parse("a///b"); raise "x"
rescue PPE => e; raise unless e.message == PPE::EXCEEDS_MAX_DIMENSIONS
end

Test("DIMENSIONAL_COHERENCE") do
  PP.parse("a//b"); raise "x"
rescue PPE => e; raise unless e.message == PPE::DIMENSIONAL_COHERENCE
end

Test("DIMENSION_SIZE_EXCEEDED") do
  PP.parse("256"); raise "x"
rescue PPE => e; raise unless e.message == PPE::DIMENSION_SIZE_EXCEEDED
end

Test("EMPTY_SEGMENT") do
  PP.parse("K//"); raise "x"
rescue PPE; end

# ============================================================================
# MODULE PROPERTIES
# ============================================================================

puts
puts "module properties:"

Test("module is frozen") do
  raise unless PP.frozen?
end

puts
puts "All Parser::PiecePlacement tests passed!"
puts
