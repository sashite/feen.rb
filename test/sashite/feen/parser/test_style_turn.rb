#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/parser/style_turn"

puts
puts "=== StyleTurn Parser Tests ==="
puts

# ============================================================================
# VALID INPUTS - FIRST PLAYER ACTIVE
# ============================================================================

puts "Valid inputs - first player active:"

run_test("parses 'C/c' (Chess, first to move)") do
  result = Sashite::Feen::Parser::StyleTurn.parse("C/c")
  raise "wrong active abbr" unless result[:active].abbr == :C
  raise "wrong active side" unless result[:active].side == :first
  raise "wrong inactive abbr" unless result[:inactive].abbr == :C
  raise "wrong inactive side" unless result[:inactive].side == :second
end

run_test("parses 'S/s' (Shogi, first to move)") do
  result = Sashite::Feen::Parser::StyleTurn.parse("S/s")
  raise "wrong active abbr" unless result[:active].abbr == :S
  raise "wrong active side" unless result[:active].side == :first
  raise "wrong inactive abbr" unless result[:inactive].abbr == :S
  raise "wrong inactive side" unless result[:inactive].side == :second
end

run_test("parses 'X/x' (Xiangqi, first to move)") do
  result = Sashite::Feen::Parser::StyleTurn.parse("X/x")
  raise "wrong active abbr" unless result[:active].abbr == :X
  raise "wrong active side" unless result[:active].side == :first
  raise "wrong inactive abbr" unless result[:inactive].abbr == :X
  raise "wrong inactive side" unless result[:inactive].side == :second
end

# ============================================================================
# VALID INPUTS - SECOND PLAYER ACTIVE
# ============================================================================

puts
puts "Valid inputs - second player active:"

run_test("parses 'c/C' (Chess, second to move)") do
  result = Sashite::Feen::Parser::StyleTurn.parse("c/C")
  raise "wrong active abbr" unless result[:active].abbr == :C
  raise "wrong active side" unless result[:active].side == :second
  raise "wrong inactive abbr" unless result[:inactive].abbr == :C
  raise "wrong inactive side" unless result[:inactive].side == :first
end

run_test("parses 's/S' (Shogi, second to move)") do
  result = Sashite::Feen::Parser::StyleTurn.parse("s/S")
  raise "wrong active abbr" unless result[:active].abbr == :S
  raise "wrong active side" unless result[:active].side == :second
  raise "wrong inactive abbr" unless result[:inactive].abbr == :S
  raise "wrong inactive side" unless result[:inactive].side == :first
end

# ============================================================================
# VALID INPUTS - DIFFERENT STYLES (CROSS-STYLE GAMES)
# ============================================================================

puts
puts "Valid inputs - cross-style games:"

run_test("parses 'C/s' (Chess vs Shogi, first to move)") do
  result = Sashite::Feen::Parser::StyleTurn.parse("C/s")
  raise "wrong active abbr" unless result[:active].abbr == :C
  raise "wrong active side" unless result[:active].side == :first
  raise "wrong inactive abbr" unless result[:inactive].abbr == :S
  raise "wrong inactive side" unless result[:inactive].side == :second
end

run_test("parses 's/C' (Shogi vs Chess, second to move)") do
  result = Sashite::Feen::Parser::StyleTurn.parse("s/C")
  raise "wrong active abbr" unless result[:active].abbr == :S
  raise "wrong active side" unless result[:active].side == :second
  raise "wrong inactive abbr" unless result[:inactive].abbr == :C
  raise "wrong inactive side" unless result[:inactive].side == :first
end

run_test("parses 'M/x' (Makruk vs Xiangqi)") do
  result = Sashite::Feen::Parser::StyleTurn.parse("M/x")
  raise "wrong active abbr" unless result[:active].abbr == :M
  raise "wrong inactive abbr" unless result[:inactive].abbr == :X
end

# ============================================================================
# VALID INPUTS - ALL LETTERS
# ============================================================================

puts
puts "Valid inputs - all letters:"

run_test("parses all uppercase/lowercase pairs A-Z") do
  ("A".."Z").each do |letter|
    input = "#{letter}/#{letter.downcase}"
    result = Sashite::Feen::Parser::StyleTurn.parse(input)
    raise "wrong active abbr for #{input}" unless result[:active].abbr == letter.to_sym
    raise "wrong active side for #{input}" unless result[:active].side == :first
    raise "wrong inactive side for #{input}" unless result[:inactive].side == :second
  end
end

run_test("parses all lowercase/uppercase pairs a-z") do
  ("a".."z").each do |letter|
    input = "#{letter}/#{letter.upcase}"
    result = Sashite::Feen::Parser::StyleTurn.parse(input)
    raise "wrong active abbr for #{input}" unless result[:active].abbr == letter.upcase.to_sym
    raise "wrong active side for #{input}" unless result[:active].side == :second
    raise "wrong inactive side for #{input}" unless result[:inactive].side == :first
  end
end

# ============================================================================
# ERROR CASES - INVALID DELIMITER
# ============================================================================

puts
puts "Error cases - invalid delimiter:"

run_test("raises on missing delimiter") do
  Sashite::Feen::Parser::StyleTurn.parse("Cc")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Feen::Errors::Argument::Messages::INVALID_STYLE_TURN_DELIMITER
