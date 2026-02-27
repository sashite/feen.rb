#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/shared/limits"

puts
puts "=== Limits Tests ==="
puts

Limits = Sashite::Feen::Limits

# ============================================================================
# CONSTANTS
# ============================================================================

puts "constants:"

run_test("MAX_STRING_LENGTH is 4096") do
  raise "wrong value" unless Limits::MAX_STRING_LENGTH == 4_096
end

run_test("MAX_DIMENSIONS is 3") do
  raise "wrong value" unless Limits::MAX_DIMENSIONS == 3
end

run_test("MAX_DIMENSION_SIZE is 255") do
  raise "wrong value" unless Limits::MAX_DIMENSION_SIZE == 255
end

# ============================================================================
# IMMUTABILITY
# ============================================================================

puts
puts "immutability:"

run_test("module is frozen") do
  raise "expected frozen" unless Limits.frozen?
end

run_test("MAX_STRING_LENGTH is frozen") do
  raise "expected frozen" unless Limits::MAX_STRING_LENGTH.frozen?
end

run_test("MAX_DIMENSIONS is frozen") do
  raise "expected frozen" unless Limits::MAX_DIMENSIONS.frozen?
end

run_test("MAX_DIMENSION_SIZE is frozen") do
  raise "expected frozen" unless Limits::MAX_DIMENSION_SIZE.frozen?
end

puts
puts "All Limits tests passed!"
puts
