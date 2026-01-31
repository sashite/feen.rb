#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../helper"
require_relative "../../lib/sashite/feen"

puts
puts "=== Feen Tests ==="
puts

# ============================================================================
# PARSE - VALID INPUTS
# ============================================================================

puts "parse - valid inputs:"

run_test("parses minimal FEEN string") do
  position = Sashite::Feen.parse("K / C/c")
  raise "wrong type" unless position.is_a?(Sashite::Feen::Position)
end

run_test("parses Chess initial position") do
  position = Sashite::Feen.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c")
  raise "wrong squares" unless position.squares_count == 64
  raise "wrong pieces" unless position.pieces_count == 32
end

run_test("parses Shogi initial position") do
  position = Sashite::Feen.parse("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s")
  raise "wrong squares" unless position.squares_count == 81
  raise "wrong pieces" unless position.pieces_count == 40
end

run_test("parses Xiangqi initial position") do
  position = Sashite::Feen.parse("rheagaehr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RHEAGAEHR / X/x")
  raise "wrong squares" unless position.squares_count == 90
end

run_test("parses position with pieces in hands") do
  position = Sashite::Feen.parse("8/8/8/8/8/8/8/8 3B2PNR/2qp C/c")
  raise "wrong first hand" unless position.hands.first.pieces_count == 7
  raise "wrong second hand" unless position.hands.second.pieces_count == 3
end

run_test("parses 3D position") do
  position = Sashite::Feen.parse("4/4//4/4 / C/c")
  raise "wrong dimensions" unless position.piece_placement.dimensions == 3
end

run_test("parses cross-style game") do
  position = Sashite::Feen.parse("K / C/s")
  raise "wrong active" unless position.style_turn.active_style.abbr == :C
  raise "wrong inactive" unless position.style_turn.inactive_style.abbr == :S
end

run_test("parses position with second to move") do
  position = Sashite::Feen.parse("K / c/C")
  raise "should be second to move" unless position.style_turn.second_to_move?
end

run_test("parses position with EPIN modifiers") do
  position = Sashite::Feen.parse("+K^'-q^' / C/c")
  raise "wrong pieces" unless position.pieces_count == 2
end

run_test("returns frozen Position") do
  position = Sashite::Feen.parse("K / C/c")
  raise "should be frozen" unless position.frozen?
end

# ============================================================================
# PARSE - INVALID INPUTS
# ============================================================================

puts
puts "parse - invalid inputs:"

run_test("raises for empty string") do
  Sashite::Feen.parse("")
  raise "should have raised"
rescue ArgumentError
  # Expected
end

run_test("raises for wrong field count") do
  Sashite::Feen.parse("K")
  raise "should have raised"
rescue ArgumentError => e
  raise "wrong message" unless e.message == "invalid field count"
end

run_test("raises for invalid piece placement") do
  Sashite::Feen.parse("/K / C/c")
  raise "should have raised"
rescue ArgumentError => e
  raise "wrong message" unless e.message == "piece placement starts with separator"
end

run_test("raises for invalid hands") do
  Sashite::Feen.parse("K PP/ C/c")
  raise "should have raised"
rescue ArgumentError => e
  raise "wrong message" unless e.message == "hand items not aggregated"
end

run_test("raises for invalid style-turn") do
  Sashite::Feen.parse("K / C/C")
  raise "should have raised"
rescue ArgumentError => e
  raise "wrong message" unless e.message == "style tokens must have opposite case"
end

run_test("raises for too many pieces") do
  Sashite::Feen.parse("K 2P/ C/c")
  raise "should have raised"
rescue ArgumentError => e
  raise "wrong message" unless e.message == "too many pieces for board size"
end

run_test("raises for string too long") do
  long_string = "K" * 4097 + " / C/c"
  Sashite::Feen.parse(long_string)
  raise "should have raised"
rescue ArgumentError => e
  raise "wrong message" unless e.message == "input exceeds 4096 characters"
end

run_test("error is Sashite::Feen::Errors::Argument") do
  Sashite::Feen.parse("invalid")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument
  # Expected
end

run_test("error is rescuable as ArgumentError") do
  Sashite::Feen.parse("invalid")
  raise "should have raised"
rescue ArgumentError
  # Expected
end

# ============================================================================
# VALID? - TRUE CASES
# ============================================================================

puts
puts "valid? - true cases:"

run_test("returns true for minimal FEEN") do
  raise "should be valid" unless Sashite::Feen.valid?("K / C/c")
end

