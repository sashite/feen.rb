#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../helper"
require_relative "../../../lib/sashite/feen/position"

puts
puts "=== Position Tests ==="
puts

Position = Sashite::Feen::Position

# Mock style object that responds to :side and :to_s
MockStyle = Struct.new(:side, :abbr) do
  def to_s
    side == :first ? abbr.to_s.upcase : abbr.to_s.downcase
  end
end

# Mock piece for board (responds to to_s)
MockPiece = Struct.new(:name) do
  def to_s
    name
  end
end

# Helper to create a simple position
def create_position(
  segments: [[8]],
  separators: [],
  first_hand: [],
  second_hand: [],
  active_side: :first,
  active_abbr: :C,
  inactive_abbr: :C
)
  inactive_side = active_side == :first ? :second : :first
  Position.new(
    piece_placement: { segments: segments, separators: separators },
    hands: { first: first_hand, second: second_hand },
    style_turn: {
      active: MockStyle.new(active_side, active_abbr),
      inactive: MockStyle.new(inactive_side, inactive_abbr)
    }
  )
end

# ============================================================================
# INITIALIZATION
# ============================================================================

puts "initialization:"

run_test("creates instance with valid components") do
  position = create_position
  raise "expected Position instance" unless Position === position
end

run_test("creates instance with empty board") do
  position = create_position(segments: [[64]], separators: [])
  raise "expected Position instance" unless Position === position
end

run_test("creates instance with pieces on board") do
  k = MockPiece.new("K")
  q = MockPiece.new("Q")
  position = create_position(segments: [[k, 6, q]], separators: [])
  raise "expected Position instance" unless Position === position
end

run_test("creates instance with pieces in hands") do
  position = create_position(
    first_hand: [{ piece: "P", count: 2 }],
    second_hand: [{ piece: "p", count: 1 }]
  )
  raise "expected Position instance" unless Position === position
end

run_test("creates instance with 2D board") do
  position = create_position(
    segments: [[8], [8], [8], [8], [8], [8], [8], [8]],
    separators: ["/", "/", "/", "/", "/", "/", "/"]
  )
  raise "expected Position instance" unless Position === position
end

run_test("creates instance with 3D board") do
  position = create_position(
    segments: [[4], [4], [4], [4]],
    separators: ["/", "//", "/"]
  )
  raise "expected Position instance" unless Position === position
end

run_test("creates instance with cross-style game") do
  position = create_position(active_abbr: :C, inactive_abbr: :S)
  raise "expected Position instance" unless Position === position
end

run_test("creates instance with second to move") do
  position = create_position(active_side: :second)
  raise "expected Position instance" unless Position === position
end

# ============================================================================
# ACCESSORS
# ============================================================================

puts
puts "accessors:"

run_test("piece_placement returns PiecePlacement") do
  position = create_position
  raise "wrong type" unless position.piece_placement.respond_to?(:squares_count)
  raise "wrong type" unless position.piece_placement.respond_to?(:pieces_count)
  raise "wrong type" unless position.piece_placement.respond_to?(:dimensions)
end

run_test("hands returns Hands") do
  position = create_position
  raise "wrong type" unless position.hands.respond_to?(:first)
  raise "wrong type" unless position.hands.respond_to?(:second)
  raise "wrong type" unless position.hands.respond_to?(:pieces_count)
end

run_test("style_turn returns StyleTurn") do
  position = create_position
  raise "wrong type" unless position.style_turn.respond_to?(:active_style)
  raise "wrong type" unless position.style_turn.respond_to?(:inactive_style)
  raise "wrong type" unless position.style_turn.respond_to?(:first_to_move?)
end

# ============================================================================
# SQUARES_COUNT
# ============================================================================

puts
puts "squares_count:"

run_test("returns count for 1D board") do
  position = create_position(segments: [[8]], separators: [])
  raise "expected 8" unless position.squares_count == 8
end

run_test("returns count for 2D board (chess-like)") do
  position = create_position(
    segments: [[8], [8], [8], [8], [8], [8], [8], [8]],
    separators: ["/", "/", "/", "/", "/", "/", "/"]
  )
  raise "expected 64" unless position.squares_count == 64
end

run_test("returns count for board with pieces") do
  k = MockPiece.new("K")
  position = create_position(segments: [[k, 3, k]], separators: [])
  raise "expected 5" unless position.squares_count == 5
end

run_test("returns count for 3D board") do
  position = create_position(
    segments: [[4], [4], [4], [4]],
    separators: ["/", "//", "/"]
  )
  raise "expected 16" unless position.squares_count == 16
end

# ============================================================================
# PIECES_COUNT
# ============================================================================

puts
puts "pieces_count:"

run_test("returns 0 for empty board and hands") do
  position = create_position(segments: [[8]], separators: [])
  raise "expected 0" unless position.pieces_count == 0
end

