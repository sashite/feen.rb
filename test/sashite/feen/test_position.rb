#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../helper"
require_relative "../../../lib/sashite/feen/parser"
require_relative "../../../lib/sashite/feen/position"

puts
puts "=== Position Tests ==="
puts

# Helper to create Position from FEEN string
def parse_position(input)
  parsed = Sashite::Feen::Parser.parse(input)
  Sashite::Feen::Position.new(**parsed)
end

# ============================================================================
# INITIALIZATION
# ============================================================================

puts "Initialization:"

run_test("creates instance from parsed data") do
  position = parse_position("K / C/c")
  raise "wrong type" unless position.is_a?(Sashite::Feen::Position)
end

run_test("instance is frozen") do
  position = parse_position("K / C/c")
  raise "should be frozen" unless position.frozen?
end

run_test("creates all three components") do
  position = parse_position("K / C/c")
  raise "missing piece_placement" unless position.piece_placement
  raise "missing hands" unless position.hands
  raise "missing style_turn" unless position.style_turn
end

# ============================================================================
# PIECE_PLACEMENT ACCESSOR
# ============================================================================

puts
puts "piece_placement accessor:"

run_test("returns PiecePlacement instance") do
  position = parse_position("K / C/c")
  raise "wrong type" unless position.piece_placement.is_a?(Sashite::Feen::Position::PiecePlacement)
end

run_test("piece_placement has correct data") do
  position = parse_position("K2Q / C/c")
  raise "wrong squares_count" unless position.piece_placement.squares_count == 4
  raise "wrong pieces_count" unless position.piece_placement.pieces_count == 2
end

run_test("piece_placement is frozen") do
  position = parse_position("K / C/c")
  raise "should be frozen" unless position.piece_placement.frozen?
end

# ============================================================================
# HANDS ACCESSOR
# ============================================================================

puts
puts "hands accessor:"

run_test("returns Hands instance") do
  position = parse_position("K / C/c")
  raise "wrong type" unless position.hands.is_a?(Sashite::Feen::Position::Hands)
end

run_test("hands has correct data (empty)") do
  position = parse_position("K / C/c")
  raise "first should be empty" unless position.hands.first.empty?
  raise "second should be empty" unless position.hands.second.empty?
end

run_test("hands has correct data (with pieces)") do
  position = parse_position("K5 3P/2p C/c")
  raise "first should not be empty" if position.hands.first.empty?
  raise "second should not be empty" if position.hands.second.empty?
  raise "wrong first count" unless position.hands.first.pieces_count == 3
  raise "wrong second count" unless position.hands.second.pieces_count == 2
end

run_test("hands is frozen") do
  position = parse_position("K / C/c")
  raise "should be frozen" unless position.hands.frozen?
end

# ============================================================================
# STYLE_TURN ACCESSOR
# ============================================================================

puts
puts "style_turn accessor:"

run_test("returns StyleTurn instance") do
  position = parse_position("K / C/c")
  raise "wrong type" unless position.style_turn.is_a?(Sashite::Feen::Position::StyleTurn)
end

run_test("style_turn has correct data (first to move)") do
  position = parse_position("K / C/c")
  raise "should be first to move" unless position.style_turn.first_to_move?
end

run_test("style_turn has correct data (second to move)") do
  position = parse_position("K / c/C")
  raise "should be second to move" unless position.style_turn.second_to_move?
end

run_test("style_turn has correct styles") do
  position = parse_position("K / C/s")
  raise "wrong active abbr" unless position.style_turn.active_style.abbr == :C
  raise "wrong inactive abbr" unless position.style_turn.inactive_style.abbr == :S
end

run_test("style_turn is frozen") do
  position = parse_position("K / C/c")
  raise "should be frozen" unless position.style_turn.frozen?
end

# ============================================================================
# SQUARES_COUNT
# ============================================================================

puts
puts "squares_count:"

run_test("returns correct count for single piece") do
  position = parse_position("K / C/c")
  raise "wrong count" unless position.squares_count == 1
end

run_test("returns correct count for empty board") do
  position = parse_position("8 / C/c")
  raise "wrong count" unless position.squares_count == 8
end

run_test("returns correct count for Chess board") do
  position = parse_position("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c")
  raise "wrong count" unless position.squares_count == 64
end

