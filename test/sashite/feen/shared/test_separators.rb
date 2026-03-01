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

Test("values match specification") do
  raise unless Separators::FIELD   == " "
  raise unless Separators::SEGMENT == "/"
end

# ============================================================================
# IMMUTABILITY
# ============================================================================

puts
puts "immutability:"

Test("module and constants are frozen") do
  raise unless Separators.frozen?
  raise unless Separators::FIELD.frozen?
  raise unless Separators::SEGMENT.frozen?
end

puts
puts "All Separators tests passed!"
puts
