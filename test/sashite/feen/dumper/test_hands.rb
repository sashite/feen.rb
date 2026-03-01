#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/dumper/hands"

puts
puts "=== Dumper::Hands Tests ==="
puts

Hands = Sashite::Feen::Dumper::Hands

# ============================================================================
# BASIC CASES
# ============================================================================

puts "basic cases:"

Test("empty, one-sided, and both hands") do
  raise unless Hands.dump({}, {})                              == "/"
  raise unless Hands.dump({ "P" => 1 }, {})                   == "P/"
  raise unless Hands.dump({}, { "p" => 1 })                   == "/p"
  raise unless Hands.dump({ "P" => 2, "N" => 1 }, { "p" => 1 }) == "2PN/p"
end

Test("complex hands") do
  raise unless Hands.dump({ "B" => 3, "P" => 2, "N" => 1, "R" => 1 }, { "q" => 2, "p" => 1 }) == "3B2PNR/2qp"
end

# ============================================================================
# CANONICAL ORDERING
# ============================================================================

puts
puts "canonical ordering:"

Test("by multiplicity descending") do
  raise unless Hands.dump({ "B" => 3, "P" => 2 }, {}) == "3B2P/"
end

Test("alphabetical at same count") do
  raise unless Hands.dump({ "N" => 1, "B" => 1 }, {}) == "BN/"
end

Test("uppercase before lowercase for same letter") do
  raise unless Hands.dump({ "P" => 1, "p" => 1 }, {}) == "Pp/"
end

Test("state modifier: diminished < enhanced < normal") do
  raise unless Hands.dump({ "-P" => 1, "+P" => 1, "P" => 1 }, {}) == "-P+PP/"
end

Test("terminal: absent before present") do
  raise unless Hands.dump({ "P" => 1, "P^" => 1 }, {}) == "PP^/"
end

Test("derivation: absent before present") do
  raise unless Hands.dump({ "P" => 1, "P'" => 1 }, {}) == "PP'/"
end

# ============================================================================
# COUNT FORMATTING
# ============================================================================

puts
puts "count formatting:"

Test("omits prefix for count 1, includes for count >= 2") do
  raise if Hands.dump({ "P" => 1 }, {}).start_with?("1")
  raise unless Hands.dump({ "P" => 3 }, {}) == "3P/"
  raise unless Hands.dump({ "R" => 1, "P" => 2, "B" => 1 }, {}) == "2PBR/"
end

# ============================================================================
# DECORATED PIECES
# ============================================================================

puts
puts "decorated pieces:"

Test("state modifiers, terminal, and fully decorated") do
  raise unless Hands.dump({ "+P" => 2 }, {})     == "2+P/"
  raise unless Hands.dump({ "K^" => 1 }, {})     == "K^/"
  raise unless Hands.dump({ "+K^'" => 2 }, {})   == "2+K^'/"
end

# ============================================================================
# FORMAT INVARIANTS & MODULE PROPERTIES
# ============================================================================

puts
puts "format and module properties:"

Test("returns String with exactly one slash") do
  inputs = [{}, { "P" => 1 }, { "P" => 2, "N" => 1 }]
  inputs.each do |hand|
    result = Hands.dump(hand, {})
    raise unless result.is_a?(String)
    raise "#{result.inspect} has #{result.count("/")} slashes" unless result.count("/") == 1
  end
end

Test("module is frozen") do
  raise unless Hands.frozen?
end

puts
puts "All Dumper::Hands tests passed!"
puts
