#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../helper"
require_relative "../../lib/sashite/feen"

puts
puts "=== Feen Integration Tests ==="
puts

Feen = Sashite::Feen

# ============================================================================
# PARSE - VALID INPUTS
# ============================================================================

puts "parse - valid inputs:"

Test("parses minimal FEEN string") do
  position = Feen.parse("K / C/c")
  raise "wrong type" unless position.is_a?(Qi)
end

Test("parses Chess initial position") do
  position = Feen.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c")
  raise "wrong squares" unless position.board.size == 64
  raise "wrong pieces" unless position.board.compact.size == 32
  raise "wrong shape" unless position.shape == [8, 8]
end

Test("parses Shogi initial position") do
  position = Feen.parse("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s")
  raise "wrong squares" unless position.board.size == 81
  raise "wrong pieces" unless position.board.compact.size == 40
  raise "wrong shape" unless position.shape == [9, 9]
end

Test("parses Xiangqi initial position") do
  position = Feen.parse("rheagaehr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RHEAGAEHR / X/x")
  raise "wrong squares" unless position.board.size == 90
  raise "wrong shape" unless position.shape == [10, 9]
end

Test("parses position with pieces in hands") do
  position = Feen.parse("8/8/8/8/8/8/8/8 3B2PNR/2qp C/c")
  raise "wrong first hand" unless position.first_player_hand.values.sum == 7
  raise "wrong second hand" unless position.second_player_hand.values.sum == 3
end

Test("parses 3D position") do
  position = Feen.parse("4/4//4/4 / C/c")
  raise "expected flat board" if position.board[0].is_a?(Array)
  raise "wrong shape" unless position.shape == [2, 2, 4]
end

Test("parses cross-style game") do
  position = Feen.parse("K / C/s")
  raise "wrong first style" unless position.first_player_style == "C"
  raise "wrong second style" unless position.second_player_style == "s"
  raise "wrong turn" unless position.turn == :first
end

Test("parses position with second to move") do
  position = Feen.parse("K / c/C")
  raise "should be second to move" unless position.turn == :second
end

Test("parses position with EPIN modifiers") do
  position = Feen.parse("+K^'-q^' / C/c")
  pieces = position.board.compact
  raise "wrong pieces" unless pieces.size == 2
  raise "wrong first piece" unless pieces[0] == "+K^'"
  raise "wrong second piece" unless pieces[1] == "-q^'"
end

Test("parses 1D board") do
  position = Feen.parse("K2Q3R / C/c")
  raise "expected flat array" if position.board[0].is_a?(Array)
  raise "wrong size" unless position.board.size == 8
  raise "wrong shape" unless position.shape == [8]
end

# ============================================================================
# PARSE - INVALID INPUTS
# ============================================================================

puts
puts "parse - invalid inputs:"

Test("raises for empty string") do
  Feen.parse("")
  raise "should have raised"
rescue Feen::ParseError
  # Expected
end

Test("raises for wrong field count") do
  Feen.parse("K")
  raise "should have raised"
rescue Feen::ParseError => e
  raise "wrong message" unless e.message.include?("field")
end

Test("raises for invalid piece placement") do
  Feen.parse("/K / C/c")
  raise "should have raised"
rescue Feen::PiecePlacementError
  # Expected
end

Test("raises for invalid hands") do
  Feen.parse("K PP/ C/c")
  raise "should have raised"
rescue Feen::HandsError
  # Expected
end

Test("raises for invalid style-turn") do
  Feen.parse("K / C/C")
  raise "should have raised"
rescue Feen::StyleTurnError
  # Expected
end

Test("raises for too many pieces") do
  Feen.parse("K 2P/ C/c")
  raise "should have raised"
rescue Feen::CardinalityError
  # Expected
end

Test("raises for string too long") do
  long_string = "K" * 4097 + " / C/c"
  Feen.parse(long_string)
  raise "should have raised"
rescue Feen::ParseError
  # Expected
end

