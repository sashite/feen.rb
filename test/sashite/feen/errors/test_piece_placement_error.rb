#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/errors/piece_placement_error"

puts
puts "=== PiecePlacementError Tests ==="
puts

PiecePlacementError = Sashite::Feen::PiecePlacementError

# ============================================================================
# INHERITANCE
# ============================================================================

puts "inheritance:"

run_test("inherits from ParseError") do
  raise "wrong parent" unless PiecePlacementError < Sashite::Feen::ParseError
end

run_test("inherits from Sashite::Feen::Error") do
  raise "wrong ancestor" unless PiecePlacementError < Sashite::Feen::Error
end

run_test("inherits from ArgumentError") do
  raise "wrong ancestor" unless PiecePlacementError < ArgumentError
end

# ============================================================================
# CONSTANTS
# ============================================================================

puts
puts "constants:"

EXPECTED_CONSTANTS = %i[
  EMPTY
  STARTS_WITH_SEPARATOR
  ENDS_WITH_SEPARATOR
  EMPTY_SEGMENT
  INVALID_EMPTY_COUNT
  INVALID_PIECE_TOKEN
  CONSECUTIVE_EMPTY_COUNTS
  DIMENSIONAL_COHERENCE
  EXCEEDS_MAX_DIMENSIONS
  DIMENSION_SIZE_EXCEEDED
].freeze

EXPECTED_CONSTANTS.each do |const|
  run_test("#{const} is defined") do
    raise "missing constant" unless PiecePlacementError.const_defined?(const)
  end

  run_test("#{const} is a String") do
    raise "wrong type" unless PiecePlacementError.const_get(const).is_a?(String)
  end
end

# ============================================================================
# RAISING
# ============================================================================

puts
puts "raising:"

run_test("can be raised and rescued as PiecePlacementError") do
  raise PiecePlacementError, PiecePlacementError::EMPTY
rescue PiecePlacementError => e
  raise "wrong message" unless e.message == PiecePlacementError::EMPTY
end

run_test("can be rescued as ParseError") do
  raise PiecePlacementError, "test"
rescue Sashite::Feen::ParseError
  # Expected
end

run_test("can be rescued as Sashite::Feen::Error") do
  raise PiecePlacementError, "test"
rescue Sashite::Feen::Error
  # Expected
end

run_test("can be rescued as ArgumentError") do
  raise PiecePlacementError, "test"
rescue ArgumentError
  # Expected
end

# ============================================================================
# IMMUTABILITY
# ============================================================================

puts
puts "immutability:"

run_test("class is frozen") do
  raise "expected frozen" unless PiecePlacementError.frozen?
end

puts
puts "All PiecePlacementError tests passed!"
puts
