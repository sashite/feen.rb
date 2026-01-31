#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../../helper"
require_relative "../../../../../lib/sashite/feen/errors/argument/messages"

puts
puts "=== Errors::Argument::Messages Tests ==="
puts

# ============================================================================
# GENERAL INPUT ERROR MESSAGES
# ============================================================================

puts "General input error messages:"

run_test("INPUT_TOO_LONG is defined") do
  raise "not defined" unless defined?(Sashite::Feen::Errors::Argument::Messages::INPUT_TOO_LONG)
end

run_test("INPUT_TOO_LONG has correct value") do
  raise "wrong value" unless Sashite::Feen::Errors::Argument::Messages::INPUT_TOO_LONG == "input exceeds 4096 characters"
end

run_test("INPUT_TOO_LONG is frozen") do
  raise "should be frozen" unless Sashite::Feen::Errors::Argument::Messages::INPUT_TOO_LONG.frozen?
end

run_test("INVALID_FIELD_COUNT is defined") do
  raise "not defined" unless defined?(Sashite::Feen::Errors::Argument::Messages::INVALID_FIELD_COUNT)
end

run_test("INVALID_FIELD_COUNT has correct value") do
  raise "wrong value" unless Sashite::Feen::Errors::Argument::Messages::INVALID_FIELD_COUNT == "invalid field count"
end

run_test("INVALID_FIELD_COUNT is frozen") do
  raise "should be frozen" unless Sashite::Feen::Errors::Argument::Messages::INVALID_FIELD_COUNT.frozen?
end

# ============================================================================
# PIECE PLACEMENT ERROR MESSAGES (FIELD 1)
# ============================================================================

puts
puts "Piece Placement error messages (Field 1):"

run_test("PIECE_PLACEMENT_EMPTY is defined") do
  raise "not defined" unless defined?(Sashite::Feen::Errors::Argument::Messages::PIECE_PLACEMENT_EMPTY)
end

run_test("PIECE_PLACEMENT_EMPTY has correct value") do
  raise "wrong value" unless Sashite::Feen::Errors::Argument::Messages::PIECE_PLACEMENT_EMPTY == "piece placement is empty"
end

run_test("PIECE_PLACEMENT_EMPTY is frozen") do
  raise "should be frozen" unless Sashite::Feen::Errors::Argument::Messages::PIECE_PLACEMENT_EMPTY.frozen?
end

run_test("PIECE_PLACEMENT_STARTS_WITH_SEPARATOR is defined") do
  raise "not defined" unless defined?(Sashite::Feen::Errors::Argument::Messages::PIECE_PLACEMENT_STARTS_WITH_SEPARATOR)
end

run_test("PIECE_PLACEMENT_STARTS_WITH_SEPARATOR has correct value") do
  raise "wrong value" unless Sashite::Feen::Errors::Argument::Messages::PIECE_PLACEMENT_STARTS_WITH_SEPARATOR == "piece placement starts with separator"
end

run_test("PIECE_PLACEMENT_STARTS_WITH_SEPARATOR is frozen") do
  raise "should be frozen" unless Sashite::Feen::Errors::Argument::Messages::PIECE_PLACEMENT_STARTS_WITH_SEPARATOR.frozen?
end

run_test("PIECE_PLACEMENT_ENDS_WITH_SEPARATOR is defined") do
  raise "not defined" unless defined?(Sashite::Feen::Errors::Argument::Messages::PIECE_PLACEMENT_ENDS_WITH_SEPARATOR)
end

run_test("PIECE_PLACEMENT_ENDS_WITH_SEPARATOR has correct value") do
  raise "wrong value" unless Sashite::Feen::Errors::Argument::Messages::PIECE_PLACEMENT_ENDS_WITH_SEPARATOR == "piece placement ends with separator"
end

run_test("PIECE_PLACEMENT_ENDS_WITH_SEPARATOR is frozen") do
  raise "should be frozen" unless Sashite::Feen::Errors::Argument::Messages::PIECE_PLACEMENT_ENDS_WITH_SEPARATOR.frozen?
end

run_test("EMPTY_SEGMENT is defined") do
  raise "not defined" unless defined?(Sashite::Feen::Errors::Argument::Messages::EMPTY_SEGMENT)
end

run_test("EMPTY_SEGMENT has correct value") do
  raise "wrong value" unless Sashite::Feen::Errors::Argument::Messages::EMPTY_SEGMENT == "empty segment"
end

run_test("EMPTY_SEGMENT is frozen") do
  raise "should be frozen" unless Sashite::Feen::Errors::Argument::Messages::EMPTY_SEGMENT.frozen?
end

run_test("INVALID_EMPTY_COUNT is defined") do
  raise "not defined" unless defined?(Sashite::Feen::Errors::Argument::Messages::INVALID_EMPTY_COUNT)
end

run_test("INVALID_EMPTY_COUNT has correct value") do
  raise "wrong value" unless Sashite::Feen::Errors::Argument::Messages::INVALID_EMPTY_COUNT == "invalid empty count"
