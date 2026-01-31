#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/parser/piece_placement"

puts
puts "=== Parser::PiecePlacement Tests ==="
puts

# ============================================================================
# VALID 1D BOARDS
# ============================================================================

puts "Valid 1D boards:"

run_test("parses single piece") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("K")
  raise "wrong segments count" unless result[:segments].size == 1
  raise "wrong separators count" unless result[:separators].empty?
  raise "wrong token count" unless result[:segments][0].size == 1
end

run_test("parses single empty count") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("8")
  raise "wrong segments count" unless result[:segments].size == 1
  raise "wrong token" unless result[:segments][0][0] == 8
end

run_test("parses large empty count") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("255")
  raise "wrong token" unless result[:segments][0][0] == 255
end

run_test("parses mixed pieces and empty counts") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("K2Q")
  segment = result[:segments][0]
  raise "wrong token count" unless segment.size == 3
  raise "wrong second token" unless segment[1] == 2
end

run_test("parses multiple pieces") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("KQR")
  segment = result[:segments][0]
  raise "wrong token count" unless segment.size == 3
end

# ============================================================================
# VALID 2D BOARDS
# ============================================================================

puts
puts "Valid 2D boards:"

run_test("parses simple 2D board") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("8/8")
  raise "wrong segments count" unless result[:segments].size == 2
  raise "wrong separators count" unless result[:separators].size == 1
  raise "wrong separator" unless result[:separators][0] == "/"
end

run_test("parses Chess initial position") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR")
  raise "wrong segments count" unless result[:segments].size == 8
  raise "wrong separators count" unless result[:separators].size == 7
end

run_test("parses Shogi board (9x9)") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL")
  raise "wrong segments count" unless result[:segments].size == 9
end

run_test("parses Xiangqi board (9x10)") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("rheagaehr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RHEAGAEHR")
  raise "wrong segments count" unless result[:segments].size == 10
end

# ============================================================================
# VALID 3D BOARDS
# ============================================================================

puts
puts "Valid 3D boards:"

run_test("parses simple 3D board") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("4/4//4/4")
  raise "wrong segments count" unless result[:segments].size == 4
  raise "wrong separators" unless result[:separators] == ["/", "//", "/"]
end

run_test("parses 3D board with pieces") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("K3/4//4/3k")
  raise "wrong segments count" unless result[:segments].size == 4
end

run_test("parses Raumschach-style 5x5x5") do
  input = "5/5/5/5/5//5/5/2K2/5/5//5/5/5/5/5//5/5/2k2/5/5//5/5/5/5/5"
  result = Sashite::Feen::Parser::PiecePlacement.parse(input)
  raise "wrong segments count" unless result[:segments].size == 25
  double_seps = result[:separators].count("//")
  raise "wrong double separator count" unless double_seps == 4
end

run_test("preserves separator structure") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("1/1//1/1//1/1")
  raise "wrong separators" unless result[:separators] == ["/", "//", "/", "//", "/"]
end

# ============================================================================
# EPIN MODIFIERS
# ============================================================================

puts
puts "EPIN modifiers:"

run_test("parses uppercase piece") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("K")
  piece = result[:segments][0][0]
  raise "wrong side" unless piece.pin.side == :first
end

run_test("parses lowercase piece") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("k")
  piece = result[:segments][0][0]
  raise "wrong side" unless piece.pin.side == :second
end

run_test("parses enhanced piece (+)") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("+P")
  piece = result[:segments][0][0]
  raise "wrong state" unless piece.pin.state == :enhanced
end

run_test("parses diminished piece (-)") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("-P")
  piece = result[:segments][0][0]
  raise "wrong state" unless piece.pin.state == :diminished
end

run_test("parses terminal piece (^)") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("K^")
  piece = result[:segments][0][0]
  raise "not terminal" unless piece.pin.terminal?
end

run_test("parses derived piece (')") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("K'")
  piece = result[:segments][0][0]
  raise "not derived" unless piece.derived?
end

run_test("parses all modifiers combined (+K^')") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("+K^'")
  piece = result[:segments][0][0]
  raise "wrong state" unless piece.pin.state == :enhanced
  raise "not terminal" unless piece.pin.terminal?
  raise "not derived" unless piece.derived?
end

run_test("parses diminished terminal derived (-k^')") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("-k^'")
  piece = result[:segments][0][0]
  raise "wrong state" unless piece.pin.state == :diminished
  raise "not terminal" unless piece.pin.terminal?
  raise "not derived" unless piece.derived?
  raise "wrong side" unless piece.pin.side == :second
end

run_test("parses mixed modifiers in segment") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("+P2-k^'K")
  segment = result[:segments][0]
  raise "wrong token count" unless segment.size == 4
  raise "first not enhanced" unless segment[0].pin.state == :enhanced
  raise "second not empty count" unless segment[1] == 2
  raise "third not diminished" unless segment[2].pin.state == :diminished
end

# ============================================================================
# EMPTY COUNT VALIDATION
# ============================================================================

puts
puts "Empty count validation:"

run_test("accepts count of 1") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("1")
  raise "wrong token" unless result[:segments][0][0] == 1
end

run_test("accepts count of 9") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("9")
  raise "wrong token" unless result[:segments][0][0] == 9
end

run_test("accepts count of 10") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("10")
  raise "wrong token" unless result[:segments][0][0] == 10
end

run_test("accepts count of 99") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("99")
  raise "wrong token" unless result[:segments][0][0] == 99
end