Test("all errors inherit from Feen::Error") do
  begin
    Feen.parse("invalid")
  rescue Feen::Error
    # Expected - catches all FEEN errors
  end
end

Test("all errors inherit from ArgumentError") do
  begin
    Feen.parse("invalid")
  rescue ArgumentError
    # Expected - standard Ruby error handling
  end
end

# ============================================================================
# VALID? - TRUE CASES
# ============================================================================

puts
puts "valid? - true cases:"

Test("returns true for minimal FEEN") do
  raise "should be valid" unless Feen.valid?("K / C/c")
end

Test("returns true for Chess initial position") do
  raise "should be valid" unless Feen.valid?("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c")
end

Test("returns true for Shogi initial position") do
  raise "should be valid" unless Feen.valid?("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s")
end

Test("returns true for Xiangqi initial position") do
  raise "should be valid" unless Feen.valid?("rheagaehr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RHEAGAEHR / X/x")
end

Test("returns true for position with hands") do
  raise "should be valid" unless Feen.valid?("8/8/8/8/8/8/8/8 3B2PNR/2qp C/c")
end

Test("returns true for 3D position") do
  raise "should be valid" unless Feen.valid?("4/4//4/4 / C/c")
end

Test("returns true for cross-style game") do
  raise "should be valid" unless Feen.valid?("K / C/s")
end

Test("returns true for second to move") do
  raise "should be valid" unless Feen.valid?("K / c/C")
end

Test("returns true for empty board") do
  raise "should be valid" unless Feen.valid?("8 / C/c")
end

Test("returns true for 1D board") do
  raise "should be valid" unless Feen.valid?("K2Q3R / C/c")
end

Test("returns true for position with EPIN modifiers") do
  raise "should be valid" unless Feen.valid?("+K^'-q^' / C/c")
end

# ============================================================================
# VALID? - FALSE CASES
# ============================================================================

puts
puts "valid? - false cases:"

Test("returns false for nil") do
  raise "should be invalid" if Feen.valid?(nil)
end

Test("returns false for Integer") do
  raise "should be invalid" if Feen.valid?(123)
end

Test("returns false for Symbol") do
  raise "should be invalid" if Feen.valid?(:symbol)
end

Test("returns false for Array") do
  raise "should be invalid" if Feen.valid?([])
end

Test("returns false for Hash") do
  raise "should be invalid" if Feen.valid?({})
end

Test("returns false for empty string") do
  raise "should be invalid" if Feen.valid?("")
end

Test("returns false for one field") do
  raise "should be invalid" if Feen.valid?("K")
end

Test("returns false for two fields") do
  raise "should be invalid" if Feen.valid?("K /")
end

Test("returns false for four fields") do
  raise "should be invalid" if Feen.valid?("K / C/c extra")
end

Test("returns false for invalid piece placement") do
  raise "should be invalid" if Feen.valid?("/K / C/c")
end

Test("returns false for invalid character in piece placement") do
  raise "should be invalid" if Feen.valid?("K@Q / C/c")
end

Test("returns false for invalid hands") do
  raise "should be invalid" if Feen.valid?("K PP/ C/c")
end

Test("returns false for invalid style-turn") do
  raise "should be invalid" if Feen.valid?("K / C/C")
end

Test("returns false for too many pieces") do
  raise "should be invalid" if Feen.valid?("K 2P/ C/c")
end

Test("returns false for string too long") do
  raise "should be invalid" if Feen.valid?("K" * 4097 + " / C/c")
end

Test("returns false for dimension size exceeded") do
  raise "should be invalid" if Feen.valid?("256 / C/c")
end

Test("returns false for exceeding dimensions") do
  raise "should be invalid" if Feen.valid?("1/1//1/1///1/1//1/1////1 / C/c")
end

Test("returns false for invalid empty count") do
  raise "should be invalid" if Feen.valid?("0 / C/c")
end

Test("returns false for leading zeros in empty count") do
  raise "should be invalid" if Feen.valid?("01 / C/c")
