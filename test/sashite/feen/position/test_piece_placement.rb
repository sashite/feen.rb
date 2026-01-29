#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/position/piece_placement"

require "sashite/epin"

puts
puts "=== Position::PiecePlacement Tests ==="
puts

# ============================================================================
# CONSTRUCTOR TESTS
# ============================================================================

puts "Constructor:"

run_test("creates PiecePlacement with single segment") do
  piece = Sashite::Epin.parse("K")
  pp = Sashite::Feen::Position::PiecePlacement.new(
    segments: [[piece]],
    separators: []
  )
  raise "wrong segment count" unless pp.segments.size == 1
  raise "wrong separator count" unless pp.separators.empty?
end

run_test("creates PiecePlacement with multiple segments") do
  k = Sashite::Epin.parse("K")
  q = Sashite::Epin.parse("Q")
  pp = Sashite::Feen::Position::PiecePlacement.new(
    segments: [[k], [q]],
    separators: ["/"]
  )
  raise "wrong segment count" unless pp.segments.size == 2
  raise "wrong separator count" unless pp.separators.size == 1
end

run_test("creates PiecePlacement with empty counts") do
  pp = Sashite::Feen::Position::PiecePlacement.new(
    segments: [[8]],
    separators: []
  )
  raise "wrong token" unless pp.segments[0][0] == 8
end

run_test("creates PiecePlacement with mixed tokens") do
  k = Sashite::Epin.parse("K")
  pp = Sashite::Feen::Position::PiecePlacement.new(
    segments: [[3, k, 4]],
    separators: []
  )
  raise "wrong token count" unless pp.segments[0].size == 3
  raise "first token wrong" unless pp.segments[0][0] == 3
  raise "second token wrong" unless pp.segments[0][1] == k
  raise "third token wrong" unless pp.segments[0][2] == 4
end

run_test("creates PiecePlacement with double separators") do
  pp = Sashite::Feen::Position::PiecePlacement.new(
    segments: [[8], [8], [8]],
    separators: ["/", "//"]
  )
  raise "wrong separator 0" unless pp.separators[0] == "/"
  raise "wrong separator 1" unless pp.separators[1] == "//"
end

# ============================================================================
# IMMUTABILITY TESTS
# ============================================================================

puts
puts "Immutability:"

run_test("PiecePlacement is frozen after creation") do
  pp = Sashite::Feen::Position::PiecePlacement.new(
    segments: [[8]],
    separators: []
  )
  raise "should be frozen" unless pp.frozen?
end

# ============================================================================
# ATTRIBUTE ACCESSORS
# ============================================================================

puts
puts "Attribute accessors:"

run_test("segments returns the segments array") do
  k = Sashite::Epin.parse("K")
  segments = [[k], [8]]
  pp = Sashite::Feen::Position::PiecePlacement.new(
    segments: segments,
    separators: ["/"]
  )
  raise "wrong segments" unless pp.segments == segments
end

run_test("separators returns the separators array") do
  separators = ["/", "//"]
  pp = Sashite::Feen::Position::PiecePlacement.new(
    segments: [[8], [8], [8]],
    separators: separators
  )
  raise "wrong separators" unless pp.separators == separators
end

# ============================================================================
# EACH_SEGMENT TESTS
# ============================================================================

puts
puts "each_segment:"

run_test("iterates over all segments") do
  k = Sashite::Epin.parse("K")
  q = Sashite::Epin.parse("Q")
  pp = Sashite::Feen::Position::PiecePlacement.new(
    segments: [[k], [8], [q]],
    separators: ["/", "/"]
  )

  collected = []
  pp.each_segment { |seg| collected << seg }

  raise "wrong count" unless collected.size == 3
  raise "first segment wrong" unless collected[0][0] == k
  raise "second segment wrong" unless collected[1][0] == 8
  raise "third segment wrong" unless collected[2][0] == q
end

