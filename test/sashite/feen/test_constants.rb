#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../helper"
require_relative "../../../lib/sashite/feen/constants"

puts
puts "=== Constants Tests ==="
puts

# ============================================================================
# MAX_STRING_LENGTH
# ============================================================================

puts "MAX_STRING_LENGTH:"

run_test("MAX_STRING_LENGTH is defined") do
  raise "not defined" unless defined?(Sashite::Feen::Constants::MAX_STRING_LENGTH)
end

run_test("MAX_STRING_LENGTH equals 4096") do
  raise "wrong value" unless Sashite::Feen::Constants::MAX_STRING_LENGTH == 4096
end

run_test("MAX_STRING_LENGTH is an Integer") do
  raise "wrong type" unless Sashite::Feen::Constants::MAX_STRING_LENGTH.is_a?(Integer)
end

# ============================================================================
# MAX_DIMENSIONS
# ============================================================================

puts
puts "MAX_DIMENSIONS:"

run_test("MAX_DIMENSIONS is defined") do
  raise "not defined" unless defined?(Sashite::Feen::Constants::MAX_DIMENSIONS)
end

run_test("MAX_DIMENSIONS equals 3") do
  raise "wrong value" unless Sashite::Feen::Constants::MAX_DIMENSIONS == 3
end

run_test("MAX_DIMENSIONS is an Integer") do
  raise "wrong type" unless Sashite::Feen::Constants::MAX_DIMENSIONS.is_a?(Integer)
end

# ============================================================================
# MAX_DIMENSION_SIZE
# ============================================================================

puts
puts "MAX_DIMENSION_SIZE:"

run_test("MAX_DIMENSION_SIZE is defined") do
  raise "not defined" unless defined?(Sashite::Feen::Constants::MAX_DIMENSION_SIZE)
end

run_test("MAX_DIMENSION_SIZE equals 255") do
  raise "wrong value" unless Sashite::Feen::Constants::MAX_DIMENSION_SIZE == 255
end

run_test("MAX_DIMENSION_SIZE is an Integer") do
  raise "wrong type" unless Sashite::Feen::Constants::MAX_DIMENSION_SIZE.is_a?(Integer)
end

# ============================================================================
# FIELD_SEPARATOR
# ============================================================================

puts
puts "FIELD_SEPARATOR:"

run_test("FIELD_SEPARATOR is defined") do
  raise "not defined" unless defined?(Sashite::Feen::Constants::FIELD_SEPARATOR)
end

run_test("FIELD_SEPARATOR equals space") do
  raise "wrong value" unless Sashite::Feen::Constants::FIELD_SEPARATOR == " "
end

run_test("FIELD_SEPARATOR is a String") do
  raise "wrong type" unless Sashite::Feen::Constants::FIELD_SEPARATOR.is_a?(String)
end

run_test("FIELD_SEPARATOR has length 1") do
  raise "wrong length" unless Sashite::Feen::Constants::FIELD_SEPARATOR.length == 1
end

# ============================================================================
# SEGMENT_SEPARATOR
# ============================================================================

puts
puts "SEGMENT_SEPARATOR:"

run_test("SEGMENT_SEPARATOR is defined") do
  raise "not defined" unless defined?(Sashite::Feen::Constants::SEGMENT_SEPARATOR)
end

run_test("SEGMENT_SEPARATOR equals forward slash") do
  raise "wrong value" unless Sashite::Feen::Constants::SEGMENT_SEPARATOR == "/"
end

run_test("SEGMENT_SEPARATOR is a String") do
  raise "wrong type" unless Sashite::Feen::Constants::SEGMENT_SEPARATOR.is_a?(String)
end

run_test("SEGMENT_SEPARATOR has length 1") do
  raise "wrong length" unless Sashite::Feen::Constants::SEGMENT_SEPARATOR.length == 1
end

# ============================================================================
# IMMUTABILITY
# ============================================================================

puts
puts "Immutability:"

run_test("MAX_STRING_LENGTH is frozen") do
  raise "should be frozen" unless Sashite::Feen::Constants::MAX_STRING_LENGTH.frozen?
end

run_test("MAX_DIMENSIONS is frozen") do
  raise "should be frozen" unless Sashite::Feen::Constants::MAX_DIMENSIONS.frozen?
end

run_test("MAX_DIMENSION_SIZE is frozen") do
  raise "should be frozen" unless Sashite::Feen::Constants::MAX_DIMENSION_SIZE.frozen?
end

run_test("FIELD_SEPARATOR is frozen") do
  raise "should be frozen" unless Sashite::Feen::Constants::FIELD_SEPARATOR.frozen?
end

run_test("SEGMENT_SEPARATOR is frozen") do
  raise "should be frozen" unless Sashite::Feen::Constants::SEGMENT_SEPARATOR.frozen?
end

# ============================================================================
# MODULE STRUCTURE
# ============================================================================

puts
puts "Module structure:"

run_test("Constants is a Module") do
  raise "wrong type" unless Sashite::Feen::Constants.is_a?(Module)
end

run_test("Constants is nested under Sashite::Feen") do
  raise "wrong nesting" unless Sashite::Feen.const_defined?(:Constants)
end

puts
puts "All Constants tests passed!"
puts
