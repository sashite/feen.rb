#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/errors/parse_error"

puts
puts "=== ParseError Tests ==="
puts

ParseError = Sashite::Feen::ParseError

# ============================================================================
# INHERITANCE
# ============================================================================

puts "inheritance:"

Test("inherits from Sashite::Feen::Error") do
  raise "wrong parent" unless ParseError < Sashite::Feen::Error
end

Test("inherits from ArgumentError") do
  raise "wrong ancestor" unless ParseError < ArgumentError
end

# ============================================================================
# CONSTANTS
# ============================================================================

puts
puts "constants:"

Test("INPUT_TOO_LONG is defined") do
  raise "missing constant" unless ParseError.const_defined?(:INPUT_TOO_LONG)
end

Test("INPUT_TOO_LONG is a String") do
  raise "wrong type" unless ParseError::INPUT_TOO_LONG.is_a?(String)
end

Test("INVALID_FIELD_COUNT is defined") do
  raise "missing constant" unless ParseError.const_defined?(:INVALID_FIELD_COUNT)
end

Test("INVALID_FIELD_COUNT is a String") do
  raise "wrong type" unless ParseError::INVALID_FIELD_COUNT.is_a?(String)
end

# ============================================================================
# RAISING
# ============================================================================

puts
puts "raising:"

Test("can be raised with INPUT_TOO_LONG message") do
  raise ParseError, ParseError::INPUT_TOO_LONG
rescue ParseError => e
  raise "wrong message" unless e.message == ParseError::INPUT_TOO_LONG
end

Test("can be raised with INVALID_FIELD_COUNT message") do
  raise ParseError, ParseError::INVALID_FIELD_COUNT
rescue ParseError => e
  raise "wrong message" unless e.message == ParseError::INVALID_FIELD_COUNT
end

Test("can be rescued as Sashite::Feen::Error") do
  raise ParseError, "test"
rescue Sashite::Feen::Error
  # Expected
end

Test("can be rescued as ArgumentError") do
  raise ParseError, "test"
rescue ArgumentError
  # Expected
end

# ============================================================================
# IMMUTABILITY
# ============================================================================

puts
puts "immutability:"

Test("class is frozen") do
  raise "expected frozen" unless ParseError.frozen?
end

puts
puts "All ParseError tests passed!"
puts
