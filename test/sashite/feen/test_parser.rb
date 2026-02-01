#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../helper"
require_relative "../../../lib/sashite/feen/parser"

puts
puts "=== Parser Tests ==="
puts

Parser = Sashite::Feen::Parser
ParseError = Sashite::Feen::ParseError
CardinalityError = Sashite::Feen::CardinalityError
PiecePlacementError = Sashite::Feen::PiecePlacementError
HandsError = Sashite::Feen::HandsError
StyleTurnError = Sashite::Feen::StyleTurnError

# ============================================================================
# PARSE - VALID INPUTS
# ============================================================================

puts "parse - valid inputs:"

run_test("parses minimal FEEN string") do
  result = Parser.parse("K / C/c")
  raise "expected Hash" unless ::Hash === result
  raise "expected :piece_placement" unless result.key?(:piece_placement)
  raise "expected :hands" unless result.key?(:hands)
  raise "expected :style_turn" unless result.key?(:style_turn)
end

run_test("parses Chess initial position") do
  result = Parser.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c")
  raise "expected 8 segments" unless result[:piece_placement][:segments].size == 8
end

run_test("parses Shogi initial position") do
  result = Parser.parse("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s")
  raise "expected 9 segments" unless result[:piece_placement][:segments].size == 9
end

run_test("parses position with pieces in hands") do
  result = Parser.parse("8/8/8/8/8/8/8/8 3BNP/2qp C/c")
  raise "expected 3 items in first hand" unless result[:hands][:first].size == 3
  raise "expected 2 items in second hand" unless result[:hands][:second].size == 2
end

run_test("parses 3D position") do
  result = Parser.parse("4/4//4/4 / C/c")
  raise "expected '//' separator" unless result[:piece_placement][:separators].include?("//")
end

run_test("parses cross-style game") do
  result = Parser.parse("K / C/s")
  raise "expected C active" unless result[:style_turn][:active].abbr == :C
  raise "expected S inactive" unless result[:style_turn][:inactive].abbr == :S
end

run_test("parses second player to move") do
  result = Parser.parse("K / c/C")
  raise "expected second active" unless result[:style_turn][:active].side == :second
end

run_test("parses empty board") do
  result = Parser.parse("8/8/8/8/8/8/8/8 / C/c")
  # No pieces on board, no pieces in hands
  board_pieces = result[:piece_placement][:segments].sum { |s| s.count { |t| !(::Integer === t) } }
  raise "expected 0 board pieces" unless board_pieces == 0
end

run_test("parses maximum board pieces") do
  # 4 squares, 4 pieces on board, 0 in hands
  result = Parser.parse("KQkq / C/c")
  raise "expected 4 tokens" unless result[:piece_placement][:segments][0].size == 4
end

# ============================================================================
# PARSE - INVALID INPUTS - GENERAL
# ============================================================================

puts
puts "parse - invalid inputs - general:"

run_test("raises for empty string") do
  Parser.parse("")
  raise "should have raised"
rescue ParseError => e
  raise "wrong message" unless e.message == ParseError::INVALID_FIELD_COUNT
end

run_test("raises for one field") do
  Parser.parse("K")
  raise "should have raised"
rescue ParseError => e
  raise "wrong message" unless e.message == ParseError::INVALID_FIELD_COUNT
end

run_test("raises for two fields") do
  Parser.parse("K /")
  raise "should have raised"
rescue ParseError => e
  raise "wrong message" unless e.message == ParseError::INVALID_FIELD_COUNT
end

run_test("raises for four fields") do
  Parser.parse("K / C/c extra")
  raise "should have raised"
rescue ParseError => e
  raise "wrong message" unless e.message == ParseError::INVALID_FIELD_COUNT
end

run_test("raises for string too long") do
  long_input = "K" + ("/" + "8" * 255) * 16 + " / C/c"
  # Make sure it exceeds 4096 bytes
  long_input = "K" * 4097 + " / C/c" if long_input.bytesize <= 4096
  Parser.parse(long_input)
  raise "should have raised"
rescue ParseError => e
  raise "wrong message" unless e.message == ParseError::INPUT_TOO_LONG
end

# ============================================================================
# PARSE - INVALID INPUTS - PIECE PLACEMENT
# ============================================================================

puts
puts "parse - invalid inputs - piece placement:"

run_test("raises for invalid piece placement (starts with separator)") do
  Parser.parse("/K / C/c")
  raise "should have raised"
rescue PiecePlacementError => e
  raise "wrong message" unless e.message == PiecePlacementError::STARTS_WITH_SEPARATOR
end

