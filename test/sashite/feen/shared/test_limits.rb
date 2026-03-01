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

Test("values match specification") do
  raise unless Limits::MAX_STRING_LENGTH  == 4_096
  raise unless Limits::MAX_DIMENSIONS     == 3
  raise unless Limits::MAX_DIMENSION_SIZE == 255
end

# ============================================================================
# IMMUTABILITY
# ============================================================================

puts
puts "immutability:"

Test("module and constants are frozen") do
  raise unless Limits.frozen?
  raise unless Limits::MAX_STRING_LENGTH.frozen?
  raise unless Limits::MAX_DIMENSIONS.frozen?
  raise unless Limits::MAX_DIMENSION_SIZE.frozen?
end

puts
puts "All Limits tests passed!"
puts