run_test("accepts count of 100") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("100")
  raise "wrong token" unless result[:segments][0][0] == 100
end

run_test("rejects count of 0") do
  Sashite::Feen::Parser::PiecePlacement.parse("0")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "invalid empty count"
end

run_test("rejects leading zero (08)") do
  Sashite::Feen::Parser::PiecePlacement.parse("08")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "invalid empty count"
end

run_test("rejects leading zeros (008)") do
  Sashite::Feen::Parser::PiecePlacement.parse("008")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "invalid empty count"
end

# ============================================================================
# CONSECUTIVE EMPTY COUNTS
# ============================================================================

puts
puts "Consecutive empty counts:"

run_test("accepts empty counts separated by piece") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("3K2")
  segment = result[:segments][0]
  raise "wrong token count" unless segment.size == 3
  raise "wrong first" unless segment[0] == 3
  raise "wrong last" unless segment[2] == 2
end

run_test("accepts empty counts in different segments") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("3/2")
  raise "wrong first segment" unless result[:segments][0][0] == 3
  raise "wrong second segment" unless result[:segments][1][0] == 2
end

# ============================================================================
# BOUNDARY VALIDATION
# ============================================================================

puts
puts "Boundary validation:"

run_test("rejects empty input") do
  Sashite::Feen::Parser::PiecePlacement.parse("")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "piece placement is empty"
end

run_test("rejects leading separator") do
  Sashite::Feen::Parser::PiecePlacement.parse("/8")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "piece placement starts with separator"
end

run_test("rejects trailing separator") do
  Sashite::Feen::Parser::PiecePlacement.parse("8/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "piece placement ends with separator"
end

run_test("rejects only separator") do
  Sashite::Feen::Parser::PiecePlacement.parse("/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "piece placement starts with separator"
end

run_test("rejects double leading separator") do
  Sashite::Feen::Parser::PiecePlacement.parse("//8")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "piece placement starts with separator"
end

run_test("rejects double trailing separator") do
  Sashite::Feen::Parser::PiecePlacement.parse("8//")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "piece placement ends with separator"
end

# ============================================================================
# DIMENSIONAL COHERENCE
# ============================================================================

puts
puts "Dimensional coherence:"

run_test("accepts valid 3D structure") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("1/1//1/1")
  raise "should parse" unless result[:segments].size == 4
end

run_test("rejects exceeding max dimensions (4D)") do
  Sashite::Feen::Parser::PiecePlacement.parse("1/1//1/1///1/1//1/1////1")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "exceeds 3 dimensions"
end

# ============================================================================
# DIMENSION SIZE VALIDATION
# ============================================================================

puts
puts "Dimension size validation:"

run_test("accepts dimension size of 255") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("255")
  raise "should parse" unless result[:segments][0][0] == 255
end

run_test("rejects dimension size of 256") do
  Sashite::Feen::Parser::PiecePlacement.parse("256")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "dimension size exceeds 255"
end

run_test("rejects combined size exceeding 255") do
  Sashite::Feen::Parser::PiecePlacement.parse("200K56")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "dimension size exceeds 255"
end

run_test("accepts combined size of exactly 255") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("200K54")
  segment = result[:segments][0]
  raise "wrong token count" unless segment.size == 3
end

# ============================================================================
# INVALID PIECE TOKEN
# ============================================================================

puts
puts "Invalid piece token:"

run_test("rejects invalid character") do
  Sashite::Feen::Parser::PiecePlacement.parse("K@Q")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "invalid piece token"
end

run_test("rejects standalone modifier") do
  Sashite::Feen::Parser::PiecePlacement.parse("+")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "invalid piece token"
end

run_test("rejects double letter") do
  Sashite::Feen::Parser::PiecePlacement.parse("KK")
  # This should parse as two pieces, not raise
  result = Sashite::Feen::Parser::PiecePlacement.parse("KK")
  raise "wrong count" unless result[:segments][0].size == 2
end

# ============================================================================
# RETURN STRUCTURE
# ============================================================================

puts
puts "Return structure:"

run_test("returns hash with :segments key") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("K")
  raise "missing :segments" unless result.key?(:segments)
end

run_test("returns hash with :separators key") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("K")
  raise "missing :separators" unless result.key?(:separators)
end

run_test(":segments is an Array") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("K")
  raise "wrong type" unless result[:segments].is_a?(Array)
end

run_test(":separators is an Array") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("K")
  raise "wrong type" unless result[:separators].is_a?(Array)
end

run_test("each segment is an Array") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("K/Q")
  result[:segments].each do |segment|
    raise "segment not Array" unless segment.is_a?(Array)
  end
end

run_test("empty counts are Integers") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("8")
  raise "wrong type" unless result[:segments][0][0].is_a?(Integer)
end

run_test("pieces are Epin::Identifier") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("K")
  raise "wrong type" unless result[:segments][0][0].is_a?(Sashite::Epin::Identifier)
end

run_test("separators are Strings") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("K/Q")
  raise "wrong type" unless result[:separators][0].is_a?(String)
end

# ============================================================================
# ERROR CLASS
# ============================================================================

puts
puts "Error class:"

run_test("raises Sashite::Feen::Errors::Argument") do
  Sashite::Feen::Parser::PiecePlacement.parse("")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument
  # Expected
end

run_test("error is rescuable as ArgumentError") do
  Sashite::Feen::Parser::PiecePlacement.parse("")
  raise "should have raised"
rescue ArgumentError
  # Expected
end

puts
puts "All Parser::PiecePlacement tests passed!"
puts
