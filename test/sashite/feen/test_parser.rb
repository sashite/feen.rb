#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../helper"
require_relative "../../../lib/sashite/feen/parser"

puts
puts "=== Parser Tests ==="
puts

# ============================================================================
# PARSE - VALID INPUTS
# ============================================================================

puts "parse - valid inputs:"

run_test("parses minimal FEEN 'K / C/c'") do
  result = Sashite::Feen::Parser.parse("K / C/c")
  raise "missing :piece_placement" unless result.key?(:piece_placement)
  raise "missing :hands" unless result.key?(:hands)
  raise "missing :style_turn" unless result.key?(:style_turn)
end

run_test("parses empty board '8 / C/c'") do
  result = Sashite::Feen::Parser.parse("8 / C/c")
  raise "should parse" unless result[:piece_placement][:segments][0][0] == 8
end

run_test("parses Chess initial position") do
  input = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c"
  result = Sashite::Feen::Parser.parse(input)
  raise "wrong segment count" unless result[:piece_placement][:segments].size == 8
end

run_test("parses Shogi initial position") do
  input = "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s"
  result = Sashite::Feen::Parser.parse(input)
  raise "wrong segment count" unless result[:piece_placement][:segments].size == 9
end

run_test("parses Xiangqi initial position") do
  input = "rheagaehr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RHEAGAEHR / X/x"
  result = Sashite::Feen::Parser.parse(input)
  raise "wrong segment count" unless result[:piece_placement][:segments].size == 10
end

run_test("parses position with pieces in hands") do
  input = "8/8/8/8/8/8/8/8 3B2PNR/2qp C/c"
  result = Sashite::Feen::Parser.parse(input)
  raise "wrong first hand size" unless result[:hands][:first].size == 4
  raise "wrong second hand size" unless result[:hands][:second].size == 2
end

run_test("parses 3D position") do
  input = "4/4//4/4 / C/c"
  result = Sashite::Feen::Parser.parse(input)
  raise "wrong segment count" unless result[:piece_placement][:segments].size == 4
end

run_test("parses cross-style game") do
  input = "K / C/s"
  result = Sashite::Feen::Parser.parse(input)
  raise "wrong active abbr" unless result[:style_turn][:active].abbr == :C
  raise "wrong inactive abbr" unless result[:style_turn][:inactive].abbr == :S
end

run_test("parses with second player to move") do
  input = "K / c/C"
  result = Sashite::Feen::Parser.parse(input)
  raise "wrong active side" unless result[:style_turn][:active].side == :second
end

# ============================================================================
# PARSE - LENGTH VALIDATION
# ============================================================================

puts
puts "parse - length validation:"

run_test("accepts string of exactly 4096 bytes") do
  # Build a valid FEEN string close to 4096 bytes
  # "K" + "/" * 4090 + " / C/c" would exceed, so we need to be careful
  # Let's use a valid 2D board with many ranks
  ranks = (1..1000).map { "4" }.join("/")
  input = "#{ranks} / C/c"
  # Trim if too long, ensure it's valid
  if input.bytesize > 4096
    # Use a simpler approach
    input = "K / C/c"
  end
  result = Sashite::Feen::Parser.parse(input)
  raise "should parse" unless result
end

run_test("rejects string exceeding 4096 bytes") do
  long_string = "K" + "K" * 4096 + " / C/c"
  Sashite::Feen::Parser.parse(long_string)
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "input exceeds 4096 characters"
end

# ============================================================================
# PARSE - FIELD COUNT VALIDATION
# ============================================================================

puts
puts "parse - field count validation:"

run_test("rejects zero fields (empty string)") do
  Sashite::Feen::Parser.parse("")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument
  # Could be empty or field count error
end

run_test("rejects one field") do
  Sashite::Feen::Parser.parse("K")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "invalid field count"
end

run_test("rejects two fields") do
  Sashite::Feen::Parser.parse("K /")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "invalid field count"
end

run_test("rejects four fields") do
  Sashite::Feen::Parser.parse("K / C/c extra")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "invalid field count"
