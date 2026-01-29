#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../helper"
require_relative "../../../lib/sashite/feen/errors"

puts
puts "=== Errors Tests ==="
puts

# ============================================================================
# GENERAL INPUT ERROR MESSAGES
# ============================================================================

puts "General input error messages:"

run_test("EMPTY_INPUT is defined") do
  raise "wrong value" unless Sashite::Feen::Errors::Argument::Messages::EMPTY_INPUT == "empty input"
end

run_test("INPUT_TOO_LONG is defined") do
  raise "wrong value" unless Sashite::Feen::Errors::Argument::Messages::INPUT_TOO_LONG == "input too long"
end

run_test("INVALID_FIELD_COUNT is defined") do
  raise "wrong value" unless Sashite::Feen::Errors::Argument::Messages::INVALID_FIELD_COUNT == "invalid field count"
end

run_test("CONTAINS_LINE_BREAKS is defined") do
  raise "wrong value" unless Sashite::Feen::Errors::Argument::Messages::CONTAINS_LINE_BREAKS == "input contains line breaks"
end

# ============================================================================
# PIECE PLACEMENT ERROR MESSAGES (FIELD 1)
# ============================================================================

puts
puts "Piece Placement error messages (Field 1):"

run_test("PIECE_PLACEMENT_STARTS_WITH_SEPARATOR is defined") do
  raise "wrong value" unless Sashite::Feen::Errors::Argument::Messages::PIECE_PLACEMENT_STARTS_WITH_SEPARATOR == "piece placement starts with separator"
end

run_test("PIECE_PLACEMENT_ENDS_WITH_SEPARATOR is defined") do
  raise "wrong value" unless Sashite::Feen::Errors::Argument::Messages::PIECE_PLACEMENT_ENDS_WITH_SEPARATOR == "piece placement ends with separator"
end

run_test("INVALID_EMPTY_COUNT is defined") do
  raise "wrong value" unless Sashite::Feen::Errors::Argument::Messages::INVALID_EMPTY_COUNT == "invalid empty count"
end

# ============================================================================
# HANDS ERROR MESSAGES (FIELD 2)
# ============================================================================

puts
puts "Hands error messages (Field 2):"

run_test("INVALID_HANDS_DELIMITER is defined") do
  raise "wrong value" unless Sashite::Feen::Errors::Argument::Messages::INVALID_HANDS_DELIMITER == "invalid hands delimiter"
end

run_test("INVALID_HAND_COUNT is defined") do
  raise "wrong value" unless Sashite::Feen::Errors::Argument::Messages::INVALID_HAND_COUNT == "invalid hand count"
end

run_test("NON_CANONICAL_HAND_ORDER is defined") do
  raise "wrong value" unless Sashite::Feen::Errors::Argument::Messages::NON_CANONICAL_HAND_ORDER == "hand items are not in canonical order"
end

# ============================================================================
# STYLE-TURN ERROR MESSAGES (FIELD 3)
# ============================================================================

puts
puts "Style-Turn error messages (Field 3):"

run_test("INVALID_STYLE_TURN_DELIMITER is defined") do
  raise "wrong value" unless Sashite::Feen::Errors::Argument::Messages::INVALID_STYLE_TURN_DELIMITER == "invalid style-turn delimiter"
end

run_test("STYLE_TOKENS_SAME_CASE is defined") do
  raise "wrong value" unless Sashite::Feen::Errors::Argument::Messages::STYLE_TOKENS_SAME_CASE == "style tokens must have opposite case"
end

# ============================================================================
# ERROR CLASS
# ============================================================================

puts
puts "Error class:"

run_test("Argument inherits from ArgumentError") do
  raise "wrong inheritance" unless Sashite::Feen::Errors::Argument < ArgumentError
end

run_test("Argument can be raised with message") do
  raise Sashite::Feen::Errors::Argument, Sashite::Feen::Errors::Argument::Messages::EMPTY_INPUT
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "empty input"
end

run_test("Argument can be rescued as ArgumentError") do
  raise Sashite::Feen::Errors::Argument, "test"
rescue ArgumentError => e
  raise "should be rescuable as ArgumentError" unless e.message == "test"
end

# ============================================================================
# ERROR MESSAGES ARE FROZEN
# ============================================================================

puts
puts "Immutability:"

run_test("EMPTY_INPUT is frozen") do
  raise "should be frozen" unless Sashite::Feen::Errors::Argument::Messages::EMPTY_INPUT.frozen?
end

run_test("INPUT_TOO_LONG is frozen") do
  raise "should be frozen" unless Sashite::Feen::Errors::Argument::Messages::INPUT_TOO_LONG.frozen?
end

run_test("INVALID_FIELD_COUNT is frozen") do
  raise "should be frozen" unless Sashite::Feen::Errors::Argument::Messages::INVALID_FIELD_COUNT.frozen?
end

run_test("CONTAINS_LINE_BREAKS is frozen") do
  raise "should be frozen" unless Sashite::Feen::Errors::Argument::Messages::CONTAINS_LINE_BREAKS.frozen?
end

run_test("PIECE_PLACEMENT_STARTS_WITH_SEPARATOR is frozen") do
  raise "should be frozen" unless Sashite::Feen::Errors::Argument::Messages::PIECE_PLACEMENT_STARTS_WITH_SEPARATOR.frozen?
end

run_test("PIECE_PLACEMENT_ENDS_WITH_SEPARATOR is frozen") do
  raise "should be frozen" unless Sashite::Feen::Errors::Argument::Messages::PIECE_PLACEMENT_ENDS_WITH_SEPARATOR.frozen?
end

run_test("INVALID_EMPTY_COUNT is frozen") do
  raise "should be frozen" unless Sashite::Feen::Errors::Argument::Messages::INVALID_EMPTY_COUNT.frozen?
end

run_test("INVALID_HANDS_DELIMITER is frozen") do
  raise "should be frozen" unless Sashite::Feen::Errors::Argument::Messages::INVALID_HANDS_DELIMITER.frozen?
end

run_test("INVALID_HAND_COUNT is frozen") do
  raise "should be frozen" unless Sashite::Feen::Errors::Argument::Messages::INVALID_HAND_COUNT.frozen?
end

run_test("NON_CANONICAL_HAND_ORDER is frozen") do
  raise "should be frozen" unless Sashite::Feen::Errors::Argument::Messages::NON_CANONICAL_HAND_ORDER.frozen?
end

run_test("INVALID_STYLE_TURN_DELIMITER is frozen") do
  raise "should be frozen" unless Sashite::Feen::Errors::Argument::Messages::INVALID_STYLE_TURN_DELIMITER.frozen?
end

run_test("STYLE_TOKENS_SAME_CASE is frozen") do
  raise "should be frozen" unless Sashite::Feen::Errors::Argument::Messages::STYLE_TOKENS_SAME_CASE.frozen?
end

puts
puts "All Errors tests passed!"
puts
