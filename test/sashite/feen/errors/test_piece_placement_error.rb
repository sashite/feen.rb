#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/errors/piece_placement_error"

puts
puts "=== PiecePlacementError Tests ==="
puts

# ============================================================================
# INHERITANCE
# ============================================================================

puts "Inheritance:"

run_test("inherits from Sashite::Feen::ParseError") do
  result = Sashite::Feen::PiecePlacementError.superclass
  raise "expected ParseError, got #{result.inspect}" unless result == Sashite::Feen::ParseError
end

run_test("is a subclass of Sashite::Feen::Error") do
  result = Sashite::Feen::PiecePlacementError < Sashite::Feen::Error
  raise "expected to be subclass of Error" unless result == true
end

run_test("is a subclass of ArgumentError") do
  result = Sashite::Feen::PiecePlacementError < ::ArgumentError
  raise "expected to be subclass of ArgumentError" unless result == true
end

# ============================================================================
# ERROR MESSAGE CONSTANTS - BOUNDARY ERRORS
# ============================================================================

puts
puts "Error message constants - Boundary errors:"

run_test("EMPTY is defined") do
  result = Sashite::Feen::PiecePlacementError::EMPTY
  raise "expected String" unless ::String === result
end

run_test("EMPTY has meaningful message") do
  result = Sashite::Feen::PiecePlacementError::EMPTY
  raise "expected to mention empty" unless result.include?("empty")
end

run_test("STARTS_WITH_SEPARATOR is defined") do
  result = Sashite::Feen::PiecePlacementError::STARTS_WITH_SEPARATOR
  raise "expected String" unless ::String === result
end

run_test("STARTS_WITH_SEPARATOR has meaningful message") do
  result = Sashite::Feen::PiecePlacementError::STARTS_WITH_SEPARATOR
  raise "expected to mention separator" unless result.include?("separator")
end

run_test("ENDS_WITH_SEPARATOR is defined") do
  result = Sashite::Feen::PiecePlacementError::ENDS_WITH_SEPARATOR
  raise "expected String" unless ::String === result
end

run_test("ENDS_WITH_SEPARATOR has meaningful message") do
  result = Sashite::Feen::PiecePlacementError::ENDS_WITH_SEPARATOR
  raise "expected to mention separator" unless result.include?("separator")
end

# ============================================================================
# ERROR MESSAGE CONSTANTS - SEGMENT ERRORS
# ============================================================================

puts
puts "Error message constants - Segment errors:"

run_test("EMPTY_SEGMENT is defined") do
  result = Sashite::Feen::PiecePlacementError::EMPTY_SEGMENT
  raise "expected String" unless ::String === result
end

run_test("EMPTY_SEGMENT has meaningful message") do
  result = Sashite::Feen::PiecePlacementError::EMPTY_SEGMENT
  raise "expected to mention segment" unless result.include?("segment")
end

# ============================================================================
# ERROR MESSAGE CONSTANTS - TOKEN ERRORS
# ============================================================================

puts
puts "Error message constants - Token errors:"

run_test("INVALID_EMPTY_COUNT is defined") do
  result = Sashite::Feen::PiecePlacementError::INVALID_EMPTY_COUNT
  raise "expected String" unless ::String === result
end

run_test("INVALID_EMPTY_COUNT has meaningful message") do
  result = Sashite::Feen::PiecePlacementError::INVALID_EMPTY_COUNT
  raise "expected to mention empty or count" unless result.include?("empty") || result.include?("count")
end

run_test("INVALID_PIECE_TOKEN is defined") do
  result = Sashite::Feen::PiecePlacementError::INVALID_PIECE_TOKEN
  raise "expected String" unless ::String === result
end

run_test("INVALID_PIECE_TOKEN has meaningful message") do
  result = Sashite::Feen::PiecePlacementError::INVALID_PIECE_TOKEN
  raise "expected to mention piece or token" unless result.include?("piece") || result.include?("token")
end

# ============================================================================
# ERROR MESSAGE CONSTANTS - CANONICALIZATION ERRORS
# ============================================================================

puts
puts "Error message constants - Canonicalization errors:"

run_test("CONSECUTIVE_EMPTY_COUNTS is defined") do
  result = Sashite::Feen::PiecePlacementError::CONSECUTIVE_EMPTY_COUNTS
  raise "expected String" unless ::String === result
end

run_test("CONSECUTIVE_EMPTY_COUNTS has meaningful message") do
  result = Sashite::Feen::PiecePlacementError::CONSECUTIVE_EMPTY_COUNTS
  raise "expected to mention merge" unless result.include?("merge")
end

# ============================================================================
# ERROR MESSAGE CONSTANTS - DIMENSIONAL ERRORS
# ============================================================================

puts
puts "Error message constants - Dimensional errors:"

run_test("DIMENSIONAL_COHERENCE is defined") do
  result = Sashite::Feen::PiecePlacementError::DIMENSIONAL_COHERENCE
  raise "expected String" unless ::String === result
end