run_test("returns enumerator without block") do
  pp = Sashite::Feen::Position::PiecePlacement.new(
    segments: [[8]],
    separators: []
  )
  raise "should return Enumerator" unless pp.each_segment.is_a?(Enumerator)
end

run_test("returns self with block") do
  pp = Sashite::Feen::Position::PiecePlacement.new(
    segments: [[8]],
    separators: []
  )
  result = pp.each_segment { |_| }
  raise "should return self" unless result.equal?(pp)
end

# ============================================================================
# TO_A TESTS
# ============================================================================

puts
puts "to_a:"

run_test("returns flat array of all tokens") do
  k = Sashite::Epin.parse("K")
  q = Sashite::Epin.parse("Q")
  pp = Sashite::Feen::Position::PiecePlacement.new(
    segments: [[3, k], [q, 2]],
    separators: ["/"]
  )

  result = pp.to_a

  raise "wrong size" unless result.size == 4
  raise "token 0 wrong" unless result[0] == 3
  raise "token 1 wrong" unless result[1] == k
  raise "token 2 wrong" unless result[2] == q
  raise "token 3 wrong" unless result[3] == 2
end

run_test("returns empty array for empty segments") do
  pp = Sashite::Feen::Position::PiecePlacement.new(
    segments: [[]],
    separators: []
  )
  raise "should be empty" unless pp.to_a.empty?
end

# ============================================================================
# TO_S TESTS - SINGLE SEGMENT
# ============================================================================

puts
puts "to_s - single segment:"

run_test("returns 'K' for single piece") do
  k = Sashite::Epin.parse("K")
  pp = Sashite::Feen::Position::PiecePlacement.new(
    segments: [[k]],
    separators: []
  )
  raise "wrong string: #{pp.to_s}" unless pp.to_s == "K"
end

run_test("returns '8' for empty count") do
  pp = Sashite::Feen::Position::PiecePlacement.new(
    segments: [[8]],
    separators: []
  )
  raise "wrong string: #{pp.to_s}" unless pp.to_s == "8"
end

run_test("returns 'KQR' for multiple pieces") do
  k = Sashite::Epin.parse("K")
  q = Sashite::Epin.parse("Q")
  r = Sashite::Epin.parse("R")
  pp = Sashite::Feen::Position::PiecePlacement.new(
    segments: [[k, q, r]],
    separators: []
  )
  raise "wrong string: #{pp.to_s}" unless pp.to_s == "KQR"
end

run_test("returns '3K2' for mixed tokens") do
  k = Sashite::Epin.parse("K")
  pp = Sashite::Feen::Position::PiecePlacement.new(
    segments: [[3, k, 2]],
    separators: []
  )
  raise "wrong string: #{pp.to_s}" unless pp.to_s == "3K2"
end

# ============================================================================
# TO_S TESTS - MULTIPLE SEGMENTS
# ============================================================================

puts
puts "to_s - multiple segments:"

run_test("returns 'K/Q' for two segments") do
  k = Sashite::Epin.parse("K")
  q = Sashite::Epin.parse("Q")
  pp = Sashite::Feen::Position::PiecePlacement.new(
    segments: [[k], [q]],
    separators: ["/"]
  )
  raise "wrong string: #{pp.to_s}" unless pp.to_s == "K/Q"
end

run_test("returns '8/8/8' for three empty segments") do
  pp = Sashite::Feen::Position::PiecePlacement.new(
    segments: [[8], [8], [8]],
    separators: ["/", "/"]
  )
  raise "wrong string: #{pp.to_s}" unless pp.to_s == "8/8/8"
end

run_test("returns 'K//Q' with double separator") do
  k = Sashite::Epin.parse("K")
  q = Sashite::Epin.parse("Q")
  pp = Sashite::Feen::Position::PiecePlacement.new(
    segments: [[k], [q]],
    separators: ["//"]
  )
  raise "wrong string: #{pp.to_s}" unless pp.to_s == "K//Q"
