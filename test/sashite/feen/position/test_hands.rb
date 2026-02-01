#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/position/hands"

Hands = Sashite::Feen::Position::Hands

puts
puts "=== Hands Tests ==="
puts

# ============================================================================
# INITIALIZATION
# ============================================================================

puts "Initialization:"

run_test("can be created with empty hands") do
  hands = Hands.send(:new, first: [], second: [])
  raise "expected Hands instance" unless Hands === hands
end

run_test("can be created with default empty hands") do
  hands = Hands.send(:new)
  raise "expected Hands instance" unless Hands === hands
end

run_test("can be created with items") do
  hands = Hands.send(:new,
    first: [{ piece: "P", count: 2 }],
    second: [{ piece: "p", count: 1 }]
  )
  raise "expected Hands instance" unless Hands === hands
end

run_test("new is private") do
  begin
    Hands.new
    raise "should have raised NoMethodError"
  rescue ::NoMethodError
    # Expected
  end
end

# ============================================================================
# IMMUTABILITY
# ============================================================================

puts
puts "Immutability:"

run_test("instance is frozen") do
  hands = Hands.send(:new)
  raise "expected frozen" unless hands.frozen?
end

run_test("class is frozen") do
  raise "expected class to be frozen" unless Hands.frozen?
end

# ============================================================================
# FIRST AND SECOND ACCESSORS
# ============================================================================

puts
puts "first and second accessors:"

run_test("first returns Hand instance") do
  hands = Hands.send(:new)
  raise "expected Hand" unless hands.first.is_a?(Sashite::Feen::Position::Hand)
end

run_test("second returns Hand instance") do
  hands = Hands.send(:new)
  raise "expected Hand" unless hands.second.is_a?(Sashite::Feen::Position::Hand)
end

run_test("first contains first player's items") do
  hands = Hands.send(:new, first: [{ piece: "P", count: 3 }], second: [])
  raise "expected 3 pieces" unless hands.first.pieces_count == 3
end

run_test("second contains second player's items") do
  hands = Hands.send(:new, first: [], second: [{ piece: "p", count: 2 }])
  raise "expected 2 pieces" unless hands.second.pieces_count == 2
end

# ============================================================================
# PIECES_COUNT
# ============================================================================

puts
puts "pieces_count method:"

run_test("returns 0 for empty hands") do
  hands = Hands.send(:new)
  raise "expected 0, got #{hands.pieces_count}" unless hands.pieces_count == 0
end

run_test("returns count from first hand only") do
  hands = Hands.send(:new, first: [{ piece: "P", count: 5 }], second: [])
  raise "expected 5, got #{hands.pieces_count}" unless hands.pieces_count == 5
end

run_test("returns count from second hand only") do
  hands = Hands.send(:new, first: [], second: [{ piece: "p", count: 3 }])
  raise "expected 3, got #{hands.pieces_count}" unless hands.pieces_count == 3
end

run_test("returns sum from both hands") do
  hands = Hands.send(:new,
    first: [{ piece: "P", count: 2 }, { piece: "N", count: 1 }],
    second: [{ piece: "p", count: 3 }]
  )
  raise "expected 6, got #{hands.pieces_count}" unless hands.pieces_count == 6
end

# ============================================================================
# TO_S
# ============================================================================

puts
puts "to_s method:"

run_test("returns '/' for empty hands") do
  hands = Hands.send(:new)
  raise "expected '/', got #{hands.to_s.inspect}" unless hands.to_s == "/"
end

run_test("returns first hand with separator for first only") do
  hands = Hands.send(:new, first: [{ piece: "P", count: 2 }], second: [])
  raise "expected '2P/', got #{hands.to_s.inspect}" unless hands.to_s == "2P/"
end

run_test("returns separator with second hand for second only") do
  hands = Hands.send(:new, first: [], second: [{ piece: "p", count: 1 }])
  raise "expected '/p', got #{hands.to_s.inspect}" unless hands.to_s == "/p"
end

run_test("returns both hands with separator") do
  hands = Hands.send(:new,
    first: [{ piece: "B", count: 2 }, { piece: "N", count: 1 }],
    second: [{ piece: "q", count: 2 }]
  )
  raise "expected '2BN/2q', got #{hands.to_s.inspect}" unless hands.to_s == "2BN/2q"
end

run_test("returns String type") do
  hands = Hands.send(:new)
  raise "expected String" unless ::String === hands.to_s
end

# ============================================================================
# EQUALITY
# ============================================================================

puts
puts "Equality:"

run_test("equal hands are ==") do
  hands1 = Hands.send(:new, first: [{ piece: "P", count: 2 }], second: [])
  hands2 = Hands.send(:new, first: [{ piece: "P", count: 2 }], second: [])
  raise "expected equal" unless hands1 == hands2
end

run_test("equal hands are eql?") do
  hands1 = Hands.send(:new, first: [{ piece: "P", count: 2 }], second: [])
  hands2 = Hands.send(:new, first: [{ piece: "P", count: 2 }], second: [])
  raise "expected eql?" unless hands1.eql?(hands2)
end

run_test("different first hands are not equal") do
  hands1 = Hands.send(:new, first: [{ piece: "P", count: 2 }], second: [])
  hands2 = Hands.send(:new, first: [{ piece: "N", count: 2 }], second: [])
  raise "expected not equal" if hands1 == hands2
end

run_test("different second hands are not equal") do
  hands1 = Hands.send(:new, first: [], second: [{ piece: "p", count: 1 }])
  hands2 = Hands.send(:new, first: [], second: [{ piece: "n", count: 1 }])
  raise "expected not equal" if hands1 == hands2
end

run_test("empty hands are equal") do
  hands1 = Hands.send(:new)
  hands2 = Hands.send(:new)
  raise "expected equal" unless hands1 == hands2
end

run_test("not equal to nil") do
  hands = Hands.send(:new)
  raise "expected not equal to nil" if hands == nil
end

run_test("not equal to other types") do
  hands = Hands.send(:new, first: [{ piece: "P", count: 1 }], second: [])
  raise "expected not equal to Hash" if hands == { first: [{ piece: "P", count: 1 }], second: [] }
end

# ============================================================================
# HASH
# ============================================================================

puts
puts "Hash:"

run_test("equal hands have same hash") do
  hands1 = Hands.send(:new, first: [{ piece: "P", count: 2 }], second: [])
  hands2 = Hands.send(:new, first: [{ piece: "P", count: 2 }], second: [])
  raise "expected same hash" unless hands1.hash == hands2.hash
end

run_test("can be used as hash key") do
  hands1 = Hands.send(:new, first: [{ piece: "P", count: 2 }], second: [])
  hands2 = Hands.send(:new, first: [{ piece: "P", count: 2 }], second: [])

  hash = { hands1 => "value" }
  raise "expected to find by equal key" unless hash[hands2] == "value"
end

# ============================================================================
# INSPECT
# ============================================================================

puts
puts "Inspect:"

run_test("returns inspect string") do
  hands = Hands.send(:new, first: [{ piece: "P", count: 2 }], second: [])
  result = hands.inspect
  raise "expected String" unless ::String === result
  raise "expected to include class name" unless result.include?("Hands")
end

run_test("inspect includes first and second") do
  hands = Hands.send(:new, first: [{ piece: "P", count: 2 }], second: [{ piece: "p", count: 1 }])
  result = hands.inspect
  raise "expected to include 'first'" unless result.include?("first")
  raise "expected to include 'second'" unless result.include?("second")
end

puts
puts "All Hands tests passed!"
puts
