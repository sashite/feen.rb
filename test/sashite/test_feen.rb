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

run_test("parses minimal FEEN string") do
  position = Feen.parse("K / C/c")
  raise "wrong type" unless position.is_a?(Qi::Position)
end

run_test("parses Chess initial position") do
  position = Feen.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c")
  flat = position.board.flatten
  raise "wrong squares" unless flat.size == 64
  raise "wrong pieces" unless flat.compact.size == 32
end

run_test("parses Shogi initial position") do
  position = Feen.parse("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s")
  flat = position.board.flatten
  raise "wrong squares" unless flat.size == 81
  raise "wrong pieces" unless flat.compact.size == 40
end

run_test("parses Xiangqi initial position") do
  position = Feen.parse("rheagaehr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RHEAGAEHR / X/x")
  flat = position.board.flatten
  raise "wrong squares" unless flat.size == 90
end

run_test("parses position with pieces in hands") do
  position = Feen.parse("8/8/8/8/8/8/8/8 3B2PNR/2qp C/c")
  raise "wrong first hand" unless position.hands[:first].size == 7
  raise "wrong second hand" unless position.hands[:second].size == 3
end

run_test("parses 3D position") do
  position = Feen.parse("4/4//4/4 / C/c")
  raise "expected 3D" unless position.board[0][0].is_a?(Array)
end

run_test("parses cross-style game") do
  position = Feen.parse("K / C/s")
  raise "wrong first style" unless position.styles[:first] == "C"
  raise "wrong second style" unless position.styles[:second] == "s"
  raise "wrong turn" unless position.turn == :first
end

run_test("parses position with second to move") do
  position = Feen.parse("K / c/C")
  raise "should be second to move" unless position.turn == :second
end

run_test("parses position with EPIN modifiers") do
  position = Feen.parse("+K^'-q^' / C/c")
  pieces = position.board.compact
  raise "wrong pieces" unless pieces.size == 2
  raise "wrong first piece" unless pieces[0] == "+K^'"
  raise "wrong second piece" unless pieces[1] == "-q^'"
end

run_test("parses 1D board") do
  position = Feen.parse("K2Q3R / C/c")
  raise "expected flat array" if position.board[0].is_a?(Array)
  raise "wrong size" unless position.board.size == 8
end

# ============================================================================
# PARSE - INVALID INPUTS
# ============================================================================

puts
puts "parse - invalid inputs:"

run_test("raises for empty string") do
  Feen.parse("")
  raise "should have raised"
rescue Feen::ParseError
  # Expected
end

run_test("raises for wrong field count") do
  Feen.parse("K")
  raise "should have raised"
rescue Feen::ParseError => e
  raise "wrong message" unless e.message.include?("field")
end

run_test("raises for invalid piece placement") do
  Feen.parse("/K / C/c")
  raise "should have raised"
rescue Feen::PiecePlacementError
  # Expected
end

run_test("raises for invalid hands") do
  Feen.parse("K PP/ C/c")
  raise "should have raised"
rescue Feen::HandsError
  # Expected
end

run_test("raises for invalid style-turn") do
  Feen.parse("K / C/C")
  raise "should have raised"
rescue Feen::StyleTurnError
  # Expected
end

run_test("raises for too many pieces") do
  Feen.parse("K 2P/ C/c")
  raise "should have raised"
rescue Feen::CardinalityError
  # Expected
end

run_test("raises for string too long") do
  long_string = "K" * 4097 + " / C/c"
  Feen.parse(long_string)
  raise "should have raised"
rescue Feen::ParseError
  # Expected
end

run_test("all errors inherit from Feen::Error") do
  begin
    Feen.parse("invalid")
  rescue Feen::Error
    # Expected - catches all FEEN errors
  end
end

run_test("all errors inherit from ArgumentError") do
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

run_test("returns true for minimal FEEN") do
  raise "should be valid" unless Feen.valid?("K / C/c")
end

run_test("returns true for Chess initial position") do
  raise "should be valid" unless Feen.valid?("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c")
end

run_test("returns true for Shogi initial position") do
  raise "should be valid" unless Feen.valid?("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s")
end

run_test("returns true for Xiangqi initial position") do
  raise "should be valid" unless Feen.valid?("rheagaehr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RHEAGAEHR / X/x")
end

run_test("returns true for position with hands") do
  raise "should be valid" unless Feen.valid?("8/8/8/8/8/8/8/8 3B2PNR/2qp C/c")
end

run_test("returns true for 3D position") do
  raise "should be valid" unless Feen.valid?("4/4//4/4 / C/c")
