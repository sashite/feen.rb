#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/parser/piece_placement"

puts
puts "=== PiecePlacement Parser Tests ==="
puts

# ============================================================================
# VALID INPUTS - SINGLE SEGMENT (1D BOARDS)
# ============================================================================

puts "Valid inputs - single segment (1D boards):"

run_test("parses 'K' (single piece)") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("K")
  raise "wrong segment count" unless result[:segments].size == 1
  raise "wrong token count" unless result[:segments][0].size == 1
  raise "wrong piece abbr" unless result[:segments][0][0].pin.abbr == :K
end

run_test("parses '8' (8 empty squares)") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("8")
  raise "wrong segment count" unless result[:segments].size == 1
  raise "wrong token" unless result[:segments][0][0] == 8
end

run_test("parses 'KQR' (3 pieces)") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("KQR")
  raise "wrong token count" unless result[:segments][0].size == 3
  raise "first piece wrong" unless result[:segments][0][0].pin.abbr == :K
  raise "second piece wrong" unless result[:segments][0][1].pin.abbr == :Q
  raise "third piece wrong" unless result[:segments][0][2].pin.abbr == :R
end

run_test("parses '3K2' (empty-piece-empty)") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("3K2")
  raise "wrong token count" unless result[:segments][0].size == 3
  raise "first token wrong" unless result[:segments][0][0] == 3
  raise "second token wrong" unless result[:segments][0][1].pin.abbr == :K
  raise "third token wrong" unless result[:segments][0][2] == 2
end

# ============================================================================
# VALID INPUTS - MULTIPLE SEGMENTS (2D BOARDS)
# ============================================================================

puts
puts "Valid inputs - multiple segments (2D boards):"

run_test("parses 'K/Q' (2 ranks)") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("K/Q")
  raise "wrong segment count" unless result[:segments].size == 2
  raise "wrong separator count" unless result[:separators].size == 1
  raise "first rank wrong" unless result[:segments][0][0].pin.abbr == :K
  raise "second rank wrong" unless result[:segments][1][0].pin.abbr == :Q
end

run_test("parses '8/8/8' (3 empty ranks)") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("8/8/8")
  raise "wrong segment count" unless result[:segments].size == 3
  raise "wrong separator count" unless result[:separators].size == 2
  raise "first rank wrong" unless result[:segments][0][0] == 8
  raise "second rank wrong" unless result[:segments][1][0] == 8
  raise "third rank wrong" unless result[:segments][2][0] == 8
end

run_test("parses standard chess initial position format") do
  input = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
  result = Sashite::Feen::Parser::PiecePlacement.parse(input)
  raise "wrong segment count" unless result[:segments].size == 8
  raise "wrong separator count" unless result[:separators].size == 7
  # First rank (black pieces)
  raise "wrong first piece" unless result[:segments][0][0].pin.abbr == :R
  raise "wrong first piece side" unless result[:segments][0][0].pin.side == :second
  # Last rank (white pieces)
  raise "wrong last piece" unless result[:segments][7][0].pin.abbr == :R
  raise "wrong last piece side" unless result[:segments][7][0].pin.side == :first
end

# ============================================================================
# VALID INPUTS - MULTI-DIMENSIONAL BOARDS (DOUBLE SEPARATORS)
# ============================================================================

puts
puts "Valid inputs - multi-dimensional boards:"

run_test("parses 'K//Q' (double separator for 3D)") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("K//Q")
  raise "wrong segment count" unless result[:segments].size == 2
  raise "wrong separator" unless result[:separators][0] == "//"
end

run_test("parses '8/8//8/8' (two 2D layers)") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("8/8//8/8")
  raise "wrong segment count" unless result[:segments].size == 4
  raise "wrong separator count" unless result[:separators].size == 3
  raise "first separator wrong" unless result[:separators][0] == "/"
  raise "second separator wrong" unless result[:separators][1] == "//"
  raise "third separator wrong" unless result[:separators][2] == "/"
end

run_test("parses 'K///Q' (triple separator for 4D)") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("K///Q")
  raise "wrong segment count" unless result[:segments].size == 2
  raise "wrong separator" unless result[:separators][0] == "///"
end

run_test("preserves separator structure") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("1/2//3/4///5")
  raise "wrong separator count" unless result[:separators].size == 4
  raise "sep 0 wrong" unless result[:separators][0] == "/"
  raise "sep 1 wrong" unless result[:separators][1] == "//"
  raise "sep 2 wrong" unless result[:separators][2] == "/"
  raise "sep 3 wrong" unless result[:separators][3] == "///"
end

# ============================================================================
# VALID INPUTS - EMPTY COUNTS
# ============================================================================

puts
puts "Valid inputs - empty counts:"

run_test("parses '1' (single empty)") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("1")
  raise "wrong token" unless result[:segments][0][0] == 1
end

run_test("parses '10' (double digit)") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("10")
  raise "wrong token" unless result[:segments][0][0] == 10
end

run_test("parses '100' (triple digit)") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("100")
  raise "wrong token" unless result[:segments][0][0] == 100
