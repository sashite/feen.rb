#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/dumper/hands"

puts
puts "=== Dumper::Hands Tests ==="
puts

Hands = Sashite::Feen::Dumper::Hands

# ============================================================================
# EMPTY HANDS
# ============================================================================

puts "empty hands:"

Test("dumps both empty hands") do
  result = Hands.dump({}, {})
  raise "expected '/'" unless result == "/"
end

# ============================================================================
# FIRST HAND ONLY
# ============================================================================

puts
puts "first hand only:"

Test("dumps single piece in first hand") do
  result = Hands.dump({ "P" => 1 }, {})
  raise "expected 'P/'" unless result == "P/"
end

Test("dumps multiple distinct pieces in first hand") do
  result = Hands.dump({ "P" => 1, "N" => 1 }, {})
  raise "expected 'NP/'" unless result == "NP/"
end

Test("dumps counted pieces in first hand") do
  result = Hands.dump({ "P" => 2 }, {})
  raise "expected '2P/'" unless result == "2P/"
end

Test("dumps complex first hand") do
  result = Hands.dump({ "B" => 3, "P" => 2, "N" => 1, "R" => 1 }, {})
  raise "expected '3B2PNR/'" unless result == "3B2PNR/"
end

# ============================================================================
# SECOND HAND ONLY
# ============================================================================

puts
puts "second hand only:"

Test("dumps single piece in second hand") do
  result = Hands.dump({}, { "p" => 1 })
  raise "expected '/p'" unless result == "/p"
end

Test("dumps counted pieces in second hand") do
  result = Hands.dump({}, { "q" => 2, "p" => 1 })
  raise "expected '/2qp'" unless result == "/2qp"
end

# ============================================================================
# BOTH HANDS
# ============================================================================

puts
puts "both hands:"

Test("dumps pieces in both hands") do
  result = Hands.dump({ "P" => 2, "N" => 1 }, { "p" => 1 })
  raise "expected '2PN/p'" unless result == "2PN/p"
end

Test("dumps complex both hands") do
  result = Hands.dump({ "B" => 3, "P" => 2, "N" => 1, "R" => 1 }, { "q" => 2, "p" => 1 })
  raise "expected '3B2PNR/2qp'" unless result == "3B2PNR/2qp"
end

# ============================================================================
# CANONICAL ORDERING
# ============================================================================

puts
puts "canonical ordering:"

Test("sorts by multiplicity descending") do
  result = Hands.dump({ "B" => 3, "P" => 2 }, {})
  raise "expected '3B2P/'" unless result == "3B2P/"
end

Test("sorts alphabetically at same count") do
  result = Hands.dump({ "N" => 1, "B" => 1 }, {})
  raise "expected 'BN/'" unless result == "BN/"
end

Test("sorts uppercase before lowercase for same letter") do
  result = Hands.dump({ "P" => 1, "p" => 1 }, {})
  raise "expected 'Pp/'" unless result == "Pp/"
end

Test("sorts diminished before enhanced before normal") do
  result = Hands.dump({ "-P" => 1, "+P" => 1, "P" => 1 }, {})
  raise "expected '-P+PP/'" unless result == "-P+PP/"
end

Test("sorts absent terminal before present terminal") do
  result = Hands.dump({ "P" => 1, "P^" => 1 }, {})
  raise "expected 'PP^/'" unless result == "PP^/"
end

Test("sorts absent derivation before present derivation") do
  result = Hands.dump({ "P" => 1, "P'" => 1 }, {})
  raise "expected 'PP'/' but got '#{result}'" unless result == "PP'/"
end

# ============================================================================
# COUNT FORMATTING
# ============================================================================

puts
puts "count formatting:"

Test("omits count prefix for single piece") do
  result = Hands.dump({ "P" => 1 }, {})
  raise "should not have count prefix" if result.start_with?("1")
end

Test("includes count prefix for multiple pieces") do
  result = Hands.dump({ "P" => 3 }, {})
  raise "expected '3P/'" unless result == "3P/"
end

Test("sorts and formats mixed counts") do
  result = Hands.dump({ "R" => 1, "P" => 2, "B" => 1 }, {})
  raise "expected '2PBR/'" unless result == "2PBR/"
end

# ============================================================================
# DECORATED PIECES
# ============================================================================

puts
puts "decorated pieces:"

Test("dumps pieces with state modifiers") do
  result = Hands.dump({ "+P" => 2 }, {})
  raise "expected '2+P/'" unless result == "2+P/"
end

Test("dumps pieces with terminal markers") do
  result = Hands.dump({ "K^" => 1 }, {})
  raise "expected 'K^/'" unless result == "K^/"
end

Test("dumps fully decorated pieces") do
  result = Hands.dump({ "+K^'" => 2 }, {})
  raise "expected '2+K^'/'" unless result == "2+K^'/"
end

# ============================================================================
# RETURN TYPE
# ============================================================================

puts
puts "return type:"

Test("returns a String") do
  result = Hands.dump({}, {})
  raise "expected String" unless result.is_a?(String)
end

Test("always contains exactly one slash") do
  inputs = [
    [{}, {}],
    [{ "P" => 1 }, {}],
    [{}, { "p" => 1 }],
    [{ "P" => 2 }, { "p" => 1 }]
  ]
  inputs.each do |first_hand, second_hand|
    result = Hands.dump(first_hand, second_hand)
    slash_count = result.count("/")
    raise "expected 1 slash in '#{result}', got #{slash_count}" unless slash_count == 1
  end
end

# ============================================================================
# MODULE PROPERTIES
# ============================================================================

puts
puts "module properties:"

Test("module is frozen") do
  raise "expected frozen" unless Hands.frozen?
end

puts
puts "All Dumper::Hands tests passed!"
puts
