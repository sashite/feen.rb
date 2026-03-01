#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../helper"
require_relative "../../../lib/sashite/feen/parser"

puts
puts "=== Parser Tests ==="
puts

Parser = Sashite::Feen::Parser

# ============================================================================
# PARSE - RETURNS Qi
# ============================================================================

puts "parse - returns Qi:"

Test("returns a Qi instance") do
  result = Parser.parse("K / C/c")
  raise "wrong type" unless result.is_a?(Qi)
end

Test("position has board accessor") do
  result = Parser.parse("K / C/c")
  raise "missing board" unless result.respond_to?(:board)
end

Test("position has first_player_hand accessor") do
  result = Parser.parse("K / C/c")
  raise "missing first_player_hand" unless result.respond_to?(:first_player_hand)
end

Test("position has second_player_hand accessor") do
  result = Parser.parse("K / C/c")
  raise "missing second_player_hand" unless result.respond_to?(:second_player_hand)
end

Test("position has first_player_style accessor") do
  result = Parser.parse("K / C/c")
  raise "missing first_player_style" unless result.respond_to?(:first_player_style)
end

Test("position has second_player_style accessor") do
  result = Parser.parse("K / C/c")
  raise "missing second_player_style" unless result.respond_to?(:second_player_style)
end

Test("position has turn accessor") do
  result = Parser.parse("K / C/c")
  raise "missing turn" unless result.respond_to?(:turn)
end

Test("position has shape accessor") do
  result = Parser.parse("K / C/c")
  raise "missing shape" unless result.respond_to?(:shape)
end

# ============================================================================
# PARSE - BOARD (FLAT ARRAY)
# ============================================================================

puts
puts "parse - board:"

Test("1D board is flat array with correct content") do
  result = Parser.parse("K2Q / C/c")
  raise "expected flat array" if result.board[0].is_a?(Array)
  raise "wrong content" unless result.board == ["K", nil, nil, "Q"]
  raise "wrong shape" unless result.shape == [4]
end

Test("2D board is flat array with shape") do
  result = Parser.parse("8/8/8/8/8/8/8/8 / C/c")
  raise "expected 64 squares" unless result.board.size == 64
  raise "expected flat" if result.board[0].is_a?(Array)
  raise "wrong shape" unless result.shape == [8, 8]
end

Test("3D board is flat array with shape") do
  result = Parser.parse("2/2//2/2 / C/c")
  raise "expected 8 squares" unless result.board.size == 8
  raise "expected flat" if result.board[0].is_a?(Array)
  raise "wrong shape" unless result.shape == [2, 2, 2]
end

Test("pieces are EPIN strings") do
  result = Parser.parse("K^+p / C/c")
  raise "wrong first piece" unless result.board[0] == "K^"
  raise "wrong second piece" unless result.board[1] == "+p"
end

# ============================================================================
# PARSE - HANDS (COUNT MAPS)
# ============================================================================

puts
puts "parse - hands:"

Test("empty hands") do
  result = Parser.parse("K / C/c")
  raise "wrong first" unless result.first_player_hand == {}
  raise "wrong second" unless result.second_player_hand == {}
end

Test("first hand with pieces") do
  result = Parser.parse("8 2PN/ C/c")
  raise "wrong first hand" unless result.first_player_hand == { "P" => 2, "N" => 1 }
  raise "wrong second hand" unless result.second_player_hand == {}
end

Test("both hands with pieces") do
  result = Parser.parse("8 2PN/p C/c")
  raise "wrong first hand" unless result.first_player_hand == { "P" => 2, "N" => 1 }
  raise "wrong second hand" unless result.second_player_hand == { "p" => 1 }
end

Test("hands are Hash{String => Integer}") do
  result = Parser.parse("8 2PB/2qr C/c")
  raise "expected Hash" unless result.first_player_hand.is_a?(Hash)
  raise "expected String keys" unless result.first_player_hand.keys.all? { |k| k.is_a?(String) }
  raise "expected Integer values" unless result.first_player_hand.values.all? { |v| v.is_a?(Integer) }
  raise "expected Hash" unless result.second_player_hand.is_a?(Hash)
  raise "expected String keys" unless result.second_player_hand.keys.all? { |k| k.is_a?(String) }
  raise "expected Integer values" unless result.second_player_hand.values.all? { |v| v.is_a?(Integer) }
end

# ============================================================================
# PARSE - STYLES AND TURN
# ============================================================================

puts
puts "parse - styles and turn:"

Test("first player to move") do
  result = Parser.parse("K / C/c")
  raise "wrong turn" unless result.turn == :first
  raise "wrong first style" unless result.first_player_style == "C"
  raise "wrong second style" unless result.second_player_style == "c"
end

Test("second player to move") do
  result = Parser.parse("K / c/C")
  raise "wrong turn" unless result.turn == :second
  raise "wrong first style" unless result.first_player_style == "C"
  raise "wrong second style" unless result.second_player_style == "c"