run_test("returns correct count for Shogi board") do
  position = parse_position("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s")
  raise "wrong count" unless position.squares_count == 81
end

run_test("returns correct count for 3D board") do
  position = parse_position("4/4//4/4 / C/c")
  raise "wrong count" unless position.squares_count == 16
end

run_test("delegates to piece_placement") do
  position = parse_position("K2Q / C/c")
  raise "should match piece_placement" unless position.squares_count == position.piece_placement.squares_count
end

# ============================================================================
# PIECES_COUNT
# ============================================================================

puts
puts "pieces_count:"

run_test("returns correct count for board only") do
  position = parse_position("K / C/c")
  raise "wrong count" unless position.pieces_count == 1
end

run_test("returns correct count for empty board") do
  position = parse_position("8 / C/c")
  raise "wrong count" unless position.pieces_count == 0
end

run_test("returns correct count for hands only") do
  position = parse_position("8 3P/2p C/c")
  raise "wrong count" unless position.pieces_count == 5
end

run_test("returns correct count for board and hands") do
  position = parse_position("K5 3P/2p C/c")
  # 1 on board + 3 in first hand + 2 in second hand = 6
  raise "wrong count" unless position.pieces_count == 6
end

run_test("returns correct count for Chess initial position") do
  position = parse_position("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c")
  raise "wrong count" unless position.pieces_count == 32
end

run_test("returns correct count for Shogi initial position") do
  position = parse_position("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s")
  raise "wrong count" unless position.pieces_count == 40
end

run_test("sums board and hands correctly") do
  position = parse_position("K2Q4 3P/2p C/c")
  board_pieces = position.piece_placement.pieces_count
  hand_pieces = position.hands.pieces_count
  raise "should sum correctly" unless position.pieces_count == board_pieces + hand_pieces
end

# ============================================================================
# TO_S
# ============================================================================

puts
puts "to_s:"

run_test("serializes minimal position") do
  position = parse_position("K / C/c")
  raise "wrong string" unless position.to_s == "K / C/c"
end

run_test("serializes position with hands") do
  position = parse_position("K5 3P/2p C/c")
  raise "wrong string" unless position.to_s == "K5 3P/2p C/c"
end

run_test("serializes Chess initial position") do
  input = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c"
  position = parse_position(input)
  raise "wrong string" unless position.to_s == input
end

run_test("serializes Shogi initial position") do
  input = "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s"
  position = parse_position(input)
  raise "wrong string" unless position.to_s == input
end

run_test("serializes 3D position") do
  input = "4/4//4/4 / C/c"
  position = parse_position(input)
  raise "wrong string" unless position.to_s == input
end

run_test("serializes cross-style position") do
  input = "K / C/s"
  position = parse_position(input)
  raise "wrong string" unless position.to_s == input
end

run_test("serializes second-to-move position") do
  input = "K / c/C"
  position = parse_position(input)
  raise "wrong string" unless position.to_s == input
end

run_test("round-trip preserves original") do
  inputs = [
    "K / C/c",
    "8 / C/c",
    "K5 3P/2p C/c",
    "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c",
    "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s",
    "4/4//4/4 / C/c",
    "K / C/s",
    "K / c/C",
    "+K^'5 3+P^'/2-p^' C/s"
  ]
  inputs.each do |input|
    position = parse_position(input)
    raise "round-trip failed for '#{input}'" unless position.to_s == input
  end
end

# ============================================================================
# EQUALITY
# ============================================================================

puts
puts "Equality:"

run_test("equal positions are ==") do
  p1 = parse_position("K5 3P/2p C/c")
  p2 = parse_position("K5 3P/2p C/c")
  raise "should be equal" unless p1 == p2
end

run_test("different piece_placement are not ==") do
  p1 = parse_position("K / C/c")
  p2 = parse_position("Q / C/c")
  raise "should not be equal" if p1 == p2
end

run_test("different hands are not ==") do
  p1 = parse_position("K3 3P/ C/c")
  p2 = parse_position("K3 2P/ C/c")
  raise "should not be equal" if p1 == p2
end

run_test("different style_turn are not ==") do
  p1 = parse_position("K / C/c")
  p2 = parse_position("K / c/C")
  raise "should not be equal" if p1 == p2
end

