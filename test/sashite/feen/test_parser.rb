#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../helper"
require_relative "../../../lib/sashite/feen/parser"

puts
puts "=== Parser Tests ==="
puts

Parser = Sashite::Feen::Parser

# ============================================================================
# PARSE - RETURNS Qi::Position
# ============================================================================

puts "parse - returns Qi::Position:"

run_test("returns a Qi::Position") do
  result = Parser.parse("K / C/c")
  raise "wrong type" unless result.is_a?(Qi::Position)
end

run_test("position has board accessor") do
  result = Parser.parse("K / C/c")
  raise "missing board" unless result.respond_to?(:board)
end

run_test("position has hands accessor") do
  result = Parser.parse("K / C/c")
  raise "missing hands" unless result.respond_to?(:hands)
end

run_test("position has styles accessor") do
  result = Parser.parse("K / C/c")
  raise "missing styles" unless result.respond_to?(:styles)
end

run_test("position has turn accessor") do
  result = Parser.parse("K / C/c")
  raise "missing turn" unless result.respond_to?(:turn)
end

# ============================================================================
# PARSE - BOARD
# ============================================================================

puts
puts "parse - board:"

run_test("1D board is flat array") do
  result = Parser.parse("K2Q / C/c")
  raise "expected flat array" if result.board[0].is_a?(Array)
  raise "wrong content" unless result.board == ["K", nil, nil, "Q"]
end

run_test("2D board is nested array") do
  result = Parser.parse("8/8/8/8/8/8/8/8 / C/c")
  raise "expected 8 ranks" unless result.board.size == 8
  raise "expected nested" unless result.board[0].is_a?(Array)
  raise "expected 8 squares" unless result.board[0].size == 8
end

run_test("3D board is doubly nested array") do
  result = Parser.parse("2/2//2/2 / C/c")
  raise "expected 2 layers" unless result.board.size == 2
  raise "expected nested" unless result.board[0][0].is_a?(Array)
end

run_test("pieces are EPIN strings") do
  result = Parser.parse("K^+p / C/c")
  raise "wrong first piece" unless result.board[0] == "K^"
  raise "wrong second piece" unless result.board[1] == "+p"
end

# ============================================================================
# PARSE - HANDS
# ============================================================================

puts
puts "parse - hands:"

run_test("empty hands") do
  result = Parser.parse("K / C/c")
  raise "wrong first" unless result.hands[:first] == []
  raise "wrong second" unless result.hands[:second] == []
end

run_test("first hand with pieces") do
  result = Parser.parse("8 2PN/ C/c")
  raise "wrong first hand" unless result.hands[:first] == ["P", "P", "N"]
  raise "wrong second hand" unless result.hands[:second] == []
end

run_test("both hands with pieces") do
  result = Parser.parse("8 2PN/p C/c")
  raise "wrong first hand" unless result.hands[:first] == ["P", "P", "N"]
  raise "wrong second hand" unless result.hands[:second] == ["p"]
end

run_test("hands are flat arrays of strings") do
  result = Parser.parse("8 2PB/2qr C/c")
  raise "expected Array" unless result.hands[:first].is_a?(Array)
  raise "expected Strings" unless result.hands[:first].all? { |p| p.is_a?(String) }
  raise "expected Array" unless result.hands[:second].is_a?(Array)
  raise "expected Strings" unless result.hands[:second].all? { |p| p.is_a?(String) }
end

# ============================================================================
# PARSE - STYLES AND TURN
# ============================================================================

puts
puts "parse - styles and turn:"

run_test("first player to move") do
  result = Parser.parse("K / C/c")
  raise "wrong turn" unless result.turn == :first
  raise "wrong first style" unless result.styles[:first] == "C"
  raise "wrong second style" unless result.styles[:second] == "c"
end

run_test("second player to move") do
  result = Parser.parse("K / c/C")
  raise "wrong turn" unless result.turn == :second
  raise "wrong first style" unless result.styles[:first] == "C"
  raise "wrong second style" unless result.styles[:second] == "c"
end

run_test("cross-style game") do
  result = Parser.parse("K / C/s")
  raise "wrong first style" unless result.styles[:first] == "C"
  raise "wrong second style" unless result.styles[:second] == "s"
  raise "wrong turn" unless result.turn == :first
end

# ============================================================================
# PARSE - REAL POSITIONS
# ============================================================================

puts
puts "parse - real positions:"

run_test("Chess initial position") do
  result = Parser.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c")
  raise "expected 8 ranks" unless result.board.size == 8
  raise "expected 64 squares" unless result.board.flatten.size == 64
  raise "wrong piece count" unless result.board.flatten.compact.size == 32
end