end

# ============================================================================
# VALID? SAFETY
# ============================================================================

puts
puts "valid? safety:"

Test("valid? never raises") do
  inputs = [nil, 123, :symbol, [], {}, "", "invalid", "K", "K / C/C", "x" * 10_000]
  inputs.each do |input|
    begin
      result = Feen.valid?(input)
      raise "should return boolean for #{input.inspect}" unless result == true || result == false
    rescue StandardError => e
      raise "valid? should not raise for #{input.inspect}: #{e.message}"
    end
  end
end

# ============================================================================
# DUMP
# ============================================================================

puts
puts "dump:"

Test("dumps a Qi position to String") do
  position = Feen.parse("K / C/c")
  result = Feen.dump(position)
  raise "expected String" unless result.is_a?(String)
end

Test("dumps minimal position") do
  position = Qi.new([1], first_player_style: "C", second_player_style: "c")
    .board_diff(0 => "K")
  result = Feen.dump(position)
  raise "expected 'K / C/c'" unless result == "K / C/c"
end

Test("dumps position with hands") do
  position = Qi.new([8], first_player_style: "S", second_player_style: "s")
    .first_player_hand_diff("P": 2)
    .second_player_hand_diff("p": 1)
  result = Feen.dump(position)
  raise "expected '8 2P/p S/s'" unless result == "8 2P/p S/s"
end

Test("dumps returns String") do
  position = Qi.new([1], first_player_style: "C", second_player_style: "c")
    .board_diff(0 => "K")
  result = Feen.dump(position)
  raise "expected String" unless result.is_a?(String)
end

# ============================================================================
# ROUND-TRIP (parse -> dump)
# ============================================================================

puts
puts "round-trip (parse -> dump):"

round_trip_cases = [
  "K / C/c",
  "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c",
  "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s",
  "rheagaehr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RHEAGAEHR / X/x",
  "8/8/8/8/8/8/8/8 3B2PNR/2qp C/c",
  "4/4//4/4 / C/c",
  "K / C/s",
  "K / c/C",
  "8 / C/c",
  "K2Q3R / C/c",
  "+K^'-q^' / C/c",
  "9/9/9/9/9/9/9/9/9 / G/g"
]

round_trip_cases.each do |feen|
  Test("round-trip: #{feen}") do
    position = Feen.parse(feen)
    result = Feen.dump(position)
    raise "round-trip failed: expected '#{feen}', got '#{result}'" unless result == feen
  end
end

# ============================================================================
# ROUND-TRIP (build -> dump -> parse)
# ============================================================================

puts
puts "round-trip (build -> dump -> parse):"

Test("1D position round-trips") do
  original = Qi.new([8], first_player_style: "C", second_player_style: "c")
    .board_diff(0 => "K", 7 => "k")
  feen = Feen.dump(original)
  restored = Feen.parse(feen)
  raise "board mismatch" unless restored.board == original.board
  raise "first hand mismatch" unless restored.first_player_hand == original.first_player_hand
  raise "second hand mismatch" unless restored.second_player_hand == original.second_player_hand
  raise "first style mismatch" unless restored.first_player_style == original.first_player_style
  raise "second style mismatch" unless restored.second_player_style == original.second_player_style
  raise "turn mismatch" unless restored.turn == original.turn
end

Test("2D position round-trips") do
  original = Qi.new([2, 8], first_player_style: "C", second_player_style: "c")
    .board_diff(0 => "K", 7 => "k")
  feen = Feen.dump(original)
  restored = Feen.parse(feen)
  raise "board mismatch" unless restored.board == original.board
  raise "shape mismatch" unless restored.shape == original.shape
  raise "turn mismatch" unless restored.turn == original.turn
end