run_test("counts pieces on board only") do
  k = MockPiece.new("K")
  q = MockPiece.new("Q")
  position = create_position(segments: [[k, 2, q]], separators: [])
  raise "expected 2" unless position.pieces_count == 2
end

run_test("counts pieces in hands only") do
  position = create_position(
    segments: [[8]],
    separators: [],
    first_hand: [{ piece: "P", count: 2 }, { piece: "B", count: 1 }],
    second_hand: [{ piece: "p", count: 1 }]
  )
  raise "expected 4" unless position.pieces_count == 4
end

run_test("counts pieces on board and in hands") do
  k = MockPiece.new("K")
  position = create_position(
    segments: [[k, 7]],
    separators: [],
    first_hand: [{ piece: "P", count: 2 }],
    second_hand: [{ piece: "p", count: 3 }]
  )
  raise "expected 6" unless position.pieces_count == 6
end

run_test("counts chess initial position") do
  # Simulate 32 pieces on board
  rank8 = Array.new(8) { MockPiece.new("x") }
  rank7 = Array.new(8) { MockPiece.new("x") }
  rank2 = Array.new(8) { MockPiece.new("X") }
  rank1 = Array.new(8) { MockPiece.new("X") }

  position = create_position(
    segments: [rank8, rank7, [8], [8], [8], [8], rank2, rank1],
    separators: ["/", "/", "/", "/", "/", "/", "/"]
  )
  raise "expected 32" unless position.pieces_count == 32
end

# ============================================================================
# TO_S
# ============================================================================

puts
puts "to_s:"

run_test("returns canonical format for simple position") do
  position = create_position(segments: [[8]], separators: [])
  raise "expected '8 / C/c'" unless position.to_s == "8 / C/c"
end

run_test("returns canonical format for 2D board") do
  position = create_position(
    segments: [[8], [8]],
    separators: ["/"]
  )
  raise "expected '8/8 / C/c'" unless position.to_s == "8/8 / C/c"
end

run_test("returns canonical format with pieces on board") do
  k = MockPiece.new("K")
  q = MockPiece.new("Q")
  position = create_position(segments: [[k, 2, q]], separators: [])
  raise "expected 'K2Q / C/c'" unless position.to_s == "K2Q / C/c"
end

run_test("returns canonical format with pieces in hands") do
  position = create_position(
    segments: [[8]],
    separators: [],
    first_hand: [{ piece: "P", count: 2 }, { piece: "B", count: 1 }],
    second_hand: [{ piece: "p", count: 1 }]
  )
  raise "expected '8 2PB/p C/c'" unless position.to_s == "8 2PB/p C/c"
end

run_test("returns canonical format with empty hands") do
  position = create_position(segments: [[8]], separators: [])
  # Empty hands should produce "/"
  raise "should contain ' / '" unless position.to_s.include?(" / ")
end

run_test("returns canonical format for second to move") do
  position = create_position(active_side: :second)
  raise "expected '8 / c/C'" unless position.to_s == "8 / c/C"
end

run_test("returns canonical format for cross-style game") do
  position = create_position(active_abbr: :C, inactive_abbr: :S)
  raise "expected '8 / C/s'" unless position.to_s == "8 / C/s"
end

run_test("returns canonical format for 3D board") do
  position = create_position(
    segments: [[2], [2], [2], [2]],
    separators: ["/", "//", "/"]
  )
  raise "expected '2/2//2/2 / C/c'" unless position.to_s == "2/2//2/2 / C/c"
end

# ============================================================================
# EQUALITY (==)
# ============================================================================

puts
puts "equality:"

run_test("equal when all components match") do
  a = create_position
  b = create_position
  raise "expected equal" unless a == b
end

run_test("equal with complex positions") do
  k = MockPiece.new("K")
  a = create_position(
    segments: [[k, 7], [8]],
    separators: ["/"],
    first_hand: [{ piece: "P", count: 2 }],
    second_hand: []
  )
  b = create_position(
    segments: [[k, 7], [8]],
    separators: ["/"],
    first_hand: [{ piece: "P", count: 2 }],
    second_hand: []
  )
  raise "expected equal" unless a == b
end

run_test("not equal when piece_placement differs") do
  a = create_position(segments: [[8]], separators: [])
  b = create_position(segments: [[4]], separators: [])
  raise "expected not equal" if a == b
end

run_test("not equal when hands differ") do
  a = create_position(first_hand: [{ piece: "P", count: 1 }])
  b = create_position(first_hand: [{ piece: "P", count: 2 }])
  raise "expected not equal" if a == b
end

run_test("not equal when style_turn differs") do
  a = create_position(active_side: :first)
  b = create_position(active_side: :second)
  raise "expected not equal" if a == b
end

run_test("not equal to nil") do
  position = create_position
  raise "expected not equal" if position == nil
end

run_test("not equal to other types") do
  position = create_position
  raise "not equal to String" if position == "8 / C/c"
  raise "not equal to Hash" if position == {}
  raise "not equal to Array" if position == []
end

