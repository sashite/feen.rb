#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/shared/separators"

puts
puts "=== Separators Tests ==="
puts

Separators = Sashite::Feen::Separators

# ============================================================================
# CONSTANTS
# ============================================================================

puts "constants:"

run_test("FIELD is a space") do
  raise "wrong value" unless Separators::FIELD == " "
end

run_test("SEGMENT is a slash") do
  raise "wrong value" unless Separators::SEGMENT == "/"
end

# ============================================================================
# IMMUTABILITY
# ============================================================================

puts
puts "immutability:"

run_test("module is frozen") do
  raise "expected frozen" unless Separators.frozen?
end

run_test("FIELD is frozen") do
  raise "expected frozen" unless Separators::FIELD.frozen?
end

run_test("SEGMENT is frozen") do
  raise "expected frozen" unless Separators::SEGMENT.frozen?
end

puts
puts "All Separators tests passed!"
puts