run_test("DIMENSIONAL_COHERENCE has meaningful message") do
  result = Sashite::Feen::PiecePlacementError::DIMENSIONAL_COHERENCE
  raise "expected to mention dimensional or coherence" unless result.include?("dimensional") || result.include?("coherence")
end

run_test("EXCEEDS_MAX_DIMENSIONS is defined") do
  result = Sashite::Feen::PiecePlacementError::EXCEEDS_MAX_DIMENSIONS
  raise "expected String" unless ::String === result
end

run_test("EXCEEDS_MAX_DIMENSIONS has meaningful message") do
  result = Sashite::Feen::PiecePlacementError::EXCEEDS_MAX_DIMENSIONS
  raise "expected to mention dimension" unless result.include?("dimension")
end

run_test("DIMENSION_SIZE_EXCEEDED is defined") do
  result = Sashite::Feen::PiecePlacementError::DIMENSION_SIZE_EXCEEDED
  raise "expected String" unless ::String === result
end

run_test("DIMENSION_SIZE_EXCEEDED has meaningful message") do
  result = Sashite::Feen::PiecePlacementError::DIMENSION_SIZE_EXCEEDED
  raise "expected to mention dimension or size" unless result.include?("dimension") || result.include?("size")
end

# ============================================================================
# RAISING AND CATCHING
# ============================================================================

puts
puts "Raising and catching:"

run_test("can be raised") do
  raised = false
  begin
    raise Sashite::Feen::PiecePlacementError, "test"
  rescue Sashite::Feen::PiecePlacementError
    raised = true
  end
  raise "expected error to be raised" unless raised
end

run_test("can be caught as PiecePlacementError") do
  caught_class = nil
  begin
    raise Sashite::Feen::PiecePlacementError, "test"
  rescue Sashite::Feen::PiecePlacementError => e
    caught_class = e.class
  end
  raise "expected PiecePlacementError" unless caught_class == Sashite::Feen::PiecePlacementError
end

run_test("can be caught as ParseError") do
  caught = false
  begin
    raise Sashite::Feen::PiecePlacementError, "test"
  rescue Sashite::Feen::ParseError
    caught = true
  end
  raise "expected to be caught as ParseError" unless caught
end

run_test("can be caught as Sashite::Feen::Error") do
  caught = false
  begin
    raise Sashite::Feen::PiecePlacementError, "test"
  rescue Sashite::Feen::Error
    caught = true
  end
  raise "expected to be caught as Error" unless caught
end

run_test("can be caught as ArgumentError") do
  caught = false
  begin
    raise Sashite::Feen::PiecePlacementError, "test"
  rescue ::ArgumentError
    caught = true
  end
  raise "expected to be caught as ArgumentError" unless caught
end

run_test("can be raised with constant message") do
  message = nil
  begin
    raise Sashite::Feen::PiecePlacementError, Sashite::Feen::PiecePlacementError::EMPTY
  rescue Sashite::Feen::PiecePlacementError => e
    message = e.message
  end
  raise "message mismatch" unless message == Sashite::Feen::PiecePlacementError::EMPTY
end

# ============================================================================
# TYPE CHECKING
# ============================================================================

puts
puts "Type checking:"

run_test("instance is a PiecePlacementError") do
  error = Sashite::Feen::PiecePlacementError.new("test")
  raise "expected PiecePlacementError === error" unless Sashite::Feen::PiecePlacementError === error
end

run_test("instance is a ParseError") do
  error = Sashite::Feen::PiecePlacementError.new("test")
  raise "expected ParseError === error" unless Sashite::Feen::ParseError === error
end

run_test("instance is a Sashite::Feen::Error") do
  error = Sashite::Feen::PiecePlacementError.new("test")
  raise "expected Error === error" unless Sashite::Feen::Error === error
end

# ============================================================================
# CONSTANTS ARE DISTINCT
# ============================================================================

puts
puts "Constants are distinct:"

run_test("all error messages are unique") do
  messages = [
    Sashite::Feen::PiecePlacementError::EMPTY,
    Sashite::Feen::PiecePlacementError::STARTS_WITH_SEPARATOR,
    Sashite::Feen::PiecePlacementError::ENDS_WITH_SEPARATOR,
    Sashite::Feen::PiecePlacementError::EMPTY_SEGMENT,
    Sashite::Feen::PiecePlacementError::INVALID_EMPTY_COUNT,
    Sashite::Feen::PiecePlacementError::INVALID_PIECE_TOKEN,
    Sashite::Feen::PiecePlacementError::CONSECUTIVE_EMPTY_COUNTS,
    Sashite::Feen::PiecePlacementError::DIMENSIONAL_COHERENCE,
    Sashite::Feen::PiecePlacementError::EXCEEDS_MAX_DIMENSIONS,
    Sashite::Feen::PiecePlacementError::DIMENSION_SIZE_EXCEEDED
  ]
  unique_messages = messages.uniq
  raise "expected unique messages, got duplicates" unless messages.length == unique_messages.length
end

puts
puts "All PiecePlacementError tests passed!"
puts