end

run_test("INVALID_EMPTY_COUNT is frozen") do
  raise "should be frozen" unless Sashite::Feen::Errors::Argument::Messages::INVALID_EMPTY_COUNT.frozen?
end

run_test("INVALID_PIECE_TOKEN is defined") do
  raise "not defined" unless defined?(Sashite::Feen::Errors::Argument::Messages::INVALID_PIECE_TOKEN)
end

run_test("INVALID_PIECE_TOKEN has correct value") do
  raise "wrong value" unless Sashite::Feen::Errors::Argument::Messages::INVALID_PIECE_TOKEN == "invalid piece token"
end

run_test("INVALID_PIECE_TOKEN is frozen") do
  raise "should be frozen" unless Sashite::Feen::Errors::Argument::Messages::INVALID_PIECE_TOKEN.frozen?
end

run_test("CONSECUTIVE_EMPTY_COUNTS is defined") do
  raise "not defined" unless defined?(Sashite::Feen::Errors::Argument::Messages::CONSECUTIVE_EMPTY_COUNTS)
end

run_test("CONSECUTIVE_EMPTY_COUNTS has correct value") do
  raise "wrong value" unless Sashite::Feen::Errors::Argument::Messages::CONSECUTIVE_EMPTY_COUNTS == "consecutive empty counts must be merged"
end

run_test("CONSECUTIVE_EMPTY_COUNTS is frozen") do
  raise "should be frozen" unless Sashite::Feen::Errors::Argument::Messages::CONSECUTIVE_EMPTY_COUNTS.frozen?
end

run_test("DIMENSIONAL_COHERENCE_VIOLATION is defined") do
  raise "not defined" unless defined?(Sashite::Feen::Errors::Argument::Messages::DIMENSIONAL_COHERENCE_VIOLATION)
end

run_test("DIMENSIONAL_COHERENCE_VIOLATION has correct value") do
  raise "wrong value" unless Sashite::Feen::Errors::Argument::Messages::DIMENSIONAL_COHERENCE_VIOLATION == "dimensional coherence violation"
end

run_test("DIMENSIONAL_COHERENCE_VIOLATION is frozen") do
  raise "should be frozen" unless Sashite::Feen::Errors::Argument::Messages::DIMENSIONAL_COHERENCE_VIOLATION.frozen?
end

run_test("EXCEEDS_MAX_DIMENSIONS is defined") do
  raise "not defined" unless defined?(Sashite::Feen::Errors::Argument::Messages::EXCEEDS_MAX_DIMENSIONS)
end

run_test("EXCEEDS_MAX_DIMENSIONS has correct value") do
  raise "wrong value" unless Sashite::Feen::Errors::Argument::Messages::EXCEEDS_MAX_DIMENSIONS == "exceeds 3 dimensions"
end

run_test("EXCEEDS_MAX_DIMENSIONS is frozen") do
  raise "should be frozen" unless Sashite::Feen::Errors::Argument::Messages::EXCEEDS_MAX_DIMENSIONS.frozen?
end

run_test("DIMENSION_SIZE_EXCEEDED is defined") do
  raise "not defined" unless defined?(Sashite::Feen::Errors::Argument::Messages::DIMENSION_SIZE_EXCEEDED)
end

run_test("DIMENSION_SIZE_EXCEEDED has correct value") do
  raise "wrong value" unless Sashite::Feen::Errors::Argument::Messages::DIMENSION_SIZE_EXCEEDED == "dimension size exceeds 255"
end

run_test("DIMENSION_SIZE_EXCEEDED is frozen") do
  raise "should be frozen" unless Sashite::Feen::Errors::Argument::Messages::DIMENSION_SIZE_EXCEEDED.frozen?
end

# ============================================================================
# HANDS ERROR MESSAGES (FIELD 2)
# ============================================================================

puts
puts "Hands error messages (Field 2):"

run_test("INVALID_HANDS_DELIMITER is defined") do
  raise "not defined" unless defined?(Sashite::Feen::Errors::Argument::Messages::INVALID_HANDS_DELIMITER)
end

run_test("INVALID_HANDS_DELIMITER has correct value") do
  raise "wrong value" unless Sashite::Feen::Errors::Argument::Messages::INVALID_HANDS_DELIMITER == "invalid hands delimiter"
end

run_test("INVALID_HANDS_DELIMITER is frozen") do
  raise "should be frozen" unless Sashite::Feen::Errors::Argument::Messages::INVALID_HANDS_DELIMITER.frozen?
end

run_test("INVALID_HAND_COUNT is defined") do
  raise "not defined" unless defined?(Sashite::Feen::Errors::Argument::Messages::INVALID_HAND_COUNT)
end

run_test("INVALID_HAND_COUNT has correct value") do
  raise "wrong value" unless Sashite::Feen::Errors::Argument::Messages::INVALID_HAND_COUNT == "invalid hand count"
end