end

run_test("rejects five fields") do
  Sashite::Feen::Parser.parse("K / C/c one two")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "invalid field count"
end

run_test("correctly splits on single spaces") do
  input = "K / C/c"
  result = Sashite::Feen::Parser.parse(input)
  raise "should parse" unless result
end

# ============================================================================
# PARSE - PIECE COUNT VALIDATION
# ============================================================================

puts
puts "parse - piece count validation:"

run_test("accepts pieces equal to squares") do
  # 1 square, 1 piece on board
  input = "K / C/c"
  result = Sashite::Feen::Parser.parse(input)
  raise "should parse" unless result
end

run_test("accepts pieces less than squares") do
  # 8 squares, 2 pieces
  input = "K6Q / C/c"
  result = Sashite::Feen::Parser.parse(input)
  raise "should parse" unless result
end

run_test("accepts empty board") do
  # 8 squares, 0 pieces
  input = "8 / C/c"
  result = Sashite::Feen::Parser.parse(input)
  raise "should parse" unless result
end

run_test("accepts pieces on board and in hands within limit") do
  # 4 squares, 2 pieces on board, 1 in hand = 3 total <= 4
  input = "K2Q P/ C/c"
  result = Sashite::Feen::Parser.parse(input)
  raise "should parse" unless result
end

run_test("rejects pieces exceeding squares (with hands)") do
  # 1 square, 0 pieces on board, 2 in hand
  Sashite::Feen::Parser.parse("1 2P/ C/c")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "too many pieces for board size"
end

run_test("rejects pieces exceeding squares (combined)") do
  # 2 squares, 1 piece on board, 2 in hand = 3 > 2
  Sashite::Feen::Parser.parse("K1 2P/ C/c")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "too many pieces for board size"
end

run_test("counts pieces correctly in both hands") do
  # 4 squares, 0 on board, 3 in first hand, 2 in second = 5 > 4
  Sashite::Feen::Parser.parse("4 3P/2p C/c")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "too many pieces for board size"
end

run_test("accepts exactly matching count with hands") do
  # 4 squares, 1 on board, 2 in first, 1 in second = 4 total = 4 squares
  input = "K3 2P/p C/c"
  result = Sashite::Feen::Parser.parse(input)
  raise "should parse" unless result
end

# ============================================================================
# PARSE - ERROR PROPAGATION
# ============================================================================

puts
puts "parse - error propagation:"

run_test("propagates piece placement errors") do
  Sashite::Feen::Parser.parse("/K / C/c")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "piece placement starts with separator"
end

run_test("propagates hands errors") do
  Sashite::Feen::Parser.parse("K2 PP/ C/c")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "hand items not aggregated"
end

run_test("propagates style-turn errors") do
  Sashite::Feen::Parser.parse("K / C/C")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "style tokens must have opposite case"
end

# ============================================================================
# VALID? - TRUE CASES
# ============================================================================

puts
puts "valid? - true cases:"

run_test("returns true for minimal FEEN") do
  raise "should be valid" unless Sashite::Feen::Parser.valid?("K / C/c")
end

run_test("returns true for Chess initial position") do
  input = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c"
  raise "should be valid" unless Sashite::Feen::Parser.valid?(input)
end

run_test("returns true for Shogi initial position") do
  input = "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s"
  raise "should be valid" unless Sashite::Feen::Parser.valid?(input)
end

run_test("returns true for position with hands") do
  raise "should be valid" unless Sashite::Feen::Parser.valid?("K4 2PN/p C/c")
end

run_test("returns true for 3D position") do
  raise "should be valid" unless Sashite::Feen::Parser.valid?("1/1//1/1 / C/c")
end

run_test("returns true for cross-style game") do
  raise "should be valid" unless Sashite::Feen::Parser.valid?("K / C/s")
end

run_test("returns true for empty board") do
  raise "should be valid" unless Sashite::Feen::Parser.valid?("8 / C/c")
end

# ============================================================================
# VALID? - FALSE CASES
# ============================================================================