end

run_test("parses '255' (max 8-bit value)") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("255")
  raise "wrong token" unless result[:segments][0][0] == 255
end

# ============================================================================
# VALID INPUTS - EPIN MODIFIERS
# ============================================================================

puts
puts "Valid inputs - EPIN modifiers:"

run_test("parses '+K' (enhanced piece)") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("+K")
  raise "piece should be enhanced" unless result[:segments][0][0].pin.state == :enhanced
end

run_test("parses '-K' (diminished piece)") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("-K")
  raise "piece should be diminished" unless result[:segments][0][0].pin.state == :diminished
end

run_test("parses 'K^' (terminal piece)") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("K^")
  raise "piece should be terminal" unless result[:segments][0][0].pin.terminal?
end

run_test("parses \"K'\" (derived piece)") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("K'")
  raise "piece should be derived" unless result[:segments][0][0].derived?
end

run_test("parses \"+K^'\" (all modifiers)") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("+K^'")
  raise "piece should be enhanced" unless result[:segments][0][0].pin.state == :enhanced
  raise "piece should be terminal" unless result[:segments][0][0].pin.terminal?
  raise "piece should be derived" unless result[:segments][0][0].derived?
end

run_test("parses '3+K^2' (modifiers mixed with empties)") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("3+K^2")
  raise "wrong token count" unless result[:segments][0].size == 3
  raise "first token wrong" unless result[:segments][0][0] == 3
  raise "piece should be enhanced" unless result[:segments][0][1].pin.state == :enhanced
  raise "piece should be terminal" unless result[:segments][0][1].pin.terminal?
  raise "third token wrong" unless result[:segments][0][2] == 2
end

# ============================================================================
# VALID INPUTS - PIECE SIDES
# ============================================================================

puts
puts "Valid inputs - piece sides:"

run_test("parses 'K' (first player piece)") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("K")
  raise "piece should be first player" unless result[:segments][0][0].pin.side == :first
end

run_test("parses 'k' (second player piece)") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("k")
  raise "piece should be second player" unless result[:segments][0][0].pin.side == :second
end

run_test("parses 'Kk' (both sides adjacent)") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("Kk")
  raise "first piece wrong side" unless result[:segments][0][0].pin.side == :first
  raise "second piece wrong side" unless result[:segments][0][1].pin.side == :second
end

# ============================================================================
# VALID INPUTS - REALISTIC EXAMPLES
# ============================================================================

puts
puts "Valid inputs - realistic examples:"

run_test("parses Shogi initial position format") do
  input = "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL"
  result = Sashite::Feen::Parser::PiecePlacement.parse(input)
  raise "wrong segment count" unless result[:segments].size == 9
end

run_test("parses Xiangqi initial position format") do
  input = "rheagaehr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RHEAGAEHR"
  result = Sashite::Feen::Parser::PiecePlacement.parse(input)
  raise "wrong segment count" unless result[:segments].size == 10
end

run_test("parses Raumschach 3D format") do
  input = "5/5/5/5/5//5/5/2K2/5/5//5/5/5/5/5//5/5/2k2/5/5//5/5/5/5/5"
  result = Sashite::Feen::Parser::PiecePlacement.parse(input)
  raise "wrong segment count" unless result[:segments].size == 25
  # Should have 24 separators: 4 "//" and 20 "/"
  double_seps = result[:separators].count("//")
  single_seps = result[:separators].count("/")
  raise "wrong double separator count: #{double_seps}" unless double_seps == 4
  raise "wrong single separator count: #{single_seps}" unless single_seps == 20
end

# ============================================================================
# ERROR CASES - BOUNDARY VIOLATIONS
# ============================================================================

puts
puts "Error cases - boundary violations:"

run_test("raises on leading separator") do
  Sashite::Feen::Parser::PiecePlacement.parse("/K")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Feen::Errors::Argument::Messages::PIECE_PLACEMENT_STARTS_WITH_SEPARATOR
end

