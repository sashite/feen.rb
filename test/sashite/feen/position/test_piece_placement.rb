#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/parser/piece_placement"
require_relative "../../../../lib/sashite/feen/position/piece_placement"

puts
puts "=== Position::PiecePlacement Tests ==="
puts

# Helper to create PiecePlacement from FEEN string
def parse_placement(input)
  parsed = Sashite::Feen::Parser::PiecePlacement.parse(input)
  Sashite::Feen::Position::PiecePlacement.new(**parsed)
end

# ============================================================================
# INITIALIZATION
# ============================================================================

puts "Initialization:"

run_test("creates instance from parsed data") do
  placement = parse_placement("K")
  raise "wrong type" unless placement.is_a?(Sashite::Feen::Position::PiecePlacement)
end

run_test("instance is frozen") do
  placement = parse_placement("K")
  raise "should be frozen" unless placement.frozen?
end

run_test("segments accessor returns segments") do
  placement = parse_placement("K/Q")
  raise "wrong segments count" unless placement.segments.size == 2
end

run_test("separators accessor returns separators") do
  placement = parse_placement("K/Q")
  raise "wrong separators count" unless placement.separators.size == 1
end

# ============================================================================
# SQUARES_COUNT
# ============================================================================

puts
puts "squares_count:"

run_test("counts single piece as 1 square") do
  placement = parse_placement("K")
  raise "wrong count" unless placement.squares_count == 1
end

run_test("counts empty squares") do
  placement = parse_placement("8")
  raise "wrong count" unless placement.squares_count == 8
end

run_test("counts mixed pieces and empty") do
  placement = parse_placement("K2Q")
  raise "wrong count" unless placement.squares_count == 4
end

run_test("counts across segments") do
  placement = parse_placement("8/8")
  raise "wrong count" unless placement.squares_count == 16
end

run_test("counts Chess board (64 squares)") do
  placement = parse_placement("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR")
  raise "wrong count" unless placement.squares_count == 64
end

run_test("counts Shogi board (81 squares)") do
  placement = parse_placement("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL")
  raise "wrong count" unless placement.squares_count == 81
end

run_test("counts Xiangqi board (90 squares)") do
  placement = parse_placement("rheagaehr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RHEAGAEHR")
  raise "wrong count" unless placement.squares_count == 90
end

run_test("counts 3D board") do
  placement = parse_placement("4/4//4/4")
  raise "wrong count" unless placement.squares_count == 16
end

# ============================================================================
# PIECES_COUNT
# ============================================================================

puts
puts "pieces_count:"

run_test("counts single piece") do
  placement = parse_placement("K")
  raise "wrong count" unless placement.pieces_count == 1
end

run_test("counts zero pieces on empty board") do
  placement = parse_placement("8")
  raise "wrong count" unless placement.pieces_count == 0
end

run_test("counts multiple pieces in segment") do
  placement = parse_placement("KQR")
  raise "wrong count" unless placement.pieces_count == 3
end

run_test("counts pieces with empty squares") do
  placement = parse_placement("K2Q")
  raise "wrong count" unless placement.pieces_count == 2
end

run_test("counts pieces across segments") do
  placement = parse_placement("K/Q/R")
  raise "wrong count" unless placement.pieces_count == 3
end

run_test("counts Chess initial position (32 pieces)") do
  placement = parse_placement("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR")
  raise "wrong count" unless placement.pieces_count == 32
end

run_test("counts Shogi initial position (40 pieces)") do
  placement = parse_placement("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL")
  raise "wrong count" unless placement.pieces_count == 40
end

run_test("counts pieces with modifiers") do
  placement = parse_placement("+K-QR'N")
  raise "wrong count" unless placement.pieces_count == 4
end

# ============================================================================
# DIMENSIONS
# ============================================================================

puts
puts "dimensions:"

run_test("returns 1 for 1D board (no separators)") do
  placement = parse_placement("K")
  raise "wrong dimensions" unless placement.dimensions == 1