run_test("eql? behaves like ==") do
  a = create_position
  b = create_position
  c = create_position(segments: [[4]], separators: [])
  raise "expected eql?" unless a.eql?(b)
  raise "expected not eql?" if a.eql?(c)
end

# ============================================================================
# HASH
# ============================================================================

puts
puts "hash:"

run_test("equal positions have equal hash codes") do
  a = create_position
  b = create_position
  raise "expected equal hashes" unless a.hash == b.hash
end

run_test("can be used as hash key") do
  a = create_position
  b = create_position
  hash = { a => "value" }
  raise "expected to find by equal key" unless hash[b] == "value"
end

run_test("different positions likely have different hashes") do
  a = create_position(segments: [[8]], separators: [])
  b = create_position(segments: [[4]], separators: [])
  # Not strictly required, but highly likely
  raise "expected different hashes" if a.hash == b.hash
end

# ============================================================================
# INSPECT
# ============================================================================

puts
puts "inspect:"

run_test("includes class name") do
  position = create_position
  raise "expected class name" unless position.inspect.include?("Position")
end

run_test("includes FEEN string") do
  position = create_position
  raise "expected FEEN content" unless position.inspect.include?("8")
  raise "expected FEEN content" unless position.inspect.include?("C/c")
end

# ============================================================================
# IMMUTABILITY
# ============================================================================

puts
puts "immutability:"

run_test("instance is frozen") do
  position = create_position
  raise "expected frozen" unless position.frozen?
end

run_test("piece_placement is frozen") do
  position = create_position
  raise "expected frozen" unless position.piece_placement.frozen?
end

run_test("hands is frozen") do
  position = create_position
  raise "expected frozen" unless position.hands.frozen?
end

run_test("style_turn is frozen") do
  position = create_position
  raise "expected frozen" unless position.style_turn.frozen?
end

# ============================================================================
# REAL-WORLD EXAMPLES
# ============================================================================

puts
puts "real-world examples:"

run_test("Chess initial position structure") do
  # Simplified: 8 ranks with pieces on 1,2,7,8 and empty on 3-6
  r = MockPiece.new("r")
  n = MockPiece.new("n")
  b = MockPiece.new("b")
  q = MockPiece.new("q")
  k = MockPiece.new("k")
  p_piece = MockPiece.new("p")

  segments = [
    [r, n, b, q, k, b, n, r],
    Array.new(8) { p_piece },
    [8], [8], [8], [8],
    Array.new(8) { MockPiece.new("P") },
    [MockPiece.new("R"), MockPiece.new("N"), MockPiece.new("B"), MockPiece.new("Q"),
     MockPiece.new("K"), MockPiece.new("B"), MockPiece.new("N"), MockPiece.new("R")]
  ]

  position = Position.new(
    piece_placement: { segments: segments, separators: ["/"] * 7 },
    hands: { first: [], second: [] },
    style_turn: { active: MockStyle.new(:first, :C), inactive: MockStyle.new(:second, :C) }
  )

  raise "expected 64 squares" unless position.squares_count == 64
  raise "expected 32 pieces" unless position.pieces_count == 32
  raise "should start with rnbqkbnr" unless position.to_s.start_with?("rnbqkbnr")
end

run_test("Shogi position with pieces in hand") do
  position = Position.new(
    piece_placement: { segments: [[9], [9], [9], [9], [9], [9], [9], [9], [9]], separators: ["/"] * 8 },
    hands: {
      first: [{ piece: "P", count: 3 }, { piece: "L", count: 1 }],
      second: [{ piece: "p", count: 2 }]
    },
    style_turn: { active: MockStyle.new(:first, :S), inactive: MockStyle.new(:second, :S) }
  )

  raise "expected 81 squares" unless position.squares_count == 81
  raise "expected 6 pieces" unless position.pieces_count == 6
  raise "should contain S/s" unless position.to_s.include?("S/s")
end

run_test("Cross-style game") do
  position = Position.new(
    piece_placement: { segments: [[8]], separators: [] },
    hands: { first: [], second: [] },
    style_turn: { active: MockStyle.new(:first, :C), inactive: MockStyle.new(:second, :S) }
  )

  raise "should contain C/s" unless position.to_s.include?("C/s")
end

run_test("3D Raumschach-like position") do
  # 5x5x5 = 125 squares, represented as 5 layers of 5 ranks
  segments = []
  separators = []

  5.times do |layer|
    5.times do |rank|
      segments << [5]
      separators << "/" if rank < 4
    end
    separators << "//" if layer < 4
  end
  separators.pop  # Remove trailing separator

  position = Position.new(
    piece_placement: { segments: segments, separators: separators },
    hands: { first: [], second: [] },
    style_turn: { active: MockStyle.new(:first, :R), inactive: MockStyle.new(:second, :R) }
  )

  raise "expected 125 squares" unless position.squares_count == 125
  raise "expected 3D" unless position.piece_placement.dimensions == 3
end

puts
puts "All Position tests passed!"
puts
