#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../helper"
require_relative "../../../lib/sashite/feen/parser"

puts
puts "=== Parser Tests ==="
puts

# ============================================================================
# VALID INPUTS - MINIMAL POSITIONS
# ============================================================================

puts "Valid inputs - minimal positions:"

run_test("parses minimal valid FEEN 'K / C/c'") do
  result = Sashite::Feen::Parser.parse("K / C/c")
  raise "missing piece_placement" unless result.key?(:piece_placement)
  raise "missing hands" unless result.key?(:hands)
  raise "missing style_turn" unless result.key?(:style_turn)
end

run_test("parses '8 / C/c' (empty board)") do
  result = Sashite::Feen::Parser.parse("8 / C/c")
  raise "wrong segment count" unless result[:piece_placement][:segments].size == 1
  raise "wrong empty count" unless result[:piece_placement][:segments][0][0] == 8
end

run_test("parses 'K P/ C/c' (piece in first hand)") do
  result = Sashite::Feen::Parser.parse("K P/ C/c")
  raise "first hand should have 1 item" unless result[:hands][:first].size == 1
end

run_test("parses 'K /p C/c' (piece in second hand)") do
  result = Sashite::Feen::Parser.parse("K /p C/c")
  raise "second hand should have 1 item" unless result[:hands][:second].size == 1
end

# ============================================================================
# VALID INPUTS - CHESS POSITIONS
# ============================================================================

puts
puts "Valid inputs - Chess positions:"

run_test("parses Chess initial position") do
  input = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c"
  result = Sashite::Feen::Parser.parse(input)
  raise "wrong segment count" unless result[:piece_placement][:segments].size == 8
  raise "hands should be empty" unless result[:hands][:first].empty?
  raise "hands should be empty" unless result[:hands][:second].empty?
  raise "wrong active style" unless result[:style_turn][:active].abbr == :C
  raise "wrong active side" unless result[:style_turn][:active].side == :first
end

run_test("parses Chess position with captures") do
  input = "r1bqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR N/ C/c"
  result = Sashite::Feen::Parser.parse(input)
  raise "first hand should have knight" unless result[:hands][:first][0][:piece].pin.abbr == :N
end

run_test("parses Chess position black to move") do
  input = "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR / c/C"
  result = Sashite::Feen::Parser.parse(input)
  raise "wrong active side" unless result[:style_turn][:active].side == :second
end

# ============================================================================
# VALID INPUTS - SHOGI POSITIONS
# ============================================================================

puts
puts "Valid inputs - Shogi positions:"

run_test("parses Shogi initial position") do
  input = "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s"
  result = Sashite::Feen::Parser.parse(input)
  raise "wrong segment count" unless result[:piece_placement][:segments].size == 9
  raise "wrong active style" unless result[:style_turn][:active].abbr == :S
end

run_test("parses Shogi position with pieces in hand") do
  input = "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL 2P/ S/s"
  result = Sashite::Feen::Parser.parse(input)
  raise "first hand wrong count" unless result[:hands][:first][0][:count] == 2
  raise "first hand wrong piece" unless result[:hands][:first][0][:piece].pin.abbr == :P
end

run_test("parses Shogi position with promoted pieces") do
  input = "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGK+PSNL / S/s"
  result = Sashite::Feen::Parser.parse(input)
  # Find the promoted piece in the last rank
  last_rank = result[:piece_placement][:segments][8]
  promoted = last_rank.find { |t| t.is_a?(Sashite::Epin::Identifier) && t.pin.state == :enhanced }
  raise "should have promoted piece" unless promoted
end

# ============================================================================
# VALID INPUTS - XIANGQI POSITIONS
# ============================================================================

puts
puts "Valid inputs - Xiangqi positions:"

run_test("parses Xiangqi initial position") do
  input = "rheagaehr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RHEAGAEHR / X/x"
  result = Sashite::Feen::Parser.parse(input)
  raise "wrong segment count" unless result[:piece_placement][:segments].size == 10
  raise "wrong active style" unless result[:style_turn][:active].abbr == :X
end

# ============================================================================
# VALID INPUTS - 3D BOARDS (RAUMSCHACH)
# ============================================================================