end

run_test("returns 1 for 1D board with multiple pieces") do
  placement = parse_placement("K2Q3R")
  raise "wrong dimensions" unless placement.dimensions == 1
end

run_test("returns 2 for 2D board (single separators)") do
  placement = parse_placement("8/8")
  raise "wrong dimensions" unless placement.dimensions == 2
end

run_test("returns 2 for Chess board") do
  placement = parse_placement("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR")
  raise "wrong dimensions" unless placement.dimensions == 2
end

run_test("returns 3 for 3D board (double separators)") do
  placement = parse_placement("4/4//4/4")
  raise "wrong dimensions" unless placement.dimensions == 3
end

run_test("returns 3 for complex 3D board") do
  placement = parse_placement("1/1/1//1/1/1//1/1/1")
  raise "wrong dimensions" unless placement.dimensions == 3
end

# ============================================================================
# EACH
# ============================================================================

puts
puts "each:"

run_test("yields each token in segment") do
  placement = parse_placement("K2Q")
  tokens = []
  placement.each { |token| tokens << token }
  raise "wrong count" unless tokens.size == 3
end

run_test("yields pieces as Epin::Identifier") do
  placement = parse_placement("K")
  placement.each do |token|
    raise "wrong type" unless token.is_a?(Sashite::Epin::Identifier)
  end
end

run_test("yields empty counts as Integer") do
  placement = parse_placement("8")
  placement.each do |token|
    raise "wrong type" unless token.is_a?(Integer)
    raise "wrong value" unless token == 8
  end
end

run_test("yields tokens across segments") do
  placement = parse_placement("K/Q")
  tokens = []
  placement.each { |token| tokens << token }
  raise "wrong count" unless tokens.size == 2
end

run_test("returns Enumerator when no block given") do
  placement = parse_placement("K")
  enum = placement.each
  raise "wrong type" unless enum.is_a?(Enumerator)
end

run_test("Enumerator works correctly") do
  placement = parse_placement("K2Q")
  tokens = placement.each.to_a
  raise "wrong count" unless tokens.size == 3
end

# ============================================================================
# ENUMERABLE
# ============================================================================

puts
puts "Enumerable:"

run_test("includes Enumerable") do
  raise "should include Enumerable" unless Sashite::Feen::Position::PiecePlacement.include?(Enumerable)
end

run_test("responds to map") do
  placement = parse_placement("K")
  raise "should respond to map" unless placement.respond_to?(:map)
end

run_test("responds to select") do
  placement = parse_placement("K")
  raise "should respond to select" unless placement.respond_to?(:select)
end

run_test("responds to count") do
  placement = parse_placement("K")
  raise "should respond to count" unless placement.respond_to?(:count)
end

run_test("map works correctly") do
  placement = parse_placement("K2Q")
  result = placement.map { |t| t.is_a?(Integer) ? t : t.to_s }
  raise "wrong result" unless result == ["K", 2, "Q"]
end

run_test("select works correctly") do
  placement = parse_placement("K2Q")
  pieces = placement.select { |t| !t.is_a?(Integer) }
  raise "wrong count" unless pieces.size == 2
end

run_test("count with block works correctly") do
  placement = parse_placement("K2Q3R")
  piece_count = placement.count { |t| !t.is_a?(Integer) }
  raise "wrong count" unless piece_count == 3
end

run_test("to_a works correctly") do
  placement = parse_placement("K2Q")
  array = placement.to_a
  raise "wrong size" unless array.size == 3
end

# ============================================================================
# TO_S
# ============================================================================

puts
puts "to_s:"

run_test("serializes single piece") do
  placement = parse_placement("K")
  raise "wrong string" unless placement.to_s == "K"
end

run_test("serializes empty count") do
  placement = parse_placement("8")
  raise "wrong string" unless placement.to_s == "8"
end