run_test("INVALID_HAND_COUNT is frozen") do
  raise "should be frozen" unless Sashite::Feen::Errors::Argument::Messages::INVALID_HAND_COUNT.frozen?
end

run_test("HAND_ITEMS_NOT_AGGREGATED is defined") do
  raise "not defined" unless defined?(Sashite::Feen::Errors::Argument::Messages::HAND_ITEMS_NOT_AGGREGATED)
end

run_test("HAND_ITEMS_NOT_AGGREGATED has correct value") do
  raise "wrong value" unless Sashite::Feen::Errors::Argument::Messages::HAND_ITEMS_NOT_AGGREGATED == "hand items not aggregated"
end

run_test("HAND_ITEMS_NOT_AGGREGATED is frozen") do
  raise "should be frozen" unless Sashite::Feen::Errors::Argument::Messages::HAND_ITEMS_NOT_AGGREGATED.frozen?
end

run_test("HAND_ITEMS_NOT_CANONICAL is defined") do
  raise "not defined" unless defined?(Sashite::Feen::Errors::Argument::Messages::HAND_ITEMS_NOT_CANONICAL)
end

run_test("HAND_ITEMS_NOT_CANONICAL has correct value") do
  raise "wrong value" unless Sashite::Feen::Errors::Argument::Messages::HAND_ITEMS_NOT_CANONICAL == "hand items not in canonical order"
end

run_test("HAND_ITEMS_NOT_CANONICAL is frozen") do
  raise "should be frozen" unless Sashite::Feen::Errors::Argument::Messages::HAND_ITEMS_NOT_CANONICAL.frozen?
end

# ============================================================================
# STYLE-TURN ERROR MESSAGES (FIELD 3)
# ============================================================================

puts
puts "Style-Turn error messages (Field 3):"

run_test("INVALID_STYLE_TURN_DELIMITER is defined") do
  raise "not defined" unless defined?(Sashite::Feen::Errors::Argument::Messages::INVALID_STYLE_TURN_DELIMITER)
end

run_test("INVALID_STYLE_TURN_DELIMITER has correct value") do
  raise "wrong value" unless Sashite::Feen::Errors::Argument::Messages::INVALID_STYLE_TURN_DELIMITER == "invalid style-turn delimiter"
end

run_test("INVALID_STYLE_TURN_DELIMITER is frozen") do
  raise "should be frozen" unless Sashite::Feen::Errors::Argument::Messages::INVALID_STYLE_TURN_DELIMITER.frozen?
end

run_test("INVALID_STYLE_TOKEN is defined") do
  raise "not defined" unless defined?(Sashite::Feen::Errors::Argument::Messages::INVALID_STYLE_TOKEN)
end

run_test("INVALID_STYLE_TOKEN has correct value") do
  raise "wrong value" unless Sashite::Feen::Errors::Argument::Messages::INVALID_STYLE_TOKEN == "invalid style token"
end

run_test("INVALID_STYLE_TOKEN is frozen") do
  raise "should be frozen" unless Sashite::Feen::Errors::Argument::Messages::INVALID_STYLE_TOKEN.frozen?
end

run_test("STYLE_TOKENS_SAME_CASE is defined") do
  raise "not defined" unless defined?(Sashite::Feen::Errors::Argument::Messages::STYLE_TOKENS_SAME_CASE)
end

run_test("STYLE_TOKENS_SAME_CASE has correct value") do
  raise "wrong value" unless Sashite::Feen::Errors::Argument::Messages::STYLE_TOKENS_SAME_CASE == "style tokens must have opposite case"
end

run_test("STYLE_TOKENS_SAME_CASE is frozen") do
  raise "should be frozen" unless Sashite::Feen::Errors::Argument::Messages::STYLE_TOKENS_SAME_CASE.frozen?
end

# ============================================================================
# CROSS-FIELD VALIDATION ERROR MESSAGES
# ============================================================================

puts
puts "Cross-field validation error messages:"

run_test("TOO_MANY_PIECES is defined") do
  raise "not defined" unless defined?(Sashite::Feen::Errors::Argument::Messages::TOO_MANY_PIECES)
end

run_test("TOO_MANY_PIECES has correct value") do
  raise "wrong value" unless Sashite::Feen::Errors::Argument::Messages::TOO_MANY_PIECES == "too many pieces for board size"
end

run_test("TOO_MANY_PIECES is frozen") do
  raise "should be frozen" unless Sashite::Feen::Errors::Argument::Messages::TOO_MANY_PIECES.frozen?
end

# ============================================================================
# MODULE STRUCTURE
# ============================================================================

puts
puts "Module structure:"

run_test("Messages is a Module") do
  raise "wrong type" unless Sashite::Feen::Errors::Argument::Messages.is_a?(Module)
end

run_test("Messages is nested under Sashite::Feen::Errors::Argument") do
  raise "wrong nesting" unless Sashite::Feen::Errors::Argument.const_defined?(:Messages)
end

puts
puts "All Errors::Argument::Messages tests passed!"
puts