run_test("raises for invalid empty count") do
  Parser.parse("0 / C/c")
  raise "should have raised"
rescue PiecePlacementError => e
  raise "wrong message" unless e.message == PiecePlacementError::INVALID_EMPTY_COUNT
end

# ============================================================================
# PARSE - INVALID INPUTS - HANDS
# ============================================================================

puts
puts "parse - invalid inputs - hands:"

run_test("raises for invalid hands delimiter") do
  Parser.parse("K P C/c")
  raise "should have raised"
rescue HandsError => e
  raise "wrong message" unless e.message == HandsError::INVALID_DELIMITER
end

run_test("raises for non-aggregated hands") do
  Parser.parse("K PP/ C/c")
  raise "should have raised"
rescue HandsError => e
  raise "wrong message" unless e.message == HandsError::NOT_AGGREGATED
end

run_test("raises for non-canonical hands") do
  Parser.parse("K BA/ C/c")
  raise "should have raised"
rescue HandsError => e
  raise "wrong message" unless e.message == HandsError::NOT_CANONICAL
end

# ============================================================================
# PARSE - INVALID INPUTS - STYLE-TURN
# ============================================================================

puts
puts "parse - invalid inputs - style-turn:"

run_test("raises for invalid style-turn delimiter") do
  Parser.parse("K / Cc")
  raise "should have raised"
rescue StyleTurnError => e
  raise "wrong message" unless e.message == StyleTurnError::INVALID_DELIMITER
end

run_test("raises for same case styles") do
  Parser.parse("K / C/C")
  raise "should have raised"
rescue StyleTurnError => e
  raise "wrong message" unless e.message == StyleTurnError::SAME_CASE
end

run_test("raises for invalid style token") do
  Parser.parse("K / 1/c")
  raise "should have raised"
rescue StyleTurnError => e
  raise "wrong message" unless e.message == StyleTurnError::INVALID_STYLE_TOKEN
end

# ============================================================================
# PARSE - INVALID INPUTS - CARDINALITY
# ============================================================================

puts
puts "parse - invalid inputs - cardinality:"

run_test("raises for too many pieces (hands exceed board capacity)") do
  # 1 square on board, 2 pieces in hands = 2 pieces > 1 square
  Parser.parse("1 2P/ C/c")
  raise "should have raised"
rescue CardinalityError => e
  raise "wrong message" unless e.message == CardinalityError::TOO_MANY_PIECES
end

run_test("raises for too many pieces (board + hands combined)") do
  # 2 squares, 1 on board, 2 in hands = 3 pieces > 2 squares
  Parser.parse("K1 2P/ C/c")
  raise "should have raised"
rescue CardinalityError => e
  raise "wrong message" unless e.message == CardinalityError::TOO_MANY_PIECES
end

run_test("raises for too many pieces (both hands)") do
  # 1 square, 0 on board, 1+1 in hands = 2 pieces > 1 square
  Parser.parse("1 P/p C/c")
  raise "should have raised"
rescue CardinalityError => e
  raise "wrong message" unless e.message == CardinalityError::TOO_MANY_PIECES
end

run_test("allows equal pieces and squares") do
  # 4 squares, 4 pieces on board
  result = Parser.parse("KQkq / C/c")
  raise "should have parsed" unless result[:piece_placement]
end

run_test("allows fewer pieces than squares") do
  # 8 squares, 2 pieces on board
  result = Parser.parse("K6q / C/c")
  raise "should have parsed" unless result[:piece_placement]
end

run_test("allows pieces in hands within capacity") do
  # 4 squares, 2 on board, 2 in hands = 4 pieces = 4 squares
  result = Parser.parse("K1k1 P/p C/c")
  raise "should have parsed" unless result[:piece_placement]
end

# ============================================================================
# VALID? - TRUE CASES
# ============================================================================

puts
puts "valid? - true cases:"

run_test("returns true for minimal FEEN") do
  raise "should be valid" unless Parser.valid?("K / C/c")
end

run_test("returns true for Chess initial position") do
  raise "should be valid" unless Parser.valid?("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c")
end

run_test("returns true for position with hands") do
  raise "should be valid" unless Parser.valid?("8/8/8/8/8/8/8/8 3BNP/2qp C/c")
end

run_test("returns true for 3D position") do
  raise "should be valid" unless Parser.valid?("4/4//4/4 / C/c")
end

run_test("returns true for empty board") do
  raise "should be valid" unless Parser.valid?("8 / C/c")
end

# ============================================================================
# VALID? - FALSE CASES
# ============================================================================

puts
puts "valid? - false cases:"

