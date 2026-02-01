#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/position/hand"

Hand = Sashite::Feen::Position::Hand

puts
puts "=== Hand Tests ==="
puts

# ============================================================================
# INITIALIZATION
# ============================================================================

puts "Initialization:"

run_test("can be created with empty array") do
  hand = Hand.send(:new, [])
  raise "expected Hand instance" unless Hand === hand
end

run_test("can be created with items") do
  hand = Hand.send(:new, [{ piece: "P", count: 2 }, { piece: "N", count: 1 }])
  raise "expected Hand instance" unless Hand === hand
end

run_test("new is private") do
  begin
    Hand.new([])
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
  hand = Hand.send(:new, [])
  raise "expected frozen" unless hand.frozen?
end

run_test("class is frozen") do
  raise "expected class to be frozen" unless Hand.frozen?
end

# ============================================================================
# EMPTY?
# ============================================================================

puts
puts "empty? predicate:"

run_test("returns true for empty hand") do
  hand = Hand.send(:new, [])
  raise "expected true" unless hand.empty? == true
end

run_test("returns false for non-empty hand") do
  hand = Hand.send(:new, [{ piece: "P", count: 1 }])
  raise "expected false" unless hand.empty? == false
end

# ============================================================================
# SIZE
# ============================================================================

puts
puts "size method:"

run_test("returns 0 for empty hand") do
  hand = Hand.send(:new, [])
  raise "expected 0, got #{hand.size}" unless hand.size == 0
end

run_test("returns number of distinct piece types") do
  hand = Hand.send(:new, [
    { piece: "B", count: 2 },
    { piece: "P", count: 3 },
    { piece: "N", count: 1 }
  ])
  raise "expected 3, got #{hand.size}" unless hand.size == 3
end

run_test("returns 1 for single piece type") do
  hand = Hand.send(:new, [{ piece: "Q", count: 5 }])
  raise "expected 1, got #{hand.size}" unless hand.size == 1
end

# ============================================================================
# PIECES_COUNT
# ============================================================================

puts
puts "pieces_count method:"

run_test("returns 0 for empty hand") do
  hand = Hand.send(:new, [])
  raise "expected 0, got #{hand.pieces_count}" unless hand.pieces_count == 0
end

run_test("returns count for single piece type") do
  hand = Hand.send(:new, [{ piece: "P", count: 5 }])
  raise "expected 5, got #{hand.pieces_count}" unless hand.pieces_count == 5
end

run_test("returns sum of counts for multiple piece types") do
  hand = Hand.send(:new, [
    { piece: "B", count: 2 },
    { piece: "P", count: 3 },
    { piece: "N", count: 1 }
  ])
  raise "expected 6, got #{hand.pieces_count}" unless hand.pieces_count == 6
end

run_test("handles count of 1") do
  hand = Hand.send(:new, [{ piece: "K", count: 1 }, { piece: "Q", count: 1 }])
  raise "expected 2, got #{hand.pieces_count}" unless hand.pieces_count == 2
end

# ============================================================================
# ITEMS ACCESSOR
# ============================================================================

puts
puts "items accessor:"

run_test("returns items array") do
  items = [{ piece: "P", count: 2 }]
  hand = Hand.send(:new, items)
  raise "expected same items" unless hand.items == items
end

run_test("returns empty array for empty hand") do
  hand = Hand.send(:new, [])
  raise "expected empty array" unless hand.items == []
end

# ============================================================================
# ENUMERABLE
# ============================================================================

puts
puts "Enumerable interface:"

run_test("includes Enumerable") do
  result = Hand.include?(::Enumerable)
  raise "expected to include Enumerable" unless result
end

run_test("each yields piece and count") do
  hand = Hand.send(:new, [{ piece: "P", count: 2 }, { piece: "N", count: 1 }])

  yielded = []
  hand.each { |piece, count| yielded << [piece.to_s, count] }

  raise "expected 2 items" unless yielded.size == 2
  raise "expected ['P', 2] in results" unless yielded.include?(["P", 2])
  raise "expected ['N', 1] in results" unless yielded.include?(["N", 1])
end

run_test("each returns Enumerator when no block given") do
  hand = Hand.send(:new, [{ piece: "P", count: 1 }])
  result = hand.each
  raise "expected Enumerator, got #{result.class}" unless ::Enumerator === result
end

run_test("each with empty hand yields nothing") do
  hand = Hand.send(:new, [])
  yielded = []
  hand.each { |piece, count| yielded << [piece, count] }
  raise "expected empty, got #{yielded.inspect}" unless yielded.empty?
end