run_test("returns true for Chess initial position") do
  raise "should be valid" unless Sashite::Feen.valid?("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c")
end

run_test("returns true for Shogi initial position") do
  raise "should be valid" unless Sashite::Feen.valid?("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s")
end

run_test("returns true for Xiangqi initial position") do
  raise "should be valid" unless Sashite::Feen.valid?("rheagaehr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RHEAGAEHR / X/x")
end

run_test("returns true for position with hands") do
  raise "should be valid" unless Sashite::Feen.valid?("8/8/8/8/8/8/8/8 3B2PNR/2qp C/c")
end

run_test("returns true for 3D position") do
  raise "should be valid" unless Sashite::Feen.valid?("4/4//4/4 / C/c")
end

run_test("returns true for cross-style game") do
  raise "should be valid" unless Sashite::Feen.valid?("K / C/s")
end

run_test("returns true for second to move") do
  raise "should be valid" unless Sashite::Feen.valid?("K / c/C")
end

run_test("returns true for empty board") do
  raise "should be valid" unless Sashite::Feen.valid?("8 / C/c")
end

run_test("returns true for 1D board") do
  raise "should be valid" unless Sashite::Feen.valid?("K2Q3R / C/c")
end

run_test("returns true for position with EPIN modifiers") do
  raise "should be valid" unless Sashite::Feen.valid?("+K^'-q^' / C/c")
end

# ============================================================================
# VALID? - FALSE CASES
# ============================================================================

puts
puts "valid? - false cases:"

run_test("returns false for nil") do
  raise "should be invalid" if Sashite::Feen.valid?(nil)
end

run_test("returns false for Integer") do
  raise "should be invalid" if Sashite::Feen.valid?(123)
end

run_test("returns false for Symbol") do
  raise "should be invalid" if Sashite::Feen.valid?(:symbol)
end

run_test("returns false for Array") do
  raise "should be invalid" if Sashite::Feen.valid?([])
end

run_test("returns false for Hash") do
  raise "should be invalid" if Sashite::Feen.valid?({})
end

run_test("returns false for empty string") do
  raise "should be invalid" if Sashite::Feen.valid?("")
end

run_test("returns false for one field") do
  raise "should be invalid" if Sashite::Feen.valid?("K")
end

run_test("returns false for two fields") do
  raise "should be invalid" if Sashite::Feen.valid?("K /")
end

run_test("returns false for four fields") do
  raise "should be invalid" if Sashite::Feen.valid?("K / C/c extra")
end

run_test("returns false for invalid piece placement") do
  raise "should be invalid" if Sashite::Feen.valid?("/K / C/c")
end

run_test("returns false for invalid character in piece placement") do
  raise "should be invalid" if Sashite::Feen.valid?("K@Q / C/c")
end

run_test("returns false for invalid hands") do
  raise "should be invalid" if Sashite::Feen.valid?("K PP/ C/c")
end

run_test("returns false for invalid style-turn") do
  raise "should be invalid" if Sashite::Feen.valid?("K / C/C")
end

run_test("returns false for too many pieces") do
  raise "should be invalid" if Sashite::Feen.valid?("K 2P/ C/c")
end

run_test("returns false for string too long") do
  raise "should be invalid" if Sashite::Feen.valid?("K" * 4097 + " / C/c")
end

run_test("returns false for dimension size exceeded") do
  raise "should be invalid" if Sashite::Feen.valid?("256 / C/c")
end

run_test("returns false for exceeding dimensions") do
  raise "should be invalid" if Sashite::Feen.valid?("1/1//1/1///1/1//1/1////1 / C/c")
end

run_test("returns false for invalid empty count") do
  raise "should be invalid" if Sashite::Feen.valid?("0 / C/c")
end

run_test("returns false for leading zero") do
  raise "should be invalid" if Sashite::Feen.valid?("08 / C/c")
end

# ============================================================================
# INTEGRATION
# ============================================================================

puts
puts "Integration:"

run_test("parse and to_s round-trip") do
  input = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c"
  position = Sashite::Feen.parse(input)
  raise "round-trip failed" unless position.to_s == input
end

run_test("position components are accessible") do
  position = Sashite::Feen.parse("K3 2P/p C/c")

  # Piece placement
  raise "wrong type" unless position.piece_placement.is_a?(Sashite::Feen::Position::PiecePlacement)
  raise "wrong squares" unless position.piece_placement.squares_count == 4

  # Hands
  raise "wrong type" unless position.hands.is_a?(Sashite::Feen::Position::Hands)
  raise "wrong first" unless position.hands.first.pieces_count == 2
  raise "wrong second" unless position.hands.second.pieces_count == 1

  # Style turn
  raise "wrong type" unless position.style_turn.is_a?(Sashite::Feen::Position::StyleTurn)
  raise "wrong turn" unless position.style_turn.first_to_move?
