#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/position/piece_placement"

puts
puts "=== Position::PiecePlacement Tests ==="
puts

PiecePlacement = Sashite::Feen::Position::PiecePlacement

# Simple mock piece for testing (responds to to_s)
MockPiece = Struct.new(:name) do
  def to_s
    name
  end
end

# ============================================================================
# INITIALIZATION
# ============================================================================

puts "initialization:"

run_test("creates instance with valid segments and separators") do
  placement = PiecePlacement.send(:new, segments: [[1]], separators: [])
  raise "expected PiecePlacement instance" unless PiecePlacement === placement
end

run_test("creates instance with empty segments array") do
  placement = PiecePlacement.send(:new, segments: [], separators: [])
  raise "expected PiecePlacement instance" unless PiecePlacement === placement
end

run_test("raises ArgumentError when segments is not an Array") do
  PiecePlacement.send(:new, segments: "not array", separators: [])
  raise "expected ArgumentError"
rescue ArgumentError => e
  raise "wrong message" unless e.message.include?("segments must be an Array")
end

run_test("raises ArgumentError when separators is not an Array") do
  PiecePlacement.send(:new, segments: [[1]], separators: "not array")
  raise "expected ArgumentError"
rescue ArgumentError => e
  raise "wrong message" unless e.message.include?("separators must be an Array")
end

run_test("raises ArgumentError when segment is not an Array") do
  PiecePlacement.send(:new, segments: ["not array"], separators: [])
  raise "expected ArgumentError"
rescue ArgumentError => e
  raise "wrong message" unless e.message.include?("segment at index 0 must be an Array")
end

run_test("raises ArgumentError when separator is not a String") do
  PiecePlacement.send(:new, segments: [[1], [1]], separators: [123])
  raise "expected ArgumentError"
rescue ArgumentError => e
  raise "wrong message" unless e.message.include?("separator at index 0 must be a String")
end

# ============================================================================
# ACCESSORS
# ============================================================================

puts
puts "accessors:"

run_test("segments returns the segments array") do
  segments = [[MockPiece.new("K"), 3]]
  placement = PiecePlacement.send(:new, segments: segments, separators: [])
  raise "wrong segments" unless placement.segments == segments
end

run_test("separators returns the separators array") do
  separators = ["/", "/"]
  placement = PiecePlacement.send(:new, segments: [[1], [1], [1]], separators: separators)
  raise "wrong separators" unless placement.separators == separators
end

# ============================================================================
# SQUARES_COUNT
# ============================================================================

puts
puts "squares_count:"

run_test("returns 0 for empty segments") do
  placement = PiecePlacement.send(:new, segments: [], separators: [])
  raise "expected 0" unless placement.squares_count == 0
end

run_test("counts single empty count") do
  placement = PiecePlacement.send(:new, segments: [[8]], separators: [])
  raise "expected 8" unless placement.squares_count == 8
end

run_test("counts single piece as 1") do
  placement = PiecePlacement.send(:new, segments: [[MockPiece.new("K")]], separators: [])
  raise "expected 1" unless placement.squares_count == 1
end

run_test("counts mixed segment correctly") do
  # K + 3 empty + Q = 5 squares
  placement = PiecePlacement.send(:new,
    segments: [[MockPiece.new("K"), 3, MockPiece.new("Q")]],
    separators: []
  )
  raise "expected 5" unless placement.squares_count == 5
end

run_test("counts multiple segments") do
  # Segment 1: 8 empty = 8
  # Segment 2: 8 empty = 8
  # Total: 16
  placement = PiecePlacement.send(:new,
    segments: [[8], [8]],
    separators: ["/"]
  )
  raise "expected 16" unless placement.squares_count == 16
end

run_test("counts chess-like board (64 squares)") do
  # 8 ranks of 8 squares each
  segments = Array.new(8) { [8] }
  separators = Array.new(7) { "/" }
  placement = PiecePlacement.send(:new, segments: segments, separators: separators)
  raise "expected 64" unless placement.squares_count == 64
end

# ============================================================================
# PIECES_COUNT
# ============================================================================

puts
puts "pieces_count:"

run_test("returns 0 for empty segments") do
  placement = PiecePlacement.send(:new, segments: [], separators: [])
  raise "expected 0" unless placement.pieces_count == 0
end

run_test("returns 0 for board with only empty squares") do
  placement = PiecePlacement.send(:new, segments: [[8], [8]], separators: ["/"])
  raise "expected 0" unless placement.pieces_count == 0
end

run_test("counts single piece") do
  placement = PiecePlacement.send(:new, segments: [[MockPiece.new("K")]], separators: [])
  raise "expected 1" unless placement.pieces_count == 1
end

run_test("counts multiple pieces in one segment") do
  placement = PiecePlacement.send(:new,
    segments: [[MockPiece.new("K"), 2, MockPiece.new("Q"), MockPiece.new("R")]],
    separators: []
  )
  raise "expected 3" unless placement.pieces_count == 3
end