end

run_test("returns true for cross-style game") do
  raise "should be valid" unless Feen.valid?("K / C/s")
end

run_test("returns true for second to move") do
  raise "should be valid" unless Feen.valid?("K / c/C")
end

run_test("returns true for empty board") do
  raise "should be valid" unless Feen.valid?("8 / C/c")
end

run_test("returns true for 1D board") do
  raise "should be valid" unless Feen.valid?("K2Q3R / C/c")
end

run_test("returns true for position with EPIN modifiers") do
  raise "should be valid" unless Feen.valid?("+K^'-q^' / C/c")
end

# ============================================================================
# VALID? - FALSE CASES
# ============================================================================

puts
puts "valid? - false cases:"

run_test("returns false for nil") do
  raise "should be invalid" if Feen.valid?(nil)
end

run_test("returns false for Integer") do
  raise "should be invalid" if Feen.valid?(123)
end

run_test("returns false for Symbol") do
  raise "should be invalid" if Feen.valid?(:symbol)
end

run_test("returns false for Array") do
  raise "should be invalid" if Feen.valid?([])
end

run_test("returns false for Hash") do
  raise "should be invalid" if Feen.valid?({})
end

run_test("returns false for empty string") do
  raise "should be invalid" if Feen.valid?("")
end

run_test("returns false for one field") do
  raise "should be invalid" if Feen.valid?("K")
end

run_test("returns false for two fields") do
  raise "should be invalid" if Feen.valid?("K /")
end

run_test("returns false for four fields") do
  raise "should be invalid" if Feen.valid?("K / C/c extra")
end

run_test("returns false for invalid piece placement") do
  raise "should be invalid" if Feen.valid?("/K / C/c")
end

run_test("returns false for invalid character in piece placement") do
  raise "should be invalid" if Feen.valid?("K@Q / C/c")
end

run_test("returns false for invalid hands") do
  raise "should be invalid" if Feen.valid?("K PP/ C/c")
end

run_test("returns false for invalid style-turn") do
  raise "should be invalid" if Feen.valid?("K / C/C")
end

run_test("returns false for too many pieces") do
  raise "should be invalid" if Feen.valid?("K 2P/ C/c")
end

run_test("returns false for string too long") do
  raise "should be invalid" if Feen.valid?("K" * 4097 + " / C/c")
end

run_test("returns false for dimension size exceeded") do
  raise "should be invalid" if Feen.valid?("256 / C/c")
end

run_test("returns false for exceeding dimensions") do
  raise "should be invalid" if Feen.valid?("1/1//1/1///1/1//1/1////1 / C/c")
end

run_test("returns false for invalid empty count") do
  raise "should be invalid" if Feen.valid?("0 / C/c")
end

run_test("returns false for leading zeros in empty count") do
  raise "should be invalid" if Feen.valid?("01 / C/c")
end

# ============================================================================
# VALID? SAFETY
# ============================================================================

puts
puts "valid? safety:"

run_test("valid? never raises") do
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

run_test("dumps a Qi::Position to String") do
  position = Feen.parse("K / C/c")
  result = Feen.dump(position)
  raise "expected String" unless result.is_a?(String)
end

run_test("dumps minimal position") do
  position = Qi.new(["K"], { first: [], second: [] }, { first: "C", second: "c" }, :first)
  result = Feen.dump(position)
  raise "expected 'K / C/c'" unless result == "K / C/c"
end

run_test("dumps position with hands") do
  position = Qi.new(
    Array.new(8),
    { first: ["P", "P"], second: ["p"] },
    { first: "S", second: "s" },
    :first
  )
  result = Feen.dump(position)
  raise "expected '8 2P/p S/s'" unless result == "8 2P/p S/s"
end

run_test("dumps returns String") do
  position = Qi.new(["K"], { first: [], second: [] }, { first: "C", second: "c" }, :first)
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
  run_test("round-trip: #{feen}") do
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

run_test("1D position round-trips") do
  original = Qi.new(
    ["K", nil, nil, nil, nil, nil, nil, "k"],
    { first: [], second: [] },
    { first: "C", second: "c" },
    :first
  )
  feen = Feen.dump(original)
  restored = Feen.parse(feen)
  raise "board mismatch" unless restored.board == original.board
  raise "hands mismatch" unless restored.hands == original.hands
  raise "styles mismatch" unless restored.styles == original.styles
  raise "turn mismatch" unless restored.turn == original.turn
end