end

run_test("position can be iterated") do
  position = Sashite::Feen.parse("K2Q / C/c")
  tokens = position.piece_placement.map { |t| t.is_a?(Integer) ? t : t.to_s }
  raise "wrong tokens" unless tokens == ["K", 2, "Q"]
end

run_test("position can be used as hash key") do
  p1 = Sashite::Feen.parse("K / C/c")
  p2 = Sashite::Feen.parse("K / C/c")
  hash = { p1 => "value" }
  raise "should find by equal key" unless hash[p2] == "value"
end

run_test("valid? does not raise") do
  # These would raise in parse, but valid? should return false
  [nil, 123, :symbol, [], {}, "", "invalid", "K", "K / C/C"].each do |input|
    begin
      result = Sashite::Feen.valid?(input)
      raise "should return boolean" unless result == true || result == false
    rescue StandardError
      raise "valid? should not raise for #{input.inspect}"
    end
  end
end

run_test("parse and valid? are consistent") do
  valid_inputs = [
    "K / C/c",
    "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c",
    "8/8/8/8/8/8/8/8 3B2PNR/2qp C/c",
    "4/4//4/4 / C/c"
  ]

  valid_inputs.each do |input|
    raise "should be valid: #{input}" unless Sashite::Feen.valid?(input)
    begin
      Sashite::Feen.parse(input)
    rescue StandardError
      raise "should parse: #{input}"
    end
  end
end

# ============================================================================
# MULTIPLE GAME TYPES
# ============================================================================

puts
puts "Multiple game types:"

run_test("supports Chess") do
  position = Sashite::Feen.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c")
  raise "wrong style" unless position.style_turn.active_style.abbr == :C
end

run_test("supports Shogi") do
  position = Sashite::Feen.parse("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s")
  raise "wrong style" unless position.style_turn.active_style.abbr == :S
end

run_test("supports Xiangqi") do
  position = Sashite::Feen.parse("rheagaehr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RHEAGAEHR / X/x")
  raise "wrong style" unless position.style_turn.active_style.abbr == :X
end

run_test("supports Go") do
  position = Sashite::Feen.parse("9/9/9/9/9/9/9/9/9 / G/g")
  raise "wrong style" unless position.style_turn.active_style.abbr == :G
end

run_test("supports cross-style games") do
  position = Sashite::Feen.parse("K / C/s")
  raise "wrong active" unless position.style_turn.active_style.abbr == :C
  raise "wrong inactive" unless position.style_turn.inactive_style.abbr == :S
end

# ============================================================================
# MODULE STRUCTURE
# ============================================================================

puts
puts "Module structure:"

run_test("Feen is a Module") do
  raise "wrong type" unless Sashite::Feen.is_a?(Module)
end

run_test("Feen is nested under Sashite") do
  raise "wrong nesting" unless Sashite.const_defined?(:Feen)
end

run_test("Feen responds to parse") do
  raise "should respond to parse" unless Sashite::Feen.respond_to?(:parse)
end

run_test("Feen responds to valid?") do
  raise "should respond to valid?" unless Sashite::Feen.respond_to?(:valid?)
end

run_test("Constants is accessible") do
  raise "missing Constants" unless defined?(Sashite::Feen::Constants)
end

run_test("Errors is accessible") do
  raise "missing Errors" unless defined?(Sashite::Feen::Errors)
end

run_test("Parser is accessible") do
  raise "missing Parser" unless defined?(Sashite::Feen::Parser)
end

run_test("Position is accessible") do
  raise "missing Position" unless defined?(Sashite::Feen::Position)
end

# ============================================================================
# EXTERNAL DEPENDENCIES
# ============================================================================

puts
puts "External dependencies:"

run_test("Epin is loaded") do
  raise "missing Epin" unless defined?(Sashite::Epin)
end

run_test("Sin is loaded") do
  raise "missing Sin" unless defined?(Sashite::Sin)
end

run_test("Epin::Identifier is accessible") do
  raise "missing Epin::Identifier" unless defined?(Sashite::Epin::Identifier)
end

run_test("Sin::Identifier is accessible") do
  raise "missing Sin::Identifier" unless defined?(Sashite::Sin::Identifier)
end

puts
puts "All Feen tests passed!"
puts
