#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../helper"
require_relative "../../../lib/sashite/feen/dumper"
require "qi"

puts
puts "=== Dumper Tests ==="
puts

Dumper = Sashite::Feen::Dumper

# Helper to build a Qi position with Qi v13 API.
#
# @param shape [Array<Integer>] Board dimensions
# @param board [Hash{Integer => String}] Flat index => piece diffs
# @param first_hand [Hash{Symbol => Integer}] First player hand diffs
# @param second_hand [Hash{Symbol => Integer}] Second player hand diffs
# @param first_style [String] First player style
# @param second_style [String] Second player style
# @param turn [Symbol] :first or :second
def qi(shape, board: {}, first_hand: {}, second_hand: {}, first_style: "C", second_style: "c", turn: :first)
  pos = Qi.new(shape, first_player_style: first_style, second_player_style: second_style)
  pos = pos.board_diff(**board) unless board.empty?
  pos = pos.first_player_hand_diff(**first_hand) unless first_hand.empty?
  pos = pos.second_player_hand_diff(**second_hand) unless second_hand.empty?
  pos = pos.toggle if turn == :second
  pos
end

# ============================================================================
# MINIMAL POSITIONS
# ============================================================================

puts "minimal positions:"

Test("dumps minimal 1D position") do
  position = qi([1], board: { 0 => "K" })
  result = Dumper.dump(position)
  raise "expected 'K / C/c'" unless result == "K / C/c"
end

Test("dumps empty 1D board") do
  position = qi([8])
  result = Dumper.dump(position)
  raise "expected '8 / C/c'" unless result == "8 / C/c"
end

# ============================================================================
# 2D POSITIONS
# ============================================================================

puts
puts "2D positions:"

Test("dumps empty 8x8 board") do
  position = qi([8, 8])
  result = Dumper.dump(position)
  raise "expected '8/8/8/8/8/8/8/8 / C/c'" unless result == "8/8/8/8/8/8/8/8 / C/c"
end

Test("dumps Chess initial position") do
  position = qi([8, 8], board: {
    0 => "r",  1 => "n",  2 => "b",  3 => "q",  4 => "k",  5 => "b",  6 => "n",  7 => "r",
    8 => "p",  9 => "p",  10 => "p", 11 => "p", 12 => "p", 13 => "p", 14 => "p", 15 => "p",
    48 => "P", 49 => "P", 50 => "P", 51 => "P", 52 => "P", 53 => "P", 54 => "P", 55 => "P",
    56 => "R", 57 => "N", 58 => "B", 59 => "Q", 60 => "K", 61 => "B", 62 => "N", 63 => "R"
  })
  result = Dumper.dump(position)
  raise "expected Chess FEEN" unless result == "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c"
end

Test("dumps Shogi initial position") do
  position = qi([9, 9], board: {
    0 => "l",  1 => "n",  2 => "s",  3 => "g",  4 => "k",  5 => "g",  6 => "s",  7 => "n",  8 => "l",
    10 => "r", 16 => "b",
    18 => "p", 19 => "p", 20 => "p", 21 => "p", 22 => "p", 23 => "p", 24 => "p", 25 => "p", 26 => "p",
    54 => "P", 55 => "P", 56 => "P", 57 => "P", 58 => "P", 59 => "P", 60 => "P", 61 => "P", 62 => "P",
    64 => "B", 70 => "R",
    72 => "L", 73 => "N", 74 => "S", 75 => "G", 76 => "K", 77 => "G", 78 => "S", 79 => "N", 80 => "L"
  }, first_style: "S", second_style: "s")
  result = Dumper.dump(position)
  raise "expected Shogi FEEN" unless result == "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s"
end

# ============================================================================
# 3D POSITIONS
# ============================================================================

puts
puts "3D positions:"

Test("dumps 3D empty board") do
  position = qi([2, 2, 4])
  result = Dumper.dump(position)
  raise "expected '4/4//4/4 / C/c'" unless result == "4/4//4/4 / C/c"
end

Test("dumps 3D board with pieces") do
  position = qi([2, 2, 2], board: {
    0 => "a", 1 => "b", 2 => "c", 3 => "d",
    4 => "A", 5 => "B", 6 => "C", 7 => "D"
  })
  result = Dumper.dump(position)
  raise "expected 'ab/cd//AB/CD / C/c'" unless result == "ab/cd//AB/CD / C/c"
end

# ============================================================================
# HANDS
# ============================================================================

puts
puts "hands:"

Test("dumps empty hands") do
  position = qi([1], board: { 0 => "K" })
  result = Dumper.dump(position)
  raise "should contain ' / '" unless result.include?(" / ")
end

Test("dumps first hand with pieces") do
  position = qi([8], first_hand: { "P": 2, "N": 1 })
  result = Dumper.dump(position)
  raise "expected '8 2PN/ C/c'" unless result == "8 2PN/ C/c"
end

Test("dumps both hands with pieces") do
  position = qi([8], first_hand: { "P": 2, "N": 1 }, second_hand: { "p": 1 })
  result = Dumper.dump(position)
  raise "expected '8 2PN/p C/c'" unless result == "8 2PN/p C/c"
end

Test("dumps complex hands") do
  position = qi([8, 8],
    first_hand: { "B": 3, "P": 2, "N": 1, "R": 1 },
    second_hand: { "q": 2, "p": 1 }
  )
  result = Dumper.dump(position)
  raise "expected '...3B2PNR/2qp...'" unless result.include?("3B2PNR/2qp")
end

# ============================================================================
# STYLES AND TURN
# ============================================================================

puts
puts "styles and turn:"

Test("dumps first player to move") do
  position = qi([1], board: { 0 => "K" }, turn: :first)
  result = Dumper.dump(position)
  raise "should end with 'C/c'" unless result.end_with?("C/c")
end

Test("dumps second player to move") do
  position = qi([1], board: { 0 => "K" }, turn: :second)
  result = Dumper.dump(position)
  raise "should end with 'c/C'" unless result.end_with?("c/C")
end

Test("dumps cross-style game") do
  position = qi([1], board: { 0 => "K" }, first_style: "C", second_style: "s", turn: :first)
  result = Dumper.dump(position)
  raise "should end with 'C/s'" unless result.end_with?("C/s")
end

Test("dumps cross-style with second to move") do
  position = qi([1], board: { 0 => "K" }, first_style: "C", second_style: "s", turn: :second)
  result = Dumper.dump(position)
  raise "should end with 's/C'" unless result.end_with?("s/C")
end

# ============================================================================
# FORMAT - THREE FIELDS
# ============================================================================

puts
puts "format:"

Test("result has exactly 3 space-separated fields") do
  position = qi([1], board: { 0 => "K" })
  result = Dumper.dump(position)
  fields = result.split(" ", -1)
  raise "expected 3 fields, got #{fields.size}" unless fields.size == 3
end

Test("fields are non-empty") do
  position = qi([1], board: { 0 => "K" })
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

Test("returns a String") do
  position = qi([1], board: { 0 => "K" })
  result = Dumper.dump(position)
  raise "expected String" unless result.is_a?(String)
end

# ============================================================================
# MODULE PROPERTIES
# ============================================================================

puts
puts "module properties:"

Test("module is frozen") do
  raise "expected frozen" unless Dumper.frozen?
end

puts
puts "All Dumper tests passed!"
puts