end

run_test("raises on multiple delimiters") do
  Sashite::Feen::Parser::StyleTurn.parse("C/c/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Feen::Errors::Argument::Messages::INVALID_STYLE_TURN_DELIMITER
end

run_test("raises on empty string") do
  Sashite::Feen::Parser::StyleTurn.parse("")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Feen::Errors::Argument::Messages::INVALID_STYLE_TURN_DELIMITER
end

run_test("raises on delimiter only") do
  Sashite::Feen::Parser::StyleTurn.parse("/")
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument
  # Expected - SIN parser rejects empty string
end

# ============================================================================
# ERROR CASES - SAME CASE
# ============================================================================

puts
puts "Error cases - same case:"

run_test("raises on both uppercase 'C/S'") do
  Sashite::Feen::Parser::StyleTurn.parse("C/S")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Feen::Errors::Argument::Messages::STYLE_TOKENS_SAME_CASE
end

run_test("raises on both lowercase 'c/s'") do
  Sashite::Feen::Parser::StyleTurn.parse("c/s")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Feen::Errors::Argument::Messages::STYLE_TOKENS_SAME_CASE
end

run_test("raises on same letter both uppercase 'C/C'") do
  Sashite::Feen::Parser::StyleTurn.parse("C/C")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Feen::Errors::Argument::Messages::STYLE_TOKENS_SAME_CASE
end

run_test("raises on same letter both lowercase 'c/c'") do
  Sashite::Feen::Parser::StyleTurn.parse("c/c")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Feen::Errors::Argument::Messages::STYLE_TOKENS_SAME_CASE
end

# ============================================================================
# ERROR CASES - INVALID SIN TOKENS
# ============================================================================

puts
puts "Error cases - invalid SIN tokens:"

run_test("raises on digit in active position") do
  Sashite::Feen::Parser::StyleTurn.parse("1/c")
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument
  # Expected - delegated to SIN
end

run_test("raises on digit in inactive position") do
  Sashite::Feen::Parser::StyleTurn.parse("C/1")
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument
  # Expected - delegated to SIN
end

run_test("raises on multiple letters in active position") do
  Sashite::Feen::Parser::StyleTurn.parse("CC/c")
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument
  # Expected - delegated to SIN
end

run_test("raises on multiple letters in inactive position") do
  Sashite::Feen::Parser::StyleTurn.parse("C/cc")
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument
  # Expected - delegated to SIN
end

run_test("raises on empty active position") do
  Sashite::Feen::Parser::StyleTurn.parse("/c")
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument
  # Expected - delegated to SIN
end

run_test("raises on empty inactive position") do
  Sashite::Feen::Parser::StyleTurn.parse("C/")
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument
  # Expected - delegated to SIN
end

# ============================================================================
# SECURITY TESTS - CONTROL CHARACTERS
# ============================================================================

puts
puts "Security - control characters:"

run_test("rejects newline in input") do
  Sashite::Feen::Parser::StyleTurn.parse("C/c\n")
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument
  # Expected
end

run_test("rejects carriage return in input") do
  Sashite::Feen::Parser::StyleTurn.parse("C\r/c")
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument
  # Expected
end

run_test("rejects tab in input") do
  Sashite::Feen::Parser::StyleTurn.parse("C/\tc")
  raise "should have raised"
rescue StandardError
  # Expected - wrong delimiter count or SIN error
end

run_test("rejects null byte") do
  Sashite::Feen::Parser::StyleTurn.parse("C/c\x00")
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument
  # Expected
end

# ============================================================================
# SECURITY TESTS - UNICODE
# ============================================================================

puts
puts "Security - Unicode:"

run_test("rejects Cyrillic lookalike") do
  # Cyrillic 'С' (U+0421) looks like Latin 'C'
  Sashite::Feen::Parser::StyleTurn.parse("\xD0\xA1/c")
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument
  # Expected
end

run_test("rejects full-width characters") do
  # Full-width 'C' (U+FF23)
  Sashite::Feen::Parser::StyleTurn.parse("\xEF\xBC\xA3/c")
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument
  # Expected
end

run_test("rejects zero-width characters") do
  # Zero-width space (U+200B)
  Sashite::Feen::Parser::StyleTurn.parse("C\xE2\x80\x8B/c")
  raise "should have raised"
rescue Sashite::Sin::Errors::Argument
  # Expected
end

# ============================================================================
# RETURN VALUE STRUCTURE
# ============================================================================

puts
puts "Return value structure:"

run_test("returns hash with :active and :inactive keys") do
  result = Sashite::Feen::Parser::StyleTurn.parse("C/c")
  raise "missing :active key" unless result.key?(:active)
  raise "missing :inactive key" unless result.key?(:inactive)
  raise "unexpected keys" unless result.keys.sort == [:active, :inactive].sort
end

run_test("returns SIN Identifier objects") do
  result = Sashite::Feen::Parser::StyleTurn.parse("C/c")
  raise "active should be Sin::Identifier" unless result[:active].is_a?(Sashite::Sin::Identifier)
  raise "inactive should be Sin::Identifier" unless result[:inactive].is_a?(Sashite::Sin::Identifier)
end

puts
puts "All StyleTurn Parser tests passed!"
puts