run_test("supports map via Enumerable") do
  hand = Hand.send(:new, [{ piece: "P", count: 2 }, { piece: "N", count: 3 }])

  result = hand.map { |piece, count| "#{count}x#{piece}" }
  raise "expected 2 items" unless result.size == 2
  raise "expected '2xP' in results" unless result.include?("2xP")
  raise "expected '3xN' in results" unless result.include?("3xN")
end

# ============================================================================
# TO_S
# ============================================================================

puts
puts "to_s method:"

run_test("returns empty string for empty hand") do
  hand = Hand.send(:new, [])
  raise "expected empty string, got #{hand.to_s.inspect}" unless hand.to_s == ""
end

run_test("returns piece without count prefix for count of 1") do
  hand = Hand.send(:new, [{ piece: "P", count: 1 }])
  raise "expected 'P', got #{hand.to_s.inspect}" unless hand.to_s == "P"
end

run_test("returns piece with count prefix for count >= 2") do
  hand = Hand.send(:new, [{ piece: "P", count: 2 }])
  raise "expected '2P', got #{hand.to_s.inspect}" unless hand.to_s == "2P"
end

run_test("concatenates multiple pieces in order") do
  hand = Hand.send(:new, [
    { piece: "B", count: 2 },
    { piece: "N", count: 1 },
    { piece: "R", count: 1 }
  ])
  result = hand.to_s
  raise "expected '2BNR', got #{result.inspect}" unless result == "2BNR"
end

run_test("handles large counts") do
  hand = Hand.send(:new, [{ piece: "P", count: 10 }])
  raise "expected '10P', got #{hand.to_s.inspect}" unless hand.to_s == "10P"
end

run_test("returns String type") do
  hand = Hand.send(:new, [{ piece: "P", count: 2 }])
  raise "expected String" unless ::String === hand.to_s
end

# ============================================================================
# EQUALITY
# ============================================================================

puts
puts "Equality:"

run_test("equal hands are ==") do
  hand1 = Hand.send(:new, [{ piece: "P", count: 2 }])
  hand2 = Hand.send(:new, [{ piece: "P", count: 2 }])
  raise "expected equal" unless hand1 == hand2
end

run_test("equal hands are eql?") do
  hand1 = Hand.send(:new, [{ piece: "P", count: 2 }])
  hand2 = Hand.send(:new, [{ piece: "P", count: 2 }])
  raise "expected eql?" unless hand1.eql?(hand2)
end

run_test("different pieces are not equal") do
  hand1 = Hand.send(:new, [{ piece: "P", count: 2 }])
  hand2 = Hand.send(:new, [{ piece: "N", count: 2 }])
  raise "expected not equal" if hand1 == hand2
end

run_test("different counts are not equal") do
  hand1 = Hand.send(:new, [{ piece: "P", count: 2 }])
  hand2 = Hand.send(:new, [{ piece: "P", count: 3 }])
  raise "expected not equal" if hand1 == hand2
end

run_test("empty hands are equal") do
  hand1 = Hand.send(:new, [])
  hand2 = Hand.send(:new, [])
  raise "expected equal" unless hand1 == hand2
end

run_test("not equal to nil") do
  hand = Hand.send(:new, [])
  raise "expected not equal to nil" if hand == nil
end

run_test("not equal to other types") do
  hand = Hand.send(:new, [{ piece: "P", count: 1 }])
  raise "expected not equal to Array" if hand == [{ piece: "P", count: 1 }]
end

# ============================================================================
# HASH
# ============================================================================

puts
puts "Hash:"

run_test("equal hands have same hash") do
  hand1 = Hand.send(:new, [{ piece: "P", count: 2 }])
  hand2 = Hand.send(:new, [{ piece: "P", count: 2 }])
  raise "expected same hash" unless hand1.hash == hand2.hash
end

run_test("can be used as hash key") do
  hand1 = Hand.send(:new, [{ piece: "P", count: 2 }])
  hand2 = Hand.send(:new, [{ piece: "P", count: 2 }])

  hash = { hand1 => "value" }
  raise "expected to find by equal key" unless hash[hand2] == "value"
end

# ============================================================================
# INSPECT
# ============================================================================

puts
puts "Inspect:"

run_test("returns inspect string") do
  hand = Hand.send(:new, [{ piece: "P", count: 2 }])
  result = hand.inspect
  raise "expected String" unless ::String === result
  raise "expected to include class name" unless result.include?("Hand")
end

run_test("inspect shows to_s representation") do
  hand = Hand.send(:new, [{ piece: "P", count: 2 }])
  result = hand.inspect
  raise "expected to include '2P'" unless result.include?("2P")
end

puts
puts "All Hand tests passed!"
puts
