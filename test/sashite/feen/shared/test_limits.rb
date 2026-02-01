#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/shared/limits"

puts
puts "=== Limits Tests ==="
puts

# ============================================================================
# MAX_STRING_LENGTH
# ============================================================================

puts "MAX_STRING_LENGTH:"

run_test("equals 4096") do
  result = Sashite::Feen::Limits::MAX_STRING_LENGTH
  raise "expected 4096, got #{result.inspect}" unless result == 4096
end

run_test("is an Integer") do
  result = Sashite::Feen::Limits::MAX_STRING_LENGTH
  raise "expected Integer, got #{result.class}" unless ::Integer === result
end

run_test("is positive") do
  result = Sashite::Feen::Limits::MAX_STRING_LENGTH
  raise "expected positive, got #{result.inspect}" unless result > 0
end

# ============================================================================
# MAX_DIMENSIONS
# ============================================================================

puts
puts "MAX_DIMENSIONS:"

run_test("equals 3") do
  result = Sashite::Feen::Limits::MAX_DIMENSIONS
  raise "expected 3, got #{result.inspect}" unless result == 3
end

run_test("is an Integer") do
  result = Sashite::Feen::Limits::MAX_DIMENSIONS
  raise "expected Integer, got #{result.class}" unless ::Integer === result
end

run_test("is positive") do
  result = Sashite::Feen::Limits::MAX_DIMENSIONS
  raise "expected positive, got #{result.inspect}" unless result > 0
end

run_test("covers 1D boards") do
  result = Sashite::Feen::Limits::MAX_DIMENSIONS
  raise "should cover 1D (#{result} < 1)" unless result >= 1
end

run_test("covers 2D boards") do
  result = Sashite::Feen::Limits::MAX_DIMENSIONS
  raise "should cover 2D (#{result} < 2)" unless result >= 2
end

run_test("covers 3D boards") do
  result = Sashite::Feen::Limits::MAX_DIMENSIONS
  raise "should cover 3D (#{result} < 3)" unless result >= 3
end

# ============================================================================
# MAX_DIMENSION_SIZE
# ============================================================================

puts
puts "MAX_DIMENSION_SIZE:"

run_test("equals 255") do
  result = Sashite::Feen::Limits::MAX_DIMENSION_SIZE
  raise "expected 255, got #{result.inspect}" unless result == 255
end

run_test("is an Integer") do
  result = Sashite::Feen::Limits::MAX_DIMENSION_SIZE
  raise "expected Integer, got #{result.class}" unless ::Integer === result
end

run_test("is positive") do
  result = Sashite::Feen::Limits::MAX_DIMENSION_SIZE
  raise "expected positive, got #{result.inspect}" unless result > 0
end

run_test("fits in 8-bit unsigned integer") do
  result = Sashite::Feen::Limits::MAX_DIMENSION_SIZE
  raise "should fit in uint8 (#{result} > 255)" unless result <= 255
end

run_test("covers standard Chess board (8)") do
  result = Sashite::Feen::Limits::MAX_DIMENSION_SIZE
  raise "should cover Chess 8x8 (#{result} < 8)" unless result >= 8
end

run_test("covers Shogi board (9)") do
  result = Sashite::Feen::Limits::MAX_DIMENSION_SIZE
  raise "should cover Shogi 9x9 (#{result} < 9)" unless result >= 9
end

run_test("covers Xiangqi board (10)") do
  result = Sashite::Feen::Limits::MAX_DIMENSION_SIZE
  raise "should cover Xiangqi 9x10 (#{result} < 10)" unless result >= 10
end

run_test("covers Go board (19)") do
  result = Sashite::Feen::Limits::MAX_DIMENSION_SIZE
  raise "should cover Go 19x19 (#{result} < 19)" unless result >= 19
end

# ============================================================================
# MODULE PROPERTIES
# ============================================================================

puts
puts "Module properties:"

run_test("module has no instance methods") do
  methods = Sashite::Feen::Limits.instance_methods(false)
  raise "expected no instance methods, got #{methods.inspect}" unless methods.empty?
end

# ============================================================================
# PRACTICAL CONSTRAINTS
# ============================================================================

puts
puts "Practical constraints:"

run_test("MAX_STRING_LENGTH can hold large 2D board representation") do
  # Worst case: 255x255 board with single-char pieces = 255*255 + 254 separators
  # That's ~65,000 chars, but FEEN uses run-length encoding
  # A 19x19 Go board fully filled: 19*19 pieces + 18 separators = ~379 chars
  # 4096 is more than sufficient
  max_len = Sashite::Feen::Limits::MAX_STRING_LENGTH
  go_board_estimate = 19 * 19 + 18
  raise "should handle Go board" unless max_len > go_board_estimate
end

run_test("dimensions and size allow 3D Raumschach (5x5x5)") do
  dims = Sashite::Feen::Limits::MAX_DIMENSIONS
  size = Sashite::Feen::Limits::MAX_DIMENSION_SIZE
  raise "should allow 3D" unless dims >= 3
  raise "should allow size 5" unless size >= 5
end

puts
puts "All Limits tests passed!"
puts
