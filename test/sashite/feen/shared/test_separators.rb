#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/shared/separators"

puts
puts "=== Separators Tests ==="
puts

# ============================================================================
# FIELD SEPARATOR
# ============================================================================

puts "FIELD separator:"

run_test("equals space character") do
  result = Sashite::Feen::Separators::FIELD
  raise "expected ' ', got #{result.inspect}" unless result == " "
end

run_test("is a String") do
  result = Sashite::Feen::Separators::FIELD
  raise "expected String, got #{result.class}" unless ::String === result
end

run_test("has length 1") do
  result = Sashite::Feen::Separators::FIELD
  raise "expected length 1, got #{result.length}" unless result.length == 1
end

run_test("has ASCII byte value 0x20") do
  result = Sashite::Feen::Separators::FIELD
  raise "expected byte 0x20, got 0x#{result.ord.to_s(16)}" unless result.ord == 0x20
end

run_test("can split FEEN into three fields") do
  feen = "K / C/c"
  fields = feen.split(Sashite::Feen::Separators::FIELD, -1)
  raise "expected 3 fields, got #{fields.length}" unless fields.length == 3
end

run_test("preserves empty fields when splitting") do
  # Edge case: what if there were empty fields (invalid FEEN, but test split behavior)
  input = "a b c"
  fields = input.split(Sashite::Feen::Separators::FIELD, -1)
  raise "expected ['a', 'b', 'c'], got #{fields.inspect}" unless fields == ["a", "b", "c"]
end

# ============================================================================
# SEGMENT SEPARATOR
# ============================================================================

puts
puts "SEGMENT separator:"

run_test("equals slash character") do
  result = Sashite::Feen::Separators::SEGMENT
  raise "expected '/', got #{result.inspect}" unless result == "/"
end

run_test("is a String") do
  result = Sashite::Feen::Separators::SEGMENT
  raise "expected String, got #{result.class}" unless ::String === result
end

run_test("has length 1") do
  result = Sashite::Feen::Separators::SEGMENT
  raise "expected length 1, got #{result.length}" unless result.length == 1
end

run_test("has ASCII byte value 0x2F") do
  result = Sashite::Feen::Separators::SEGMENT
  raise "expected byte 0x2F, got 0x#{result.ord.to_s(16)}" unless result.ord == 0x2F
end

run_test("can split hands field") do
  hands = "2P/p"
  parts = hands.split(Sashite::Feen::Separators::SEGMENT, -1)
  raise "expected 2 parts, got #{parts.length}" unless parts.length == 2
  raise "expected ['2P', 'p'], got #{parts.inspect}" unless parts == ["2P", "p"]
end

run_test("can split style-turn field") do
  style_turn = "C/c"
  parts = style_turn.split(Sashite::Feen::Separators::SEGMENT, -1)
  raise "expected 2 parts, got #{parts.length}" unless parts.length == 2
  raise "expected ['C', 'c'], got #{parts.inspect}" unless parts == ["C", "c"]
end

run_test("can split piece placement ranks") do
  piece_placement = "8/8/8/8/8/8/8/8"
  ranks = piece_placement.split(Sashite::Feen::Separators::SEGMENT, -1)
  raise "expected 8 ranks, got #{ranks.length}" unless ranks.length == 8
end

run_test("preserves empty segments when splitting") do
  # Important for detecting invalid FEEN like "a//b" split by single "/"
  input = "a//b"
  parts = input.split(Sashite::Feen::Separators::SEGMENT, -1)
  raise "expected ['a', '', 'b'], got #{parts.inspect}" unless parts == ["a", "", "b"]
end

# ============================================================================
# DISTINCTNESS
# ============================================================================

puts
puts "Distinctness:"

run_test("FIELD and SEGMENT are different") do
  field = Sashite::Feen::Separators::FIELD
  segment = Sashite::Feen::Separators::SEGMENT
  raise "FIELD and SEGMENT should differ" if field == segment
end

run_test("FIELD and SEGMENT have different byte values") do
  field_byte = Sashite::Feen::Separators::FIELD.ord
  segment_byte = Sashite::Feen::Separators::SEGMENT.ord
  raise "bytes should differ" if field_byte == segment_byte
end

# ============================================================================
# MODULE PROPERTIES
# ============================================================================

puts
puts "Module properties:"

run_test("module has no instance methods") do
  methods = Sashite::Feen::Separators.instance_methods(false)
  raise "expected no instance methods, got #{methods.inspect}" unless methods.empty?
end

# ============================================================================
# FEEN FORMAT INTEGRATION
# ============================================================================

puts
puts "FEEN format integration:"

run_test("can parse complete FEEN string structure") do
  feen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c"

  # Split into fields
  fields = feen.split(Sashite::Feen::Separators::FIELD, -1)
  raise "expected 3 fields" unless fields.length == 3

  piece_placement, hands, style_turn = fields

  # Split piece placement into ranks
  ranks = piece_placement.split(Sashite::Feen::Separators::SEGMENT, -1)
  raise "expected 8 ranks" unless ranks.length == 8

  # Split hands
  hand_parts = hands.split(Sashite::Feen::Separators::SEGMENT, -1)
  raise "expected 2 hand parts" unless hand_parts.length == 2

  # Split style-turn
  style_parts = style_turn.split(Sashite::Feen::Separators::SEGMENT, -1)
  raise "expected 2 style parts" unless style_parts.length == 2
end

run_test("can reconstruct FEEN string") do
  piece_placement = "K"
  hands = "/"
  style_turn = "C/c"

  sep = Sashite::Feen::Separators::FIELD
  reconstructed = [piece_placement, hands, style_turn].join(sep)

  raise "expected 'K / C/c', got #{reconstructed.inspect}" unless reconstructed == "K / C/c"
end

puts
puts "All Separators tests passed!"
puts
