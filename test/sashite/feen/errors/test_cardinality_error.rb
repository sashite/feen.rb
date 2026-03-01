#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/errors/cardinality_error"

puts
puts "=== CardinalityError Tests ==="
puts

CardinalityError = Sashite::Feen::CardinalityError

# ============================================================================
# INHERITANCE
# ============================================================================

puts "inheritance:"

Test("inherits from ParseError") do
  raise "wrong parent" unless CardinalityError < Sashite::Feen::ParseError
end

Test("inherits from Sashite::Feen::Error") do
  raise "wrong ancestor" unless CardinalityError < Sashite::Feen::Error
end

Test("inherits from ArgumentError") do
  raise "wrong ancestor" unless CardinalityError < ArgumentError
end

# ============================================================================
# CONSTANTS
# ============================================================================

puts
puts "constants:"

Test("TOO_MANY_PIECES is defined") do
  raise "missing constant" unless CardinalityError.const_defined?(:TOO_MANY_PIECES)
end

Test("TOO_MANY_PIECES is a String") do
  raise "wrong type" unless CardinalityError::TOO_MANY_PIECES.is_a?(String)
end

# ============================================================================
# RAISING
# ============================================================================

puts
puts "raising:"

Test("can be raised and rescued as CardinalityError") do
  raise CardinalityError, CardinalityError::TOO_MANY_PIECES
rescue CardinalityError => e
  raise "wrong message" unless e.message == CardinalityError::TOO_MANY_PIECES
end

Test("can be rescued as ParseError") do
  raise CardinalityError, "test"
rescue Sashite::Feen::ParseError
  # Expected
end

Test("can be rescued as Sashite::Feen::Error") do
  raise CardinalityError, "test"
rescue Sashite::Feen::Error
  # Expected
end

Test("can be rescued as ArgumentError") do
  raise CardinalityError, "test"
rescue ArgumentError
  # Expected
end

# ============================================================================
# IMMUTABILITY
# ============================================================================

puts
puts "immutability:"

Test("class is frozen") do
  raise "expected frozen" unless CardinalityError.frozen?
end

puts
puts "All CardinalityError tests passed!"
puts