run_test("Shogi initial position") do
  result = Parser.parse("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s")
  raise "expected 9 ranks" unless result.board.size == 9
  raise "expected 81 squares" unless result.board.flatten.size == 81
end

run_test("Xiangqi initial position") do
  result = Parser.parse("rheagaehr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RHEAGAEHR / X/x")
  raise "expected 10 ranks" unless result.board.size == 10
  raise "expected 90 squares" unless result.board.flatten.size == 90
end

run_test("position with hands") do
  result = Parser.parse("8/8/8/8/8/8/8/8 3B2PNR/2qp C/c")
  raise "wrong first hand size" unless result.hands[:first].size == 7
  raise "wrong second hand size" unless result.hands[:second].size == 3
end

# ============================================================================
# PARSE - CARDINALITY VALIDATION
# ============================================================================

puts
puts "parse - cardinality validation:"

run_test("accepts pieces equal to squares") do
  # 1 square, 1 piece on board, 0 in hands
  result = Parser.parse("K / C/c")
  raise "should succeed" unless result.is_a?(Qi::Position)
end

run_test("accepts pieces less than squares") do
  # 8 squares, 0 pieces
  result = Parser.parse("8 / C/c")
  raise "should succeed" unless result.is_a?(Qi::Position)
end

run_test("raises when pieces exceed squares") do
  # 1 square on board (K), 2 pieces in first hand
  Parser.parse("K 2P/ C/c")
  raise "should have raised"
rescue Sashite::Feen::CardinalityError
  # Expected
end

run_test("counts hand pieces in cardinality check") do
  # 2 squares, 1 on board + 2 in hands = 3 > 2
  Parser.parse("K1 2P/ C/c")
  raise "should have raised"
rescue Sashite::Feen::CardinalityError
  # Expected
end

# ============================================================================
# PARSE - INVALID INPUTS
# ============================================================================

puts
puts "parse - invalid inputs:"

run_test("raises for empty string") do
  Parser.parse("")
  raise "should have raised"
rescue Sashite::Feen::ParseError
  # Expected
end

run_test("raises for single field") do
  Parser.parse("K")
  raise "should have raised"
rescue Sashite::Feen::ParseError
  # Expected
end

run_test("raises for two fields") do
  Parser.parse("K /")
  raise "should have raised"
rescue Sashite::Feen::ParseError
  # Expected
end

run_test("raises for four fields") do
  Parser.parse("K / C/c extra")
  raise "should have raised"
rescue Sashite::Feen::ParseError
  # Expected
end

run_test("raises for string too long") do
  long_string = "K" * 4097 + " / C/c"
  Parser.parse(long_string)
  raise "should have raised"
rescue Sashite::Feen::ParseError
  # Expected
end

run_test("raises for invalid piece placement") do
  Parser.parse("/K / C/c")
  raise "should have raised"
rescue Sashite::Feen::PiecePlacementError
  # Expected
end

run_test("raises for invalid hands") do
  Parser.parse("K PP/ C/c")
  raise "should have raised"
rescue Sashite::Feen::HandsError
  # Expected
end

run_test("raises for invalid style-turn") do
  Parser.parse("K / C/C")
  raise "should have raised"
rescue Sashite::Feen::StyleTurnError
  # Expected
end

# ============================================================================
# VALID?
# ============================================================================

puts
puts "valid?:"

run_test("returns true for valid FEEN") do
  raise "expected true" unless Parser.valid?("K / C/c")
end

run_test("returns true for complex valid FEEN") do
  raise "expected true" unless Parser.valid?("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c")
end

run_test("returns false for invalid FEEN") do
  raise "expected false" if Parser.valid?("invalid")
end

run_test("returns false for nil") do
  raise "expected false" if Parser.valid?(nil)
end

run_test("returns false for Integer") do
  raise "expected false" if Parser.valid?(123)
end

run_test("returns false for Symbol") do
  raise "expected false" if Parser.valid?(:symbol)
end

run_test("returns false for empty string") do
  raise "expected false" if Parser.valid?("")
end

run_test("never raises") do
  inputs = [nil, 123, :symbol, [], {}, "", "invalid", "K", "K / C/C", "x" * 10_000]
  inputs.each do |input|
    begin
      result = Parser.valid?(input)
      raise "should return boolean for #{input.inspect}" unless result == true || result == false
    rescue StandardError => e
      raise "valid? should not raise for #{input.inspect}: #{e.message}"
    end
  end
end

# ============================================================================
# MODULE PROPERTIES
# ============================================================================

puts
puts "module properties:"

run_test("module is frozen") do
  raise "expected frozen" unless Parser.frozen?
end

puts
puts "All Parser tests passed!"
puts