run_test("counts pieces across multiple segments") do
  placement = PiecePlacement.send(:new,
    segments: [[MockPiece.new("K"), 7], [8], [MockPiece.new("k"), 7]],
    separators: ["/", "/"]
  )
  raise "expected 2" unless placement.pieces_count == 2
end

# ============================================================================
# DIMENSIONS
# ============================================================================

puts
puts "dimensions:"

run_test("returns 1 for empty separators (1D board)") do
  placement = PiecePlacement.send(:new, segments: [[MockPiece.new("K"), 2, MockPiece.new("Q")]], separators: [])
  raise "expected 1" unless placement.dimensions == 1
end

run_test("returns 2 for single-slash separators (2D board)") do
  placement = PiecePlacement.send(:new,
    segments: [[8], [8], [8]],
    separators: ["/", "/"]
  )
  raise "expected 2" unless placement.dimensions == 2
end

run_test("returns 3 for double-slash separators (3D board)") do
  placement = PiecePlacement.send(:new,
    segments: [[4], [4], [4], [4]],
    separators: ["/", "//", "/"]
  )
  raise "expected 3" unless placement.dimensions == 3
end

run_test("returns dimension based on max separator length") do
  # Mix of "/" and "//" means 3D
  placement = PiecePlacement.send(:new,
    segments: [[1], [1], [1], [1], [1]],
    separators: ["/", "/", "//", "/"]
  )
  raise "expected 3" unless placement.dimensions == 3
end

# ============================================================================
# EACH (ENUMERABLE)
# ============================================================================

puts
puts "each:"

run_test("returns Enumerator when no block given") do
  placement = PiecePlacement.send(:new, segments: [[1]], separators: [])
  enum = placement.each
  raise "expected Enumerator" unless Enumerator === enum
end

run_test("yields nothing for empty segments") do
  placement = PiecePlacement.send(:new, segments: [], separators: [])
  tokens = placement.each.to_a
  raise "expected empty array" unless tokens == []
end

run_test("yields tokens in order") do
  k = MockPiece.new("K")
  q = MockPiece.new("Q")
  placement = PiecePlacement.send(:new, segments: [[k, 2, q]], separators: [])
  tokens = placement.each.to_a
  raise "expected [k, 2, q]" unless tokens == [k, 2, q]
end

run_test("yields tokens across segments") do
  k = MockPiece.new("K")
  q = MockPiece.new("Q")
  placement = PiecePlacement.send(:new,
    segments: [[k, 3], [4], [q]],
    separators: ["/", "/"]
  )
  tokens = placement.each.to_a
  raise "expected [k, 3, 4, q]" unless tokens == [k, 3, 4, q]
end

run_test("supports Enumerable methods via each") do
  placement = PiecePlacement.send(:new,
    segments: [[MockPiece.new("K"), 3, MockPiece.new("Q")]],
    separators: []
  )
  count = placement.count { |t| ::Integer === t }
  raise "expected 1 integer" unless count == 1
end

run_test("map works correctly") do
  placement = PiecePlacement.send(:new, segments: [[1, 2, 3]], separators: [])
  result = placement.map { |t| t * 2 }
  raise "expected [2, 4, 6]" unless result == [2, 4, 6]
end

# ============================================================================
# TO_S
# ============================================================================

puts
puts "to_s:"

run_test("returns empty string for empty segments") do
  placement = PiecePlacement.send(:new, segments: [], separators: [])
  raise "expected empty string" unless placement.to_s == ""
end

run_test("serializes single segment without separator") do
  placement = PiecePlacement.send(:new,
    segments: [[MockPiece.new("K"), 2, MockPiece.new("Q")]],
    separators: []
  )
  raise "expected K2Q" unless placement.to_s == "K2Q"
end

run_test("serializes multiple segments with separators") do
  placement = PiecePlacement.send(:new,
    segments: [[8], [8], [8]],
    separators: ["/", "/"]
  )
  raise "expected 8/8/8" unless placement.to_s == "8/8/8"
end

run_test("serializes 3D board with double-slash separators") do
  placement = PiecePlacement.send(:new,
    segments: [[4], [4], [4], [4]],
    separators: ["/", "//", "/"]
  )
  raise "expected 4/4//4/4" unless placement.to_s == "4/4//4/4"
end

run_test("serializes mixed content correctly") do
  placement = PiecePlacement.send(:new,
    segments: [[MockPiece.new("r"), MockPiece.new("n"), 4, MockPiece.new("k")], [8]],
    separators: ["/"]
  )
  raise "expected rn4k/8" unless placement.to_s == "rn4k/8"
end

# ============================================================================
# EQUALITY (==)
# ============================================================================

puts
puts "equality:"

run_test("equal when segments and separators match") do
  a = PiecePlacement.send(:new, segments: [[8], [8]], separators: ["/"])
  b = PiecePlacement.send(:new, segments: [[8], [8]], separators: ["/"])
  raise "expected equal" unless a == b
end

