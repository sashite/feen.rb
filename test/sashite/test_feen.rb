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
  raise "wrong type" unless position.is_a?(Feen::Position)
end

run_test("parses Chess initial position") do
  position = Feen.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c")
  raise "wrong squares" unless position.squares_count == 64
  raise "wrong pieces" unless position.pieces_count == 32
end

run_test("parses Shogi initial position") do
  position = Feen.parse("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s")
  raise "wrong squares" unless position.squares_count == 81
  raise "wrong pieces" unless position.pieces_count == 40
end

run_test("parses Xiangqi initial position") do
  position = Feen.parse("rheagaehr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RHEAGAEHR / X/x")
  raise "wrong squares" unless position.squares_count == 90
end

run_test("parses position with pieces in hands") do
  position = Feen.parse("8/8/8/8/8/8/8/8 3B2PNR/2qp C/c")
  raise "wrong first hand" unless position.hands.first.pieces_count == 7
  raise "wrong second hand" unless position.hands.second.pieces_count == 3
end

run_test("parses 3D position") do
  position = Feen.parse("4/4//4/4 / C/c")
  raise "wrong dimensions" unless position.piece_placement.dimensions == 3
end

run_test("parses cross-style game") do
  position = Feen.parse("K / C/s")
  raise "wrong active" unless position.style_turn.active_style.abbr == :C
  raise "wrong inactive" unless position.style_turn.inactive_style.abbr == :S
end

run_test("parses position with second to move") do
  position = Feen.parse("K / c/C")
  raise "should be second to move" unless position.style_turn.second_to_move?
end

run_test("parses position with EPIN modifiers") do
  position = Feen.parse("+K^'-q^' / C/c")
  raise "wrong pieces" unless position.pieces_count == 2
end

run_test("returns frozen Position") do
  position = Feen.parse("K / C/c")
  raise "should be frozen" unless position.frozen?
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

run_test("returns false for leading zero") do
  raise "should be invalid" if Feen.valid?("08 / C/c")
end

# ============================================================================
# DUMP - BASIC
# ============================================================================

puts
puts "dump - basic:"

run_test("dumps minimal position") do
  result = Feen.dump(
    piece_placement: { segments: [["K"]], separators: [] },
    hands: { first: [], second: [] },
    style_turn: { active: "C", inactive: "c" }
  )
  raise "expected 'K / C/c'" unless result == "K / C/c"
end

run_test("dumps position with empty board") do
  result = Feen.dump(
    piece_placement: {
      segments: [[8], [8], [8], [8], [8], [8], [8], [8]],
      separators: ["/", "/", "/", "/", "/", "/", "/"]
    },
    hands: { first: [], second: [] },
    style_turn: { active: "C", inactive: "c" }
  )
  raise "expected empty Chess board" unless result == "8/8/8/8/8/8/8/8 / C/c"
end

run_test("dumps position with hands") do
  result = Feen.dump(
    piece_placement: { segments: [[8]], separators: [] },
    hands: {
      first: [{ piece: "P", count: 2 }],
      second: [{ piece: "p", count: 1 }]
    },
    style_turn: { active: "S", inactive: "s" }
  )
  raise "expected '8 2P/p S/s'" unless result == "8 2P/p S/s"
end

run_test("dumps returns String") do
  result = Feen.dump(
    piece_placement: { segments: [["K"]], separators: [] },
    hands: { first: [], second: [] },
    style_turn: { active: "C", inactive: "c" }
  )
  raise "expected String" unless result.is_a?(String)
end

# ============================================================================
# ROUND-TRIP
# ============================================================================

puts
puts "Round-trip (parse -> to_s):"

run_test("round-trip minimal") do
  input = "K / C/c"
  position = Feen.parse(input)
  raise "round-trip failed" unless position.to_s == input
end

run_test("round-trip Chess initial") do
  input = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c"
  position = Feen.parse(input)
  raise "round-trip failed" unless position.to_s == input
end

run_test("round-trip Shogi initial") do
  input = "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s"
  position = Feen.parse(input)
  raise "round-trip failed" unless position.to_s == input