run_test("raises on trailing separator") do
  Sashite::Feen::Parser::PiecePlacement.parse("K/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Feen::Errors::Argument::Messages::PIECE_PLACEMENT_ENDS_WITH_SEPARATOR
end

run_test("raises on leading double separator") do
  Sashite::Feen::Parser::PiecePlacement.parse("//K")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Feen::Errors::Argument::Messages::PIECE_PLACEMENT_STARTS_WITH_SEPARATOR
end

run_test("raises on trailing double separator") do
  Sashite::Feen::Parser::PiecePlacement.parse("K//")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Feen::Errors::Argument::Messages::PIECE_PLACEMENT_ENDS_WITH_SEPARATOR
end

run_test("raises on empty string") do
  Sashite::Feen::Parser::PiecePlacement.parse("")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Feen::Errors::Argument::Messages::EMPTY_INPUT
end

run_test("raises on separator only") do
  Sashite::Feen::Parser::PiecePlacement.parse("/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Feen::Errors::Argument::Messages::PIECE_PLACEMENT_STARTS_WITH_SEPARATOR
end

# ============================================================================
# ERROR CASES - INVALID EMPTY COUNTS
# ============================================================================

puts
puts "Error cases - invalid empty counts:"

run_test("raises on '0' (zero not allowed)") do
  Sashite::Feen::Parser::PiecePlacement.parse("0")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Feen::Errors::Argument::Messages::INVALID_EMPTY_COUNT
end

run_test("raises on '01' (leading zero)") do
  Sashite::Feen::Parser::PiecePlacement.parse("01")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Feen::Errors::Argument::Messages::INVALID_EMPTY_COUNT
end

run_test("raises on '08' (leading zero)") do
  Sashite::Feen::Parser::PiecePlacement.parse("08")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Feen::Errors::Argument::Messages::INVALID_EMPTY_COUNT
end

run_test("raises on 'K0' (zero in segment)") do
  Sashite::Feen::Parser::PiecePlacement.parse("K0")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Feen::Errors::Argument::Messages::INVALID_EMPTY_COUNT
end

run_test("raises on '8/0/8' (zero in middle rank)") do
  Sashite::Feen::Parser::PiecePlacement.parse("8/0/8")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Feen::Errors::Argument::Messages::INVALID_EMPTY_COUNT
end

# ============================================================================
# ERROR CASES - INVALID EPIN TOKENS
# ============================================================================

puts
puts "Error cases - invalid EPIN tokens:"

run_test("raises on invalid character '!'") do
  Sashite::Feen::Parser::PiecePlacement.parse("K!")
  raise "should have raised"
rescue StandardError
  # Expected - EPIN parsing error
end

run_test("raises on double apostrophe") do
  Sashite::Feen::Parser::PiecePlacement.parse("K''")
  raise "should have raised"
rescue StandardError
  # Expected - EPIN parsing error
end

run_test("raises on space in input") do
  Sashite::Feen::Parser::PiecePlacement.parse("K Q")
  raise "should have raised"
rescue StandardError
  # Expected - space is field separator, not valid here
end

# ============================================================================
# SECURITY TESTS - CONTROL CHARACTERS
# ============================================================================

puts
puts "Security - control characters:"

run_test("rejects newline in input") do
  Sashite::Feen::Parser::PiecePlacement.parse("K\n")
  raise "should have raised"
rescue StandardError
  # Expected
end

run_test("rejects carriage return") do
  Sashite::Feen::Parser::PiecePlacement.parse("K\r")
  raise "should have raised"
rescue StandardError
  # Expected
end

run_test("rejects tab") do
  Sashite::Feen::Parser::PiecePlacement.parse("K\tQ")
  raise "should have raised"
rescue StandardError
  # Expected
end

run_test("rejects null byte") do
  Sashite::Feen::Parser::PiecePlacement.parse("K\x00")
  raise "should have raised"
rescue StandardError
  # Expected
end

# ============================================================================
# SECURITY TESTS - UNICODE
# ============================================================================

puts
puts "Security - Unicode:"

run_test("rejects Cyrillic lookalike") do
  # Cyrillic 'К' (U+041A) looks like Latin 'K'
  Sashite::Feen::Parser::PiecePlacement.parse("\xD0\x9A")
  raise "should have raised"
rescue StandardError
  # Expected
end

run_test("rejects full-width characters") do
  # Full-width 'K' (U+FF2B)
  Sashite::Feen::Parser::PiecePlacement.parse("\xEF\xBC\xAB")
  raise "should have raised"
rescue StandardError
  # Expected
end

# ============================================================================
# RETURN VALUE STRUCTURE
# ============================================================================

puts
puts "Return value structure:"

run_test("returns hash with :segments and :separators keys") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("K")
  raise "missing :segments key" unless result.key?(:segments)
  raise "missing :separators key" unless result.key?(:separators)
  raise "unexpected keys" unless result.keys.sort == [:segments, :separators].sort
end

run_test("segments is an Array of Arrays") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("K/Q")
  raise "segments should be Array" unless result[:segments].is_a?(Array)
  raise "segment should be Array" unless result[:segments][0].is_a?(Array)
end

run_test("separators is an Array of Strings") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("K/Q")
  raise "separators should be Array" unless result[:separators].is_a?(Array)
  raise "separator should be String" unless result[:separators][0].is_a?(String)
end

run_test("empty counts are Integers") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("8")
  raise "empty count should be Integer" unless result[:segments][0][0].is_a?(Integer)
end

run_test("pieces are EPIN Identifiers") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("K")
  raise "piece should be Epin::Identifier" unless result[:segments][0][0].is_a?(Sashite::Epin::Identifier)
end

run_test("separators array is one shorter than segments") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("K/Q/R")
  raise "wrong relationship" unless result[:separators].size == result[:segments].size - 1
end

run_test("single segment has empty separators array") do
  result = Sashite::Feen::Parser::PiecePlacement.parse("K")
  raise "separators should be empty" unless result[:separators].empty?
end

puts
puts "All PiecePlacement Parser tests passed!"
puts