run_test("serializes mixed segment") do
  placement = parse_placement("K2Q")
  raise "wrong string" unless placement.to_s == "K2Q"
end

run_test("serializes 2D board with separators") do
  placement = parse_placement("8/8")
  raise "wrong string" unless placement.to_s == "8/8"
end

run_test("serializes Chess initial position") do
  input = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
  placement = parse_placement(input)
  raise "wrong string" unless placement.to_s == input
end

run_test("serializes 3D board with double separators") do
  input = "4/4//4/4"
  placement = parse_placement(input)
  raise "wrong string" unless placement.to_s == input
end

run_test("serializes pieces with modifiers") do
  input = "+K^'"
  placement = parse_placement(input)
  raise "wrong string" unless placement.to_s == input
end

run_test("round-trip preserves original") do
  inputs = [
    "K",
    "8",
    "K2Q",
    "8/8/8/8/8/8/8/8",
    "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR",
    "4/4//4/4",
    "+K^'-q2R"
  ]
  inputs.each do |input|
    placement = parse_placement(input)
    raise "round-trip failed for #{input}" unless placement.to_s == input
  end
end

# ============================================================================
# EQUALITY
# ============================================================================

puts
puts "Equality:"

run_test("equal placements are ==") do
  p1 = parse_placement("K2Q")
  p2 = parse_placement("K2Q")
  raise "should be equal" unless p1 == p2
end

run_test("different placements are not ==") do
  p1 = parse_placement("K2Q")
  p2 = parse_placement("K3Q")
  raise "should not be equal" if p1 == p2
end

run_test("different separators are not ==") do
  p1 = parse_placement("K/Q")
  p2 = parse_placement("K//Q")
  raise "should not be equal" if p1 == p2
end

run_test("== returns false for non-PiecePlacement") do
  placement = parse_placement("K")
  raise "should not be equal to string" if placement == "K"
  raise "should not be equal to nil" if placement == nil
end

run_test("eql? is aliased to ==") do
  p1 = parse_placement("K2Q")
  p2 = parse_placement("K2Q")
  raise "eql? should work" unless p1.eql?(p2)
end

# ============================================================================
# HASH
# ============================================================================

puts
puts "Hash:"

run_test("equal placements have same hash") do
  p1 = parse_placement("K2Q")
  p2 = parse_placement("K2Q")
  raise "hashes should be equal" unless p1.hash == p2.hash
end

run_test("different placements have different hash") do
  p1 = parse_placement("K2Q")
  p2 = parse_placement("K3Q")
  # Note: hash collision is possible but unlikely
  raise "hashes should differ" if p1.hash == p2.hash
end

run_test("can be used as hash key") do
  p1 = parse_placement("K2Q")
  p2 = parse_placement("K2Q")
  hash = { p1 => "value" }
  raise "should find by equal key" unless hash[p2] == "value"
end

# ============================================================================
# INSPECT
# ============================================================================

puts
puts "Inspect:"

run_test("inspect includes class name") do
  placement = parse_placement("K")
  raise "should include class" unless placement.inspect.include?("PiecePlacement")
end

run_test("inspect includes string representation") do
  placement = parse_placement("K2Q")
  raise "should include to_s" unless placement.inspect.include?("K2Q")
end

run_test("inspect format is #<Class string>") do
  placement = parse_placement("K")
  raise "wrong format" unless placement.inspect.match?(/^#<.*PiecePlacement.*K>$/)
end

# ============================================================================
# CLASS STRUCTURE
# ============================================================================

puts
puts "Class structure:"

run_test("PiecePlacement is a Class") do
  raise "wrong type" unless Sashite::Feen::Position::PiecePlacement.is_a?(Class)
end

run_test("PiecePlacement is nested under Position") do
  raise "wrong nesting" unless Sashite::Feen::Position.const_defined?(:PiecePlacement)
end

puts
puts "All Position::PiecePlacement tests passed!"
puts