end

run_test("round-trip with hands") do
  input = "8/8/8/8/8/8/8/8 3B2PNR/2qp C/c"
  position = Feen.parse(input)
  raise "round-trip failed" unless position.to_s == input
end

run_test("round-trip 3D") do
  input = "4/4//4/4 / C/c"
  position = Feen.parse(input)
  raise "round-trip failed" unless position.to_s == input
end

run_test("round-trip cross-style") do
  input = "K / C/s"
  position = Feen.parse(input)
  raise "round-trip failed" unless position.to_s == input
end

# ============================================================================
# POSITION ACCESS
# ============================================================================

puts
puts "Position component access:"

run_test("position provides piece_placement") do
  position = Feen.parse("K3 2P/p C/c")
  raise "wrong type" unless position.piece_placement.is_a?(Feen::Position::PiecePlacement)
  raise "wrong squares" unless position.piece_placement.squares_count == 4
end

run_test("position provides hands") do
  position = Feen.parse("K3 2P/p C/c")
  raise "wrong type" unless position.hands.is_a?(Feen::Position::Hands)
  raise "wrong first" unless position.hands.first.pieces_count == 2
  raise "wrong second" unless position.hands.second.pieces_count == 1
end

run_test("position provides style_turn") do
  position = Feen.parse("K3 2P/p C/c")
  raise "wrong type" unless position.style_turn.is_a?(Feen::Position::StyleTurn)
  raise "wrong turn" unless position.style_turn.first_to_move?
end

run_test("position is iterable via piece_placement") do
  position = Feen.parse("K2Q / C/c")
  tokens = position.piece_placement.map { |t| t.is_a?(Integer) ? t : t.to_s }
  raise "wrong tokens" unless tokens == ["K", 2, "Q"]
end

# ============================================================================
# POSITION AS HASH KEY
# ============================================================================

puts
puts "Position as hash key:"

run_test("equal positions have same hash") do
  p1 = Feen.parse("K / C/c")
  p2 = Feen.parse("K / C/c")
  raise "should have same hash" unless p1.hash == p2.hash
end

run_test("position can be used as hash key") do
  p1 = Feen.parse("K / C/c")
  p2 = Feen.parse("K / C/c")
  hash = { p1 => "value" }
  raise "should find by equal key" unless hash[p2] == "value"
end

run_test("different positions have different hash") do
  p1 = Feen.parse("K / C/c")
  p2 = Feen.parse("Q / C/c")
  raise "should have different hash" if p1.hash == p2.hash
end

# ============================================================================
# ERROR HIERARCHY
# ============================================================================

puts
puts "Error hierarchy:"

run_test("Error exists") do
  raise "missing Error" unless defined?(Feen::Error)
end

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
puts "Module structure:"

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

run_test("Position is accessible") do
  raise "missing Position" unless defined?(Feen::Position)
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

# ============================================================================
# VALID? DOES NOT RAISE
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
# MULTIPLE GAME TYPES
# ============================================================================

puts
puts "Multiple game types:"

run_test("supports Chess") do
  position = Feen.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c")
  raise "wrong style" unless position.style_turn.active_style.abbr == :C
end

run_test("supports Shogi") do
  position = Feen.parse("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s")
  raise "wrong style" unless position.style_turn.active_style.abbr == :S
end

run_test("supports Xiangqi") do
  position = Feen.parse("rheagaehr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RHEAGAEHR / X/x")
  raise "wrong style" unless position.style_turn.active_style.abbr == :X
end

run_test("supports Go") do
  position = Feen.parse("9/9/9/9/9/9/9/9/9 / G/g")
  raise "wrong style" unless position.style_turn.active_style.abbr == :G
end

run_test("supports cross-style games") do
  position = Feen.parse("K / C/s")
  raise "wrong active" unless position.style_turn.active_style.abbr == :C
  raise "wrong inactive" unless position.style_turn.inactive_style.abbr == :S
end

puts
puts "All Feen integration tests passed!"
puts