end

run_test("returns '8/8//8/8' for mixed separators") do
  pp = Sashite::Feen::Position::PiecePlacement.new(
    segments: [[8], [8], [8], [8]],
    separators: ["/", "//", "/"]
  )
  raise "wrong string: #{pp.to_s}" unless pp.to_s == "8/8//8/8"
end

run_test("returns 'K///Q' with triple separator") do
  k = Sashite::Epin.parse("K")
  q = Sashite::Epin.parse("Q")
  pp = Sashite::Feen::Position::PiecePlacement.new(
    segments: [[k], [q]],
    separators: ["///"]
  )
  raise "wrong string: #{pp.to_s}" unless pp.to_s == "K///Q"
end

# ============================================================================
# TO_S TESTS - EPIN MODIFIERS
# ============================================================================

puts
puts "to_s - EPIN modifiers:"

run_test("handles enhanced pieces") do
  k = Sashite::Epin.parse("+K")
  pp = Sashite::Feen::Position::PiecePlacement.new(
    segments: [[k]],
    separators: []
  )
  raise "wrong string: #{pp.to_s}" unless pp.to_s == "+K"
end

run_test("handles diminished pieces") do
  k = Sashite::Epin.parse("-K")
  pp = Sashite::Feen::Position::PiecePlacement.new(
    segments: [[k]],
    separators: []
  )
  raise "wrong string: #{pp.to_s}" unless pp.to_s == "-K"
end

run_test("handles terminal pieces") do
  k = Sashite::Epin.parse("K^")
  pp = Sashite::Feen::Position::PiecePlacement.new(
    segments: [[k]],
    separators: []
  )
  raise "wrong string: #{pp.to_s}" unless pp.to_s == "K^"
end

run_test("handles derived pieces") do
  k = Sashite::Epin.parse("K'")
  pp = Sashite::Feen::Position::PiecePlacement.new(
    segments: [[k]],
    separators: []
  )
  raise "wrong string: #{pp.to_s}" unless pp.to_s == "K'"
end

run_test("handles all modifiers combined") do
  k = Sashite::Epin.parse("+K^'")
  pp = Sashite::Feen::Position::PiecePlacement.new(
    segments: [[k]],
    separators: []
  )
  raise "wrong string: #{pp.to_s}" unless pp.to_s == "+K^'"
end

run_test("handles lowercase pieces") do
  k = Sashite::Epin.parse("k")
  pp = Sashite::Feen::Position::PiecePlacement.new(
    segments: [[k]],
    separators: []
  )
  raise "wrong string: #{pp.to_s}" unless pp.to_s == "k"
end

# ============================================================================
# TO_S TESTS - REALISTIC EXAMPLES
# ============================================================================

puts
puts "to_s - realistic examples:"

run_test("returns Chess initial position") do
  # Build the chess initial position
  rank8 = "rnbqkbnr".chars.map { |c| Sashite::Epin.parse(c) }
  rank7 = "pppppppp".chars.map { |c| Sashite::Epin.parse(c) }
  rank2 = "PPPPPPPP".chars.map { |c| Sashite::Epin.parse(c) }
  rank1 = "RNBQKBNR".chars.map { |c| Sashite::Epin.parse(c) }

  pp = Sashite::Feen::Position::PiecePlacement.new(
    segments: [rank8, rank7, [8], [8], [8], [8], rank2, rank1],
    separators: ["/", "/", "/", "/", "/", "/", "/"]
  )

  expected = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
  raise "wrong string: #{pp.to_s}" unless pp.to_s == expected
end