end

Test("cross-style game") do
  result = Parser.parse("K / C/s")
  raise "wrong first style" unless result.first_player_style == "C"
  raise "wrong second style" unless result.second_player_style == "s"
  raise "wrong turn" unless result.turn == :first
end

# ============================================================================
# PARSE - REAL POSITIONS
# ============================================================================

puts
puts "parse - real positions:"

Test("Chess initial position") do
  result = Parser.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c")
  raise "expected 64 squares" unless result.board.size == 64
  raise "expected [8,8] shape" unless result.shape == [8, 8]
  raise "wrong piece count" unless result.board.compact.size == 32
end

Test("Shogi initial position") do
  result = Parser.parse("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s")
  raise "expected 81 squares" unless result.board.size == 81
  raise "expected [9,9] shape" unless result.shape == [9, 9]
end

Test("Xiangqi initial position") do
  result = Parser.parse("rheagaehr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RHEAGAEHR / X/x")
  raise "expected 90 squares" unless result.board.size == 90
  raise "expected [10,9] shape" unless result.shape == [10, 9]
end

Test("position with hands") do
  result = Parser.parse("8/8/8/8/8/8/8/8 3B2PNR/2qp C/c")
  first_total = result.first_player_hand.values.sum
  second_total = result.second_player_hand.values.sum
  raise "wrong first hand total" unless first_total == 7
  raise "wrong second hand total" unless second_total == 3
end

# ============================================================================
# PARSE - CARDINALITY VALIDATION
# ============================================================================

puts
puts "parse - cardinality validation:"

Test("accepts pieces equal to squares") do
  # 1 square, 1 piece on board, 0 in hands
  result = Parser.parse("K / C/c")
  raise "should succeed" unless result.is_a?(Qi)
end

Test("accepts pieces less than squares") do
  # 8 squares, 0 pieces
  result = Parser.parse("8 / C/c")
  raise "should succeed" unless result.is_a?(Qi)
end

Test("raises when pieces exceed squares") do
  # 1 square on board (K), 2 pieces in first hand
  Parser.parse("K 2P/ C/c")
  raise "should have raised"
rescue Sashite::Feen::CardinalityError
  # Expected
end

Test("counts hand pieces in cardinality check") do
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

Test("raises for empty string") do
  Parser.parse("")
  raise "should have raised"
rescue Sashite::Feen::ParseError
  # Expected
end

Test("raises for single field") do
  Parser.parse("K")
  raise "should have raised"
rescue Sashite::Feen::ParseError
  # Expected
end

Test("raises for two fields") do
  Parser.parse("K /")
  raise "should have raised"
rescue Sashite::Feen::ParseError
  # Expected
end

Test("raises for four fields") do
  Parser.parse("K / C/c extra")
  raise "should have raised"
rescue Sashite::Feen::ParseError
  # Expected
end

Test("raises for string too long") do
  long_string = "K" * 4097 + " / C/c"
  Parser.parse(long_string)
  raise "should have raised"
rescue Sashite::Feen::ParseError
  # Expected
end

Test("raises for invalid piece placement") do
  Parser.parse("/K / C/c")
  raise "should have raised"
rescue Sashite::Feen::PiecePlacementError
  # Expected
end

Test("raises for invalid hands") do
  Parser.parse("K PP/ C/c")
  raise "should have raised"
rescue Sashite::Feen::HandsError
  # Expected
end

Test("raises for invalid style-turn") do
  Parser.parse("K / C/C")
  raise "should have raised"
rescue Sashite::Feen::StyleTurnError
  # Expected
end

# ============================================================================
# VALID? (EXCEPTION-FREE PATH)
# ============================================================================

puts
puts "valid?:"

Test("returns false for invalid hands") do
  raise "expected false" if Parser.valid?("K PP/ C/c")
end

Test("returns true for valid FEEN") do
  raise "expected true" unless Parser.valid?("K / C/c")
end

Test("returns true for complex valid FEEN") do
  raise "expected true" unless Parser.valid?("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c")
end

Test("returns false for invalid FEEN") do
  raise "expected false" if Parser.valid?("invalid")
end

Test("returns false for nil") do
  raise "expected false" if Parser.valid?(nil)
end

Test("returns false for Integer") do
  raise "expected false" if Parser.valid?(123)
end

Test("returns false for Symbol") do
  raise "expected false" if Parser.valid?(:symbol)
end

Test("returns false for empty string") do
  raise "expected false" if Parser.valid?("")
end

Test("returns false for dimensional coherence violation") do
  raise "expected false" if Parser.valid?("rkr//PPPP / G/g")
end

Test("returns false for cardinality violation") do
  raise "expected false" if Parser.valid?("K 2P/ C/c")
end

Test("never raises") do
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

Test("module is frozen") do
  raise "expected frozen" unless Parser.frozen?
end

puts
puts "All Parser tests passed!"
puts
