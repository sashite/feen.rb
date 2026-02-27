#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../helper"
require_relative "../../../lib/sashite/feen/dumper"
require "qi"

puts
puts "=== Dumper Tests ==="
puts

Dumper = Sashite::Feen::Dumper

# Helper to build a Qi::Position
def qi(board, hands: { first: [], second: [] }, styles: { first: "C", second: "c" }, turn: :first)
  Qi.new(board, hands, styles, turn)
end

# ============================================================================
# MINIMAL POSITIONS
# ============================================================================

puts "minimal positions:"

run_test("dumps minimal 1D position") do
  position = qi(["K"])
  result = Dumper.dump(position)
  raise "expected 'K / C/c'" unless result == "K / C/c"
end

run_test("dumps empty 1D board") do
  position = qi(Array.new(8))
  result = Dumper.dump(position)
  raise "expected '8 / C/c'" unless result == "8 / C/c"
end

# ============================================================================
# 2D POSITIONS
# ============================================================================

puts
puts "2D positions:"

run_test("dumps empty 8x8 board") do
  position = qi(Array.new(8) { Array.new(8) })
  result = Dumper.dump(position)
  raise "expected '8/8/8/8/8/8/8/8 / C/c'" unless result == "8/8/8/8/8/8/8/8 / C/c"
end

run_test("dumps Chess initial position") do
  board = [
    ["r", "n", "b", "q", "k", "b", "n", "r"],
    ["p", "p", "p", "p", "p", "p", "p", "p"],
    Array.new(8), Array.new(8), Array.new(8), Array.new(8),
    ["P", "P", "P", "P", "P", "P", "P", "P"],
    ["R", "N", "B", "Q", "K", "B", "N", "R"]
  ]
  position = qi(board)
  result = Dumper.dump(position)
  raise "expected Chess FEEN" unless result == "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c"
end

run_test("dumps Shogi initial position") do
  board = [
    ["l", "n", "s", "g", "k", "g", "s", "n", "l"],
    [nil, "r", nil, nil, nil, nil, nil, "b", nil],
    ["p", "p", "p", "p", "p", "p", "p", "p", "p"],
    Array.new(9), Array.new(9), Array.new(9),
    ["P", "P", "P", "P", "P", "P", "P", "P", "P"],
    [nil, "B", nil, nil, nil, nil, nil, "R", nil],
    ["L", "N", "S", "G", "K", "G", "S", "N", "L"]
  ]
  position = qi(board, styles: { first: "S", second: "s" })
  result = Dumper.dump(position)
  raise "expected Shogi FEEN" unless result == "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s"
end

# ============================================================================
# 3D POSITIONS
# ============================================================================

puts
puts "3D positions:"

run_test("dumps 3D empty board") do
  board = [
    [Array.new(4), Array.new(4)],
    [Array.new(4), Array.new(4)]
  ]
  position = qi(board)
  result = Dumper.dump(position)
  raise "expected '4/4//4/4 / C/c'" unless result == "4/4//4/4 / C/c"
end

run_test("dumps 3D board with pieces") do
  board = [
    [["a", "b"], ["c", "d"]],
    [["A", "B"], ["C", "D"]]
  ]
  position = qi(board)
  result = Dumper.dump(position)
  raise "expected 'ab/cd//AB/CD / C/c'" unless result == "ab/cd//AB/CD / C/c"
end

# ============================================================================
# HANDS
# ============================================================================

puts
puts "hands:"

run_test("dumps empty hands") do
  position = qi(["K"])
  result = Dumper.dump(position)
  raise "should contain ' / '" unless result.include?(" / ")
end

run_test("dumps first hand with pieces") do
  position = qi(Array.new(8), hands: { first: ["P", "P", "N"], second: [] })
  result = Dumper.dump(position)
  raise "expected '8 2PN/ C/c'" unless result == "8 2PN/ C/c"
end

run_test("dumps both hands with pieces") do
  position = qi(Array.new(8), hands: { first: ["P", "P", "N"], second: ["p"] })
  result = Dumper.dump(position)
  raise "expected '8 2PN/p C/c'" unless result == "8 2PN/p C/c"
end

run_test("dumps complex hands") do
  position = qi(
    Array.new(8) { Array.new(8) },
    hands: { first: ["B", "B", "B", "P", "P", "N", "R"], second: ["q", "q", "p"] }
  )
  result = Dumper.dump(position)
  raise "expected '...3B2PNR/2qp...'" unless result.include?("3B2PNR/2qp")
end

# ============================================================================
# STYLES AND TURN
# ============================================================================

puts
puts "styles and turn:"

run_test("dumps first player to move") do
  position = qi(["K"], turn: :first)
  result = Dumper.dump(position)
  raise "should end with 'C/c'" unless result.end_with?("C/c")
end

run_test("dumps second player to move") do
  position = qi(["K"], turn: :second)
  result = Dumper.dump(position)
  raise "should end with 'c/C'" unless result.end_with?("c/C")
end

run_test("dumps cross-style game") do
  position = qi(["K"], styles: { first: "C", second: "s" }, turn: :first)
  result = Dumper.dump(position)
  raise "should end with 'C/s'" unless result.end_with?("C/s")
end

run_test("dumps cross-style with second to move") do
  position = qi(["K"], styles: { first: "C", second: "s" }, turn: :second)
  result = Dumper.dump(position)
  raise "should end with 's/C'" unless result.end_with?("s/C")
end

# ============================================================================
# FORMAT - THREE FIELDS
# ============================================================================

puts
puts "format:"

run_test("result has exactly 3 space-separated fields") do
  position = qi(["K"])
  result = Dumper.dump(position)
  fields = result.split(" ", -1)
  raise "expected 3 fields, got #{fields.size}" unless fields.size == 3
end

run_test("fields are non-empty") do
  position = qi(["K"])
  result = Dumper.dump(position)
  fields = result.split(" ", -1)
  fields.each_with_index do |field, i|
    raise "field #{i} is empty" if field.empty?
  end
end

# ============================================================================
# RETURN TYPE
# ============================================================================

puts
puts "return type:"

run_test("returns a String") do
  position = qi(["K"])
  result = Dumper.dump(position)
  raise "expected String" unless result.is_a?(String)
end

# ============================================================================
# MODULE PROPERTIES
# ============================================================================

puts
puts "module properties:"

run_test("module is frozen") do
  raise "expected frozen" unless Dumper.frozen?
end

puts
puts "All Dumper tests passed!"
puts