run_test("returns 3D Raumschach layer structure") do
  k = Sashite::Epin.parse("K")
  q = Sashite::Epin.parse("k")

  # 5 layers of 5x5, with pieces on layer 2 and 4
  pp = Sashite::Feen::Position::PiecePlacement.new(
    segments: [
      [5], [5], [5], [5], [5],  # layer 1
      [5], [5], [2, k, 2], [5], [5],  # layer 2 with K
      [5], [5], [5], [5], [5],  # layer 3
      [5], [5], [2, q, 2], [5], [5],  # layer 4 with k
      [5], [5], [5], [5], [5]   # layer 5
    ],
    separators: [
      "/", "/", "/", "/",   # within layer 1
      "//",                  # between layer 1-2
      "/", "/", "/", "/",   # within layer 2
      "//",                  # between layer 2-3
      "/", "/", "/", "/",   # within layer 3
      "//",                  # between layer 3-4
      "/", "/", "/", "/",   # within layer 4
      "//",                  # between layer 4-5
      "/", "/", "/", "/"    # within layer 5
    ]
  )

  result = pp.to_s
  raise "should contain double separator" unless result.include?("//")
  raise "should contain pieces" unless result.include?("K") && result.include?("k")
end

# ============================================================================
# EQUALITY TESTS
# ============================================================================

puts
puts "Equality:"

run_test("equal PiecePlacements are ==") do
  k = Sashite::Epin.parse("K")
  pp1 = Sashite::Feen::Position::PiecePlacement.new(
    segments: [[k], [8]],
    separators: ["/"]
  )
  pp2 = Sashite::Feen::Position::PiecePlacement.new(
    segments: [[k], [8]],
    separators: ["/"]
  )
  raise "should be equal" unless pp1 == pp2
end

run_test("different segments are not ==") do
  k = Sashite::Epin.parse("K")
  q = Sashite::Epin.parse("Q")
  pp1 = Sashite::Feen::Position::PiecePlacement.new(
    segments: [[k]],
    separators: []
  )
  pp2 = Sashite::Feen::Position::PiecePlacement.new(
    segments: [[q]],
    separators: []
  )
  raise "should not be equal" if pp1 == pp2
end

run_test("different separators are not ==") do
  pp1 = Sashite::Feen::Position::PiecePlacement.new(
    segments: [[8], [8]],
    separators: ["/"]
  )
  pp2 = Sashite::Feen::Position::PiecePlacement.new(
    segments: [[8], [8]],
    separators: ["//"]
  )
  raise "should not be equal" if pp1 == pp2
end

run_test("different empty counts are not ==") do
  pp1 = Sashite::Feen::Position::PiecePlacement.new(
    segments: [[8]],
    separators: []
  )
  pp2 = Sashite::Feen::Position::PiecePlacement.new(
    segments: [[9]],
    separators: []
  )
  raise "should not be equal" if pp1 == pp2
end

run_test("eql? is aliased to ==") do
  k = Sashite::Epin.parse("K")
  pp1 = Sashite::Feen::Position::PiecePlacement.new(
    segments: [[k]],
    separators: []
  )
  pp2 = Sashite::Feen::Position::PiecePlacement.new(
    segments: [[k]],
    separators: []
  )
  raise "eql? should work" unless pp1.eql?(pp2)
end

run_test("equal PiecePlacements have same hash") do
  k = Sashite::Epin.parse("K")
  pp1 = Sashite::Feen::Position::PiecePlacement.new(
    segments: [[k], [8]],
    separators: ["/"]
  )
  pp2 = Sashite::Feen::Position::PiecePlacement.new(
    segments: [[k], [8]],
    separators: ["/"]
  )
  raise "hash should match" unless pp1.hash == pp2.hash
end

run_test("can be used as hash key") do
  k = Sashite::Epin.parse("K")
  pp1 = Sashite::Feen::Position::PiecePlacement.new(
    segments: [[k]],
    separators: []
  )
  pp2 = Sashite::Feen::Position::PiecePlacement.new(
    segments: [[k]],
    separators: []
  )

  hash = { pp1 => "value" }
  raise "should find by equal key" unless hash[pp2] == "value"
end

puts
puts "All Position::PiecePlacement tests passed!"
puts