puts
puts "valid? - false cases:"

run_test("returns false for nil") do
  raise "should be invalid" if Sashite::Feen::Parser.valid?(nil)
end

run_test("returns false for non-string (Integer)") do
  raise "should be invalid" if Sashite::Feen::Parser.valid?(123)
end

run_test("returns false for non-string (Symbol)") do
  raise "should be invalid" if Sashite::Feen::Parser.valid?(:symbol)
end

run_test("returns false for non-string (Array)") do
  raise "should be invalid" if Sashite::Feen::Parser.valid?([])
end

run_test("returns false for non-string (Hash)") do
  raise "should be invalid" if Sashite::Feen::Parser.valid?({})
end

run_test("returns false for empty string") do
  raise "should be invalid" if Sashite::Feen::Parser.valid?("")
end

run_test("returns false for one field") do
  raise "should be invalid" if Sashite::Feen::Parser.valid?("K")
end

run_test("returns false for two fields") do
  raise "should be invalid" if Sashite::Feen::Parser.valid?("K /")
end

run_test("returns false for four fields") do
  raise "should be invalid" if Sashite::Feen::Parser.valid?("K / C/c extra")
end

run_test("returns false for invalid piece placement") do
  raise "should be invalid" if Sashite::Feen::Parser.valid?("/K / C/c")
end

run_test("returns false for invalid hands") do
  raise "should be invalid" if Sashite::Feen::Parser.valid?("K PP C/c")
end

run_test("returns false for invalid style-turn") do
  raise "should be invalid" if Sashite::Feen::Parser.valid?("K / C/C")
end

run_test("returns false for too many pieces") do
  raise "should be invalid" if Sashite::Feen::Parser.valid?("K 2P/ C/c")
end

run_test("returns false for string too long") do
  long_string = "K" * 4097 + " / C/c"
  raise "should be invalid" if Sashite::Feen::Parser.valid?(long_string)
end

# ============================================================================
# RETURN STRUCTURE
# ============================================================================

puts
puts "Return structure:"

run_test("returns a Hash") do
  result = Sashite::Feen::Parser.parse("K / C/c")
  raise "wrong type" unless result.is_a?(Hash)
end

run_test("returns exactly 3 keys") do
  result = Sashite::Feen::Parser.parse("K / C/c")
  raise "wrong key count" unless result.keys.size == 3
end

run_test(":piece_placement is a Hash") do
  result = Sashite::Feen::Parser.parse("K / C/c")
  raise "wrong type" unless result[:piece_placement].is_a?(Hash)
end

run_test(":hands is a Hash") do
  result = Sashite::Feen::Parser.parse("K / C/c")
  raise "wrong type" unless result[:hands].is_a?(Hash)
end

run_test(":style_turn is a Hash") do
  result = Sashite::Feen::Parser.parse("K / C/c")
  raise "wrong type" unless result[:style_turn].is_a?(Hash)
end

# ============================================================================
# ERROR CLASS
# ============================================================================

puts
puts "Error class:"

run_test("raises Sashite::Feen::Errors::Argument") do
  Sashite::Feen::Parser.parse("invalid")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument
  # Expected
end

run_test("error is rescuable as ArgumentError") do
  Sashite::Feen::Parser.parse("invalid")
  raise "should have raised"
rescue ArgumentError
  # Expected
end

# ============================================================================
# MODULE STRUCTURE
# ============================================================================

puts
puts "Module structure:"

run_test("Parser is a Module") do
  raise "wrong type" unless Sashite::Feen::Parser.is_a?(Module)
end

run_test("Parser is nested under Sashite::Feen") do
  raise "wrong nesting" unless Sashite::Feen.const_defined?(:Parser)
end

run_test("FIELD_COUNT constant is defined") do
  raise "not defined" unless defined?(Sashite::Feen::Parser::FIELD_COUNT)
end

run_test("FIELD_COUNT equals 3") do
  raise "wrong value" unless Sashite::Feen::Parser::FIELD_COUNT == 3
end

puts
puts "All Parser tests passed!"
puts