puts
puts "Valid inputs - 3D boards:"

run_test("parses 3D Raumschach position") do
  input = "5/5/5/5/5//5/5/2K2/5/5//5/5/5/5/5//5/5/2k2/5/5//5/5/5/5/5 / C/c"
  result = Sashite::Feen::Parser.parse(input)
  raise "wrong segment count" unless result[:piece_placement][:segments].size == 25
  # Verify double separators preserved
  double_seps = result[:piece_placement][:separators].count("//")
  raise "wrong double separator count" unless double_seps == 4
end

# ============================================================================
# VALID INPUTS - CROSS-STYLE GAMES
# ============================================================================

puts
puts "Valid inputs - cross-style games:"

run_test("parses Chess vs Shogi game") do
  input = "8/8/8/8/8/8/8/8 / C/s"
  result = Sashite::Feen::Parser.parse(input)
  raise "wrong active abbr" unless result[:style_turn][:active].abbr == :C
  raise "wrong inactive abbr" unless result[:style_turn][:inactive].abbr == :S
end

run_test("parses Shogi vs Chess, second to move") do
  input = "8/8/8/8/8/8/8/8 / s/C"
  result = Sashite::Feen::Parser.parse(input)
  raise "wrong active side" unless result[:style_turn][:active].side == :second
  raise "wrong inactive side" unless result[:style_turn][:inactive].side == :first
end

# ============================================================================
# VALID INPUTS - COMPLEX HANDS
# ============================================================================

puts
puts "Valid inputs - complex hands:"

run_test("parses position with multiple piece types in hands (canonical order)") do
  # Canonical order: 3B (count 3) before 2P (count 2) before N and R (count 1, alpha order)
  input = "8/8/8/8/8/8/8/8 3B2PNR/2pq C/c"
  result = Sashite::Feen::Parser.parse(input)
  raise "first hand wrong size" unless result[:hands][:first].size == 4
  raise "second hand wrong size" unless result[:hands][:second].size == 2
end

run_test("parses position with EPIN modifiers in hands") do
  input = "8/8/8/8/8/8/8/8 +P'/ C/c"
  result = Sashite::Feen::Parser.parse(input)
  piece = result[:hands][:first][0][:piece]
  raise "piece should be enhanced" unless piece.pin.state == :enhanced
  raise "piece should be derived" unless piece.derived?
end

# ============================================================================
# VALID? METHOD
# ============================================================================

puts
puts "valid? method:"

run_test("returns true for valid FEEN strings") do
  valid_inputs = [
    "K / C/c",
    "8 / C/c",
    "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c",
    "K P/ C/c",
    "K /p C/c",
    "K 3B2PN/n C/c"  # canonical order: 3B, 2P, N
  ]
  valid_inputs.each do |input|
    raise "#{input} should be valid" unless Sashite::Feen::Parser.valid?(input)
  end
end

run_test("returns false for invalid FEEN strings") do
  invalid_inputs = [
    "",
    "K",
    "K /",
    "K / C",
    "K / C/C",
    "/K / C/c",
    "K/ / C/c"
  ]
  invalid_inputs.each do |input|
    raise "#{input} should be invalid" if Sashite::Feen::Parser.valid?(input)
  end
end

run_test("returns false for nil") do
  raise "nil should be invalid" if Sashite::Feen::Parser.valid?(nil)
end

run_test("returns false for non-string") do
  raise "integer should be invalid" if Sashite::Feen::Parser.valid?(123)
  raise "symbol should be invalid" if Sashite::Feen::Parser.valid?(:feen)
  raise "array should be invalid" if Sashite::Feen::Parser.valid?([])
end

# ============================================================================
# ERROR CASES - EMPTY INPUT
# ============================================================================

puts
puts "Error cases - empty input:"

run_test("raises on empty string") do
  Sashite::Feen::Parser.parse("")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Feen::Errors::Argument::Messages::EMPTY_INPUT
end

# ============================================================================
# ERROR CASES - INPUT TOO LONG
# ============================================================================

puts
puts "Error cases - input too long:"