Test("position with hands round-trips") do
  original = Qi.new([8, 8], first_player_style: "C", second_player_style: "c")
    .first_player_hand_diff("B": 3, "P": 2, "N": 1, "R": 1)
    .second_player_hand_diff("q": 2, "p": 1)
  feen = Feen.dump(original)
  restored = Feen.parse(feen)
  raise "first hand mismatch" unless restored.first_player_hand == original.first_player_hand
  raise "second hand mismatch" unless restored.second_player_hand == original.second_player_hand
end

Test("3D position round-trips") do
  original = Qi.new([2, 2, 2], first_player_style: "C", second_player_style: "c")
    .board_diff(0 => "a", 1 => "b", 2 => "c", 3 => "d",
                4 => "A", 5 => "B", 6 => "C", 7 => "D")
  feen = Feen.dump(original)
  restored = Feen.parse(feen)
  raise "board mismatch" unless restored.board == original.board
  raise "shape mismatch" unless restored.shape == original.shape
end

# ============================================================================
# ERROR HIERARCHY
# ============================================================================

puts
puts "error hierarchy:"

Test("Error inherits from ArgumentError") do
  raise "wrong parent" unless Feen::Error < ArgumentError
end

Test("ParseError inherits from Error") do
  raise "wrong parent" unless Feen::ParseError < Feen::Error
end

Test("PiecePlacementError inherits from ParseError") do
  raise "wrong parent" unless Feen::PiecePlacementError < Feen::ParseError
end

Test("HandsError inherits from ParseError") do
  raise "wrong parent" unless Feen::HandsError < Feen::ParseError
end

Test("StyleTurnError inherits from ParseError") do
  raise "wrong parent" unless Feen::StyleTurnError < Feen::ParseError
end

Test("CardinalityError inherits from ParseError") do
  raise "wrong parent" unless Feen::CardinalityError < Feen::ParseError
end

# ============================================================================
# MODULE STRUCTURE
# ============================================================================

puts
puts "module structure:"

Test("Feen is a Module") do
  raise "wrong type" unless Feen.is_a?(Module)
end

Test("Feen is nested under Sashite") do
  raise "wrong nesting" unless Sashite.const_defined?(:Feen)
end

Test("Feen responds to parse") do
  raise "should respond to parse" unless Feen.respond_to?(:parse)
end

Test("Feen responds to valid?") do
  raise "should respond to valid?" unless Feen.respond_to?(:valid?)
end

Test("Feen responds to dump") do
  raise "should respond to dump" unless Feen.respond_to?(:dump)
end

Test("Parser is accessible") do
  raise "missing Parser" unless defined?(Feen::Parser)
end

Test("Dumper is accessible") do
  raise "missing Dumper" unless defined?(Feen::Dumper)
end

# ============================================================================
# EXTERNAL DEPENDENCIES
# ============================================================================

puts
puts "external dependencies:"

Test("Qi is loaded") do
  raise "missing Qi" unless defined?(Qi)
end

Test("Epin is loaded") do
  raise "missing Epin" unless defined?(Sashite::Epin)
end

Test("Sin is loaded") do
  raise "missing Sin" unless defined?(Sashite::Sin)
end

# ============================================================================
# MULTIPLE GAME TYPES
# ============================================================================

puts
puts "multiple game types:"

Test("supports Chess") do
  position = Feen.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c")
  raise "wrong style" unless position.first_player_style == "C"
end

Test("supports Shogi") do
  position = Feen.parse("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s")
  raise "wrong style" unless position.first_player_style == "S"
end

Test("supports Xiangqi") do
  position = Feen.parse("rheagaehr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RHEAGAEHR / X/x")
  raise "wrong style" unless position.first_player_style == "X"
end

Test("supports Go") do
  position = Feen.parse("9/9/9/9/9/9/9/9/9 / G/g")
  raise "wrong style" unless position.first_player_style == "G"
end

Test("supports cross-style games") do
  position = Feen.parse("K / C/s")
  raise "wrong first" unless position.first_player_style == "C"
  raise "wrong second" unless position.second_player_style == "s"
end

puts
puts "All Feen integration tests passed!"
puts