run_test("returns false for nil") do
  raise "should be invalid" if Parser.valid?(nil)
end

run_test("returns false for Integer") do
  raise "should be invalid" if Parser.valid?(123)
end

run_test("returns false for Array") do
  raise "should be invalid" if Parser.valid?([])
end

run_test("returns false for empty string") do
  raise "should be invalid" if Parser.valid?("")
end

run_test("returns false for invalid piece placement") do
  raise "should be invalid" if Parser.valid?("/K / C/c")
end

run_test("returns false for invalid hands") do
  raise "should be invalid" if Parser.valid?("K PP/ C/c")
end

run_test("returns false for invalid style-turn") do
  raise "should be invalid" if Parser.valid?("K / C/C")
end

run_test("returns false for too many pieces") do
  raise "should be invalid" if Parser.valid?("K 2P/ C/c")
end

run_test("returns false for string too long") do
  raise "should be invalid" if Parser.valid?("K" * 4097 + " / C/c")
end

# ============================================================================
# ERROR HIERARCHY
# ============================================================================

puts
puts "Error hierarchy:"

run_test("ParseError is rescued by ArgumentError") do
  Parser.parse("")
  raise "should have raised"
rescue ArgumentError
  # Expected
end

run_test("PiecePlacementError is rescued by ParseError") do
  Parser.parse("/K / C/c")
  raise "should have raised"
rescue ParseError
  # Expected
end

run_test("HandsError is rescued by ParseError") do
  Parser.parse("K PP/ C/c")
  raise "should have raised"
rescue ParseError
  # Expected
end

run_test("StyleTurnError is rescued by ParseError") do
  Parser.parse("K / C/C")
  raise "should have raised"
rescue ParseError
  # Expected
end

run_test("CardinalityError is rescued by ParseError") do
  Parser.parse("K 2P/ C/c")
  raise "should have raised"
rescue ParseError
  # Expected
end

# ============================================================================
# MODULE STRUCTURE
# ============================================================================

puts
puts "Module structure:"

run_test("module is frozen") do
  raise "expected frozen" unless Parser.frozen?
end

run_test("has parse and valid? public methods") do
  public_methods = Parser.methods(false) - Object.methods
  raise "expected :parse" unless public_methods.include?(:parse)
  raise "expected :valid?" unless public_methods.include?(:valid?)
end

run_test("FIELD_COUNT constant is 3") do
  raise "expected 3" unless Parser::FIELD_COUNT == 3
end

# ============================================================================
# REAL-WORLD EXAMPLES
# ============================================================================

puts
puts "Real-world examples:"

run_test("parses and validates Chess initial position") do
  feen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c"
  raise "should be valid" unless Parser.valid?(feen)
  result = Parser.parse(feen)
  # 64 squares, 32 pieces
  squares = result[:piece_placement][:segments].sum { |s| s.sum { |t| ::Integer === t ? t : 1 } }
  pieces = result[:piece_placement][:segments].sum { |s| s.count { |t| !(::Integer === t) } }
  raise "expected 64 squares" unless squares == 64
  raise "expected 32 pieces" unless pieces == 32
end

run_test("parses and validates Shogi initial position") do
  feen = "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s"
  raise "should be valid" unless Parser.valid?(feen)
  result = Parser.parse(feen)
  # 81 squares, 40 pieces
  squares = result[:piece_placement][:segments].sum { |s| s.sum { |t| ::Integer === t ? t : 1 } }
  pieces = result[:piece_placement][:segments].sum { |s| s.count { |t| !(::Integer === t) } }
  raise "expected 81 squares" unless squares == 81
  raise "expected 40 pieces" unless pieces == 40
end

run_test("parses and validates Xiangqi initial position") do
  feen = "rheagaehr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RHEAGAEHR / X/x"
  raise "should be valid" unless Parser.valid?(feen)
  result = Parser.parse(feen)
  # 90 squares
  squares = result[:piece_placement][:segments].sum { |s| s.sum { |t| ::Integer === t ? t : 1 } }
  raise "expected 90 squares" unless squares == 90
end

run_test("parses mid-game position with hands") do
  # Shogi mid-game: some pieces captured
  feen = "lnsgkgsnl/7b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL R/r S/s"
  raise "should be valid" unless Parser.valid?(feen)
  result = Parser.parse(feen)
  raise "expected R in first hand" unless result[:hands][:first].any? { |i| i[:piece].to_s == "R" }
  raise "expected r in second hand" unless result[:hands][:second].any? { |i| i[:piece].to_s == "r" }
end

puts
puts "All Parser tests passed!"
puts