run_test("raises on input exceeding max length") do
  long_input = "K" + "8/" * 2500 + "8 / C/c"
  Sashite::Feen::Parser.parse(long_input)
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Feen::Errors::Argument::Messages::INPUT_TOO_LONG
end

# ============================================================================
# ERROR CASES - LINE BREAKS (EXPLICIT VALIDATION)
# ============================================================================

puts
puts "Error cases - line breaks:"

run_test("raises CONTAINS_LINE_BREAKS on newline at end") do
  Sashite::Feen::Parser.parse("K / C/c\n")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message: #{e.message}" unless e.message == Sashite::Feen::Errors::Argument::Messages::CONTAINS_LINE_BREAKS
end

run_test("raises CONTAINS_LINE_BREAKS on newline at start") do
  Sashite::Feen::Parser.parse("\nK / C/c")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message: #{e.message}" unless e.message == Sashite::Feen::Errors::Argument::Messages::CONTAINS_LINE_BREAKS
end

run_test("raises CONTAINS_LINE_BREAKS on newline in piece placement") do
  Sashite::Feen::Parser.parse("K\n8 / C/c")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message: #{e.message}" unless e.message == Sashite::Feen::Errors::Argument::Messages::CONTAINS_LINE_BREAKS
end

run_test("raises CONTAINS_LINE_BREAKS on newline in hands") do
  Sashite::Feen::Parser.parse("K P\n/ C/c")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message: #{e.message}" unless e.message == Sashite::Feen::Errors::Argument::Messages::CONTAINS_LINE_BREAKS
end

run_test("raises CONTAINS_LINE_BREAKS on newline in style-turn") do
  Sashite::Feen::Parser.parse("K / C\n/c")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message: #{e.message}" unless e.message == Sashite::Feen::Errors::Argument::Messages::CONTAINS_LINE_BREAKS
end

run_test("raises CONTAINS_LINE_BREAKS on carriage return") do
  Sashite::Feen::Parser.parse("K / C/c\r")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message: #{e.message}" unless e.message == Sashite::Feen::Errors::Argument::Messages::CONTAINS_LINE_BREAKS
end

run_test("raises CONTAINS_LINE_BREAKS on CRLF") do
  Sashite::Feen::Parser.parse("K / C/c\r\n")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message: #{e.message}" unless e.message == Sashite::Feen::Errors::Argument::Messages::CONTAINS_LINE_BREAKS
end

run_test("raises CONTAINS_LINE_BREAKS on multiple newlines") do
  Sashite::Feen::Parser.parse("K\n/\n8 / C/c")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message: #{e.message}" unless e.message == Sashite::Feen::Errors::Argument::Messages::CONTAINS_LINE_BREAKS
end

# ============================================================================
# ERROR CASES - INVALID FIELD COUNT
# ============================================================================

puts
puts "Error cases - invalid field count:"

run_test("raises on single field") do
  Sashite::Feen::Parser.parse("K")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Feen::Errors::Argument::Messages::INVALID_FIELD_COUNT
end

run_test("raises on two fields") do
  Sashite::Feen::Parser.parse("K /")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Feen::Errors::Argument::Messages::INVALID_FIELD_COUNT
end

run_test("raises on four fields") do
  Sashite::Feen::Parser.parse("K / C/c extra")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Feen::Errors::Argument::Messages::INVALID_FIELD_COUNT
end

# ============================================================================
# ERROR CASES - FIELD 1 ERRORS (PIECE PLACEMENT)
# ============================================================================

puts
puts "Error cases - Field 1 (Piece Placement):"

run_test("raises on leading separator in piece placement") do
  Sashite::Feen::Parser.parse("/K / C/c")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Feen::Errors::Argument::Messages::PIECE_PLACEMENT_STARTS_WITH_SEPARATOR
end

run_test("raises on trailing separator in piece placement") do
  Sashite::Feen::Parser.parse("K/ / C/c")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Feen::Errors::Argument::Messages::PIECE_PLACEMENT_ENDS_WITH_SEPARATOR
end

run_test("raises on zero in piece placement") do
  Sashite::Feen::Parser.parse("0 / C/c")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Feen::Errors::Argument::Messages::INVALID_EMPTY_COUNT