run_test("2D position round-trips") do
  original = Qi.new(
    [["K", nil, nil, nil, nil, nil, nil, "k"], Array.new(8)],
    { first: [], second: [] },
    { first: "C", second: "c" },
    :first
  )
  feen = Feen.dump(original)
  restored = Feen.parse(feen)
  raise "board mismatch" unless restored.board == original.board
  raise "hands mismatch" unless restored.hands == original.hands
  raise "styles mismatch" unless restored.styles == original.styles
  raise "turn mismatch" unless restored.turn == original.turn
end

run_test("position with hands round-trips") do
  original = Qi.new(
    Array.new(8) { Array.new(8) },
    { first: ["B", "B", "B", "P", "P", "N", "R"], second: ["q", "q", "p"] },
    { first: "C", second: "c" },
    :first
  )
  feen = Feen.dump(original)
  restored = Feen.parse(feen)
  raise "hands mismatch" unless restored.hands == original.hands
end

run_test("3D position round-trips") do
  original = Qi.new(
    [[["a", "b"], ["c", "d"]], [["A", "B"], ["C", "D"]]],
    { first: [], second: [] },
    { first: "C", second: "c" },
    :first
  )
  feen = Feen.dump(original)
  restored = Feen.parse(feen)
  raise "board mismatch" unless restored.board == original.board
end

# ============================================================================
# ERROR HIERARCHY
# ============================================================================

puts
puts "error hierarchy:"

run_test("Error inherits from ArgumentError") do
  raise "wrong parent" unless Feen::Error < ArgumentError
end

run_test("ParseError inherits from Error") do
  raise "wrong parent" unless Feen::ParseError < Feen::Error
end

run_test("PiecePlacementError inherits from ParseError") do
  raise "wrong parent" unless Feen::PiecePlacementError < Feen::ParseError
end

run_test("HandsError inherits from ParseError") do
  raise "wrong parent" unless Feen::HandsError < Feen::ParseError
end

run_test("StyleTurnError inherits from ParseError") do
  raise "wrong parent" unless Feen::StyleTurnError < Feen::ParseError
end

run_test("CardinalityError inherits from ParseError") do
  raise "wrong parent" unless Feen::CardinalityError < Feen::ParseError
end

# ============================================================================
# MODULE STRUCTURE
# ============================================================================

puts
puts "module structure:"

run_test("Feen is a Module") do
  raise "wrong type" unless Feen.is_a?(Module)
end

run_test("Feen is nested under Sashite") do
  raise "wrong nesting" unless Sashite.const_defined?(:Feen)
end

run_test("Feen responds to parse") do
  raise "should respond to parse" unless Feen.respond_to?(:parse)
end

run_test("Feen responds to valid?") do
  raise "should respond to valid?" unless Feen.respond_to?(:valid?)
end

run_test("Feen responds to dump") do
  raise "should respond to dump" unless Feen.respond_to?(:dump)
end

run_test("Parser is accessible") do
  raise "missing Parser" unless defined?(Feen::Parser)
end

run_test("Dumper is accessible") do
  raise "missing Dumper" unless defined?(Feen::Dumper)
end

# ============================================================================
# EXTERNAL DEPENDENCIES
# ============================================================================

puts
puts "external dependencies:"

run_test("Qi is loaded") do
  raise "missing Qi" unless defined?(Qi)
end

run_test("Epin is loaded") do
  raise "missing Epin" unless defined?(Sashite::Epin)
end

run_test("Sin is loaded") do
  raise "missing Sin" unless defined?(Sashite::Sin)
end

# ============================================================================
# MULTIPLE GAME TYPES
# ============================================================================

puts
puts "multiple game types:"

run_test("supports Chess") do
  position = Feen.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c")
  raise "wrong style" unless position.styles[:first] == "C"
end

run_test("supports Shogi") do
  position = Feen.parse("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s")
  raise "wrong style" unless position.styles[:first] == "S"
end

run_test("supports Xiangqi") do
  position = Feen.parse("rheagaehr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RHEAGAEHR / X/x")
  raise "wrong style" unless position.styles[:first] == "X"
end

run_test("supports Go") do
  position = Feen.parse("9/9/9/9/9/9/9/9/9 / G/g")
  raise "wrong style" unless position.styles[:first] == "G"
end

run_test("supports cross-style games") do
  position = Feen.parse("K / C/s")
  raise "wrong first" unless position.styles[:first] == "C"
  raise "wrong second" unless position.styles[:second] == "s"
end

puts
puts "All Feen integration tests passed!"
puts
