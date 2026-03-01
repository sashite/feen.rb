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

Test("FIELD is a space") do
  raise "wrong value" unless Separators::FIELD == " "
end

Test("SEGMENT is a slash") do
  raise "wrong value" unless Separators::SEGMENT == "/"
end

# ============================================================================
# IMMUTABILITY
# ============================================================================

puts
puts "immutability:"

Test("module is frozen") do
  raise "expected frozen" unless Separators.frozen?
end

Test("FIELD is frozen") do
  raise "expected frozen" unless Separators::FIELD.frozen?
end

Test("SEGMENT is frozen") do
  raise "expected frozen" unless Separators::SEGMENT.frozen?
end

puts
puts "All Separators tests passed!"
puts