end

# ============================================================================
# ERROR CASES - FIELD 2 ERRORS (HANDS)
# ============================================================================

puts
puts "Error cases - Field 2 (Hands):"

run_test("raises on missing delimiter in hands") do
  Sashite::Feen::Parser.parse("K PP C/c")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Feen::Errors::Argument::Messages::INVALID_HANDS_DELIMITER
end

run_test("raises on invalid count in hands") do
  Sashite::Feen::Parser.parse("K 1P/ C/c")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Feen::Errors::Argument::Messages::INVALID_HAND_COUNT
end

# ============================================================================
# ERROR CASES - FIELD 3 ERRORS (STYLE-TURN)
# ============================================================================

puts
puts "Error cases - Field 3 (Style-Turn):"

run_test("raises on missing delimiter in style-turn") do
  Sashite::Feen::Parser.parse("K / Cc")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Feen::Errors::Argument::Messages::INVALID_STYLE_TURN_DELIMITER
end

run_test("raises on same case in style-turn") do
  Sashite::Feen::Parser.parse("K / C/S")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Feen::Errors::Argument::Messages::STYLE_TOKENS_SAME_CASE
end

# ============================================================================
# SECURITY TESTS - CONTROL CHARACTERS (OTHER THAN LINE BREAKS)
# ============================================================================

puts
puts "Security - control characters (other than line breaks):"

run_test("rejects tab") do
  Sashite::Feen::Parser.parse("K\t/ C/c")
  raise "should have raised"
rescue StandardError
  # Expected - tab is not a valid character
end

run_test("rejects null byte") do
  Sashite::Feen::Parser.parse("K\x00 / C/c")
  raise "should have raised"
rescue StandardError
  # Expected
end

# ============================================================================
# SECURITY TESTS - UNICODE
# ============================================================================

puts
puts "Security - Unicode:"

run_test("rejects Cyrillic lookalikes") do
  # Cyrillic 'К' looks like Latin 'K'
  Sashite::Feen::Parser.parse("\xD0\x9A / C/c")
  raise "should have raised"
rescue StandardError
  # Expected
end

run_test("rejects full-width characters") do
  Sashite::Feen::Parser.parse("\xEF\xBC\xAB / C/c")
  raise "should have raised"
rescue StandardError
  # Expected
end

# ============================================================================
# RETURN VALUE STRUCTURE
# ============================================================================

puts
puts "Return value structure:"

run_test("returns hash with three top-level keys") do
  result = Sashite::Feen::Parser.parse("K / C/c")
  raise "missing piece_placement" unless result.key?(:piece_placement)
  raise "missing hands" unless result.key?(:hands)
  raise "missing style_turn" unless result.key?(:style_turn)
  raise "unexpected keys" unless result.keys.sort == [:hands, :piece_placement, :style_turn].sort
end

run_test("piece_placement has correct structure") do
  result = Sashite::Feen::Parser.parse("K/Q / C/c")
  pp = result[:piece_placement]
  raise "missing segments" unless pp.key?(:segments)
  raise "missing separators" unless pp.key?(:separators)
  raise "segments wrong type" unless pp[:segments].is_a?(Array)
  raise "separators wrong type" unless pp[:separators].is_a?(Array)
end

run_test("hands has correct structure") do
  result = Sashite::Feen::Parser.parse("K P/p C/c")
  hands = result[:hands]
  raise "missing first" unless hands.key?(:first)
  raise "missing second" unless hands.key?(:second)
  raise "first wrong type" unless hands[:first].is_a?(Array)
  raise "second wrong type" unless hands[:second].is_a?(Array)
end

run_test("style_turn has correct structure") do
  result = Sashite::Feen::Parser.parse("K / C/c")
  st = result[:style_turn]
  raise "missing active" unless st.key?(:active)
  raise "missing inactive" unless st.key?(:inactive)
  raise "active wrong type" unless st[:active].is_a?(Sashite::Sin::Identifier)
  raise "inactive wrong type" unless st[:inactive].is_a?(Sashite::Sin::Identifier)
end

puts
puts "All Parser tests passed!"
puts