run_test("not equal when segments differ") do
  a = PiecePlacement.send(:new, segments: [[8], [8]], separators: ["/"])
  b = PiecePlacement.send(:new, segments: [[4], [4]], separators: ["/"])
  raise "expected not equal" if a == b
end

run_test("not equal when separators differ") do
  a = PiecePlacement.send(:new, segments: [[4], [4], [4], [4]], separators: ["/", "/", "/"])
  b = PiecePlacement.send(:new, segments: [[4], [4], [4], [4]], separators: ["/", "//", "/"])
  raise "expected not equal" if a == b
end

run_test("not equal to nil") do
  a = PiecePlacement.send(:new, segments: [[8]], separators: [])
  raise "expected not equal" if a == nil
end

run_test("not equal to other types") do
  a = PiecePlacement.send(:new, segments: [[8]], separators: [])
  raise "not equal to String" if a == "8"
  raise "not equal to Array" if a == [[8]]
  raise "not equal to Hash" if a == { segments: [[8]], separators: [] }
end

run_test("eql? behaves like ==") do
  a = PiecePlacement.send(:new, segments: [[8], [8]], separators: ["/"])
  b = PiecePlacement.send(:new, segments: [[8], [8]], separators: ["/"])
  c = PiecePlacement.send(:new, segments: [[4], [4]], separators: ["/"])
  raise "expected eql?" unless a.eql?(b)
  raise "expected not eql?" if a.eql?(c)
end

# ============================================================================
# HASH
# ============================================================================

puts
puts "hash:"

run_test("equal objects have equal hash codes") do
  a = PiecePlacement.send(:new, segments: [[8], [8]], separators: ["/"])
  b = PiecePlacement.send(:new, segments: [[8], [8]], separators: ["/"])
  raise "expected equal hashes" unless a.hash == b.hash
end

run_test("can be used as hash key") do
  a = PiecePlacement.send(:new, segments: [[8], [8]], separators: ["/"])
  b = PiecePlacement.send(:new, segments: [[8], [8]], separators: ["/"])
  hash = { a => "value" }
  raise "expected to find by equal key" unless hash[b] == "value"
end

# ============================================================================
# INSPECT
# ============================================================================

puts
puts "inspect:"

run_test("includes class name") do
  placement = PiecePlacement.send(:new, segments: [[8]], separators: [])
  raise "expected class name" unless placement.inspect.include?("PiecePlacement")
end

run_test("includes string representation") do
  placement = PiecePlacement.send(:new, segments: [[8], [8]], separators: ["/"])
  raise "expected to_s content" unless placement.inspect.include?("8/8")
end

# ============================================================================
# REAL-WORLD EXAMPLES
# ============================================================================

puts
puts "real-world examples:"

run_test("chess initial position metrics") do
  # Simulated chess position: pieces on ranks 1, 2, 7, 8; empty in between
  # Using simple strings as mock pieces
  r = MockPiece.new("r")
  n = MockPiece.new("n")
  b = MockPiece.new("b")
  q = MockPiece.new("q")
  k = MockPiece.new("k")
  p_piece = MockPiece.new("p")

  segments = [
    [r, n, b, q, k, b, n, r],  # rank 8
    Array.new(8) { p_piece },  # rank 7
    [8],                        # rank 6
    [8],                        # rank 5
    [8],                        # rank 4
    [8],                        # rank 3
    Array.new(8) { MockPiece.new("P") },  # rank 2
    [MockPiece.new("R"), MockPiece.new("N"), MockPiece.new("B"), MockPiece.new("Q"),
     MockPiece.new("K"), MockPiece.new("B"), MockPiece.new("N"), MockPiece.new("R")]  # rank 1
  ]
  separators = ["/", "/", "/", "/", "/", "/", "/"]

  placement = PiecePlacement.send(:new, segments: segments, separators: separators)

  raise "expected 64 squares" unless placement.squares_count == 64
  raise "expected 32 pieces" unless placement.pieces_count == 32
  raise "expected 2D" unless placement.dimensions == 2
end

run_test("1D board example") do
  # Linear board: K--Q (King, 2 empty, Queen)
  placement = PiecePlacement.send(:new,
    segments: [[MockPiece.new("K"), 2, MockPiece.new("Q")]],
    separators: []
  )

  raise "expected 4 squares" unless placement.squares_count == 4
  raise "expected 2 pieces" unless placement.pieces_count == 2
  raise "expected 1D" unless placement.dimensions == 1
  raise "expected K2Q" unless placement.to_s == "K2Q"
end

run_test("3D board example") do
  # 2x2x2 cube: 2 layers of 2 ranks
  placement = PiecePlacement.send(:new,
    segments: [[2], [2], [2], [2]],
    separators: ["/", "//", "/"]
  )

  raise "expected 8 squares" unless placement.squares_count == 8
  raise "expected 0 pieces" unless placement.pieces_count == 0
  raise "expected 3D" unless placement.dimensions == 3
  raise "expected 2/2//2/2" unless placement.to_s == "2/2//2/2"
end

puts
puts "All Position::PiecePlacement tests passed!"
puts
