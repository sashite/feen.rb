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

run_test("dumps both empty hands") do
  result = Hands.dump({ first: [], second: [] })
  raise "expected '/'" unless result == "/"
end

# ============================================================================
# FIRST HAND ONLY
# ============================================================================

puts
puts "first hand only:"

run_test("dumps single piece in first hand") do
  result = Hands.dump({ first: ["P"], second: [] })
  raise "expected 'P/'" unless result == "P/"
end

run_test("dumps multiple distinct pieces in first hand") do
  result = Hands.dump({ first: ["P", "N"], second: [] })
  raise "expected 'NP/'" unless result == "NP/"
end

run_test("dumps aggregated pieces in first hand") do
  result = Hands.dump({ first: ["P", "P"], second: [] })
  raise "expected '2P/'" unless result == "2P/"
end

run_test("dumps complex first hand") do
  result = Hands.dump({ first: ["B", "B", "B", "P", "P", "N", "R"], second: [] })
  raise "expected '3B2PNR/'" unless result == "3B2PNR/"
end

# ============================================================================
# SECOND HAND ONLY
# ============================================================================

puts
puts "second hand only:"

run_test("dumps single piece in second hand") do
  result = Hands.dump({ first: [], second: ["p"] })
  raise "expected '/p'" unless result == "/p"
end

run_test("dumps aggregated pieces in second hand") do
  result = Hands.dump({ first: [], second: ["q", "q", "p"] })
  raise "expected '/2qp'" unless result == "/2qp"
end

# ============================================================================
# BOTH HANDS
# ============================================================================

puts
puts "both hands:"

run_test("dumps pieces in both hands") do
  result = Hands.dump({ first: ["P", "P", "N"], second: ["p"] })
  raise "expected '2PN/p'" unless result == "2PN/p"
end

run_test("dumps complex both hands") do
  result = Hands.dump({ first: ["B", "B", "B", "P", "P", "N", "R"], second: ["q", "q", "p"] })
  raise "expected '3B2PNR/2qp'" unless result == "3B2PNR/2qp"
end

# ============================================================================
# CANONICAL ORDERING
# ============================================================================

puts
puts "canonical ordering:"

run_test("sorts by multiplicity descending") do
  result = Hands.dump({ first: ["B", "B", "B", "P", "P"], second: [] })
  raise "expected '3B2P/'" unless result == "3B2P/"
end

run_test("sorts alphabetically at same count") do
  result = Hands.dump({ first: ["N", "B"], second: [] })
  raise "expected 'BN/'" unless result == "BN/"
end

run_test("sorts uppercase before lowercase for same letter") do
  result = Hands.dump({ first: ["P", "p"], second: [] })
  raise "expected 'Pp/'" unless result == "Pp/"
end

run_test("sorts diminished before enhanced before normal") do
  result = Hands.dump({ first: ["-P", "+P", "P"], second: [] })
  raise "expected '-P+PP/'" unless result == "-P+PP/"
end

run_test("sorts absent terminal before present terminal") do
  result = Hands.dump({ first: ["P", "P^"], second: [] })
  raise "expected 'PP^/'" unless result == "PP^/"
end

run_test("sorts absent derivation before present derivation") do
  result = Hands.dump({ first: ["P", "P'"], second: [] })
  raise "expected 'PP'/' but got '#{result}'" unless result == "PP'/"
end

# ============================================================================
# AGGREGATION
# ============================================================================

puts
puts "aggregation:"

run_test("aggregates identical pieces") do
  result = Hands.dump({ first: ["P", "P", "P"], second: [] })
  raise "expected '3P/'" unless result == "3P/"
end

run_test("aggregates and sorts mixed pieces") do
  result = Hands.dump({ first: ["R", "P", "P", "B"], second: [] })
  raise "expected '2PBR/'" unless result == "2PBR/"
end

run_test("does not aggregate different pieces") do
  result = Hands.dump({ first: ["P", "N", "B"], second: [] })
  raise "expected 'BNP/'" unless result == "BNP/"
end

run_test("handles single piece without count prefix") do
  result = Hands.dump({ first: ["P"], second: [] })
  raise "should not have count prefix" if result.start_with?("1")
end

# ============================================================================
# DECORATED PIECES
# ============================================================================

puts
puts "decorated pieces:"

run_test("dumps pieces with state modifiers") do
  result = Hands.dump({ first: ["+P", "+P"], second: [] })
  raise "expected '2+P/'" unless result == "2+P/"
end

run_test("dumps pieces with terminal markers") do
  result = Hands.dump({ first: ["K^"], second: [] })
  raise "expected 'K^/'" unless result == "K^/"
end

run_test("dumps fully decorated pieces") do
  result = Hands.dump({ first: ["+K^'", "+K^'"], second: [] })
  raise "expected '2+K^'/'" unless result == "2+K^'/"
end

# ============================================================================
# RETURN TYPE
# ============================================================================

puts
puts "return type:"

run_test("returns a String") do
  result = Hands.dump({ first: [], second: [] })
  raise "expected String" unless result.is_a?(String)
end

run_test("always contains exactly one slash") do
  inputs = [
    { first: [], second: [] },
    { first: ["P"], second: [] },
    { first: [], second: ["p"] },
    { first: ["P", "P"], second: ["p"] }
  ]
  inputs.each do |hands|
    result = Hands.dump(hands)
    slash_count = result.count("/")
    raise "expected 1 slash in '#{result}', got #{slash_count}" unless slash_count == 1
  end
end

# ============================================================================
# MODULE PROPERTIES
# ============================================================================

puts
puts "module properties:"

run_test("module is frozen") do
  raise "expected frozen" unless Hands.frozen?
end

puts
puts "All Dumper::Hands tests passed!"
puts
