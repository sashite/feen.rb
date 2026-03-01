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

Test("inherits from ParseError, Error, and ArgumentError") do
  raise unless PiecePlacementError < Sashite::Feen::ParseError
  raise unless PiecePlacementError < Sashite::Feen::Error
  raise unless PiecePlacementError < ArgumentError
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

Test("all error message constants are defined strings") do
  EXPECTED_CONSTANTS.each do |const|
    raise "#{const} missing" unless PiecePlacementError.const_defined?(const)
    raise "#{const} not String" unless PiecePlacementError.const_get(const).is_a?(String)
  end
end

# ============================================================================
# RAISING
# ============================================================================

puts
puts "raising:"

Test("raises with correct message for each constant") do
  EXPECTED_CONSTANTS.each do |const|
    msg = PiecePlacementError.const_get(const)
    begin
      raise PiecePlacementError, msg
    rescue PiecePlacementError => e
      raise "wrong message for #{const}" unless e.message == msg
    end
  end
end

Test("rescuable as all ancestor types") do
  begin; raise PiecePlacementError, "test"; rescue Sashite::Feen::ParseError; end
  begin; raise PiecePlacementError, "test"; rescue Sashite::Feen::Error; end
  begin; raise PiecePlacementError, "test"; rescue ArgumentError; end
end

# ============================================================================
# IMMUTABILITY
# ============================================================================

puts
puts "immutability:"

Test("class is frozen") do
  raise unless PiecePlacementError.frozen?
end

puts
puts "All PiecePlacementError tests passed!"
puts