run_test("== returns false for non-Position") do
  position = parse_position("K / C/c")
  raise "should not be equal to string" if position == "K / C/c"
  raise "should not be equal to nil" if position == nil
  raise "should not be equal to array" if position == []
end

run_test("eql? is aliased to ==") do
  p1 = parse_position("K5 3P/2p C/c")
  p2 = parse_position("K5 3P/2p C/c")
  raise "eql? should work" unless p1.eql?(p2)
end

# ============================================================================
# HASH
# ============================================================================

puts
puts "Hash:"

run_test("equal positions have same hash") do
  p1 = parse_position("K5 3P/2p C/c")
  p2 = parse_position("K5 3P/2p C/c")
  raise "hashes should be equal" unless p1.hash == p2.hash
end

run_test("different positions have different hash") do
  p1 = parse_position("K / C/c")
  p2 = parse_position("Q / C/c")
  raise "hashes should differ" if p1.hash == p2.hash
end

run_test("can be used as hash key") do
  p1 = parse_position("K5 3P/2p C/c")
  p2 = parse_position("K5 3P/2p C/c")
  hash = { p1 => "value" }
  raise "should find by equal key" unless hash[p2] == "value"
end

run_test("different positions as separate hash keys") do
  p1 = parse_position("K / C/c")
  p2 = parse_position("Q / C/c")
  hash = { p1 => "first", p2 => "second" }
  raise "should have 2 keys" unless hash.size == 2
  raise "wrong value for p1" unless hash[p1] == "first"
  raise "wrong value for p2" unless hash[p2] == "second"
end

# ============================================================================
# INSPECT
# ============================================================================

puts
puts "Inspect:"

run_test("inspect includes class name") do
  position = parse_position("K / C/c")
  raise "should include class" unless position.inspect.include?("Position")
end

run_test("inspect includes string representation") do
  position = parse_position("K5 3P/2p C/c")
  raise "should include to_s" unless position.inspect.include?("K5 3P/2p C/c")
end

run_test("inspect format is #<Class string>") do
  position = parse_position("K / C/c")
  raise "wrong format" unless position.inspect.match?(/^#<.*Position.*K \/ C\/c>$/)
end

# ============================================================================
# INTEGRATION
# ============================================================================

puts
puts "Integration:"

run_test("all components work together") do
  position = parse_position("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR 2P/p C/c")

  # Piece placement
  raise "wrong squares" unless position.squares_count == 64
  raise "wrong board pieces" unless position.piece_placement.pieces_count == 32
  raise "wrong dimensions" unless position.piece_placement.dimensions == 2

  # Hands
  raise "wrong first hand" unless position.hands.first.pieces_count == 2
  raise "wrong second hand" unless position.hands.second.pieces_count == 1

  # Style turn
  raise "should be first to move" unless position.style_turn.first_to_move?
  raise "wrong active style" unless position.style_turn.active_style.abbr == :C

  # Total
  raise "wrong total pieces" unless position.pieces_count == 35
end

run_test("can iterate over piece placement") do
  position = parse_position("K2Q / C/c")
  tokens = position.piece_placement.to_a
  raise "wrong token count" unless tokens.size == 3
end

run_test("can iterate over hands") do
  position = parse_position("K5 3B2P/ C/c")
  pieces = []
  position.hands.first.each { |piece, count| pieces << [piece.to_s, count] }
  raise "wrong pieces" unless pieces == [["B", 3], ["P", 2]]
end

# ============================================================================
# CLASS STRUCTURE
# ============================================================================

puts
puts "Class structure:"

run_test("Position is a Class") do
  raise "wrong type" unless Sashite::Feen::Position.is_a?(Class)
end

run_test("Position is nested under Sashite::Feen") do
  raise "wrong nesting" unless Sashite::Feen.const_defined?(:Position)
end

run_test("PiecePlacement is nested under Position") do
  raise "wrong nesting" unless Sashite::Feen::Position.const_defined?(:PiecePlacement)
end

run_test("Hands is nested under Position") do
  raise "wrong nesting" unless Sashite::Feen::Position.const_defined?(:Hands)
end

run_test("StyleTurn is nested under Position") do
  raise "wrong nesting" unless Sashite::Feen::Position.const_defined?(:StyleTurn)
end

puts
puts "All Position tests passed!"
puts
