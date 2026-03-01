#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../helper"
require_relative "../../../lib/sashite/feen/dumper"
require "qi"

puts
puts "=== Dumper Tests ==="
puts

Dumper = Sashite::Feen::Dumper

# Helper to build a Qi position.
def qi(shape, board: {}, first_hand: {}, second_hand: {}, first_style: "C", second_style: "c", turn: :first)
  pos = Qi.new(shape, first_player_style: first_style, second_player_style: second_style)
  pos = pos.board_diff(**board) unless board.empty?
  pos = pos.first_player_hand_diff(**first_hand) unless first_hand.empty?
  pos = pos.second_player_hand_diff(**second_hand) unless second_hand.empty?
  pos = pos.toggle if turn == :second
  pos
end

# ============================================================================
# MINIMAL & 1D POSITIONS
# ============================================================================

puts "minimal and 1D positions:"

Test("single piece and empty board") do
  raise unless Dumper.dump(qi([1], board: { 0 => "K" })) == "K / C/c"
  raise unless Dumper.dump(qi([8])) == "8 / C/c"
end

# ============================================================================
# 2D POSITIONS
# ============================================================================

puts
puts "2D positions:"

Test("empty 8x8 board") do
  raise unless Dumper.dump(qi([8, 8])) == "8/8/8/8/8/8/8/8 / C/c"
end

Test("Chess initial position") do
  pos = qi([8, 8], board: {
    0 => "r",  1 => "n",  2 => "b",  3 => "q",  4 => "k",  5 => "b",  6 => "n",  7 => "r",
    8 => "p",  9 => "p",  10 => "p", 11 => "p", 12 => "p", 13 => "p", 14 => "p", 15 => "p",
    48 => "P", 49 => "P", 50 => "P", 51 => "P", 52 => "P", 53 => "P", 54 => "P", 55 => "P",
    56 => "R", 57 => "N", 58 => "B", 59 => "Q", 60 => "K", 61 => "B", 62 => "N", 63 => "R"
  })
  raise unless Dumper.dump(pos) == "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c"
end

Test("Shogi initial position") do
  pos = qi([9, 9], board: {
    0 => "l",  1 => "n",  2 => "s",  3 => "g",  4 => "k",  5 => "g",  6 => "s",  7 => "n",  8 => "l",
    10 => "r", 16 => "b",
    18 => "p", 19 => "p", 20 => "p", 21 => "p", 22 => "p", 23 => "p", 24 => "p", 25 => "p", 26 => "p",
    54 => "P", 55 => "P", 56 => "P", 57 => "P", 58 => "P", 59 => "P", 60 => "P", 61 => "P", 62 => "P",
    64 => "B", 70 => "R",
    72 => "L", 73 => "N", 74 => "S", 75 => "G", 76 => "K", 77 => "G", 78 => "S", 79 => "N", 80 => "L"
  }, first_style: "S", second_style: "s")
  raise unless Dumper.dump(pos) == "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s"
end

# ============================================================================
# 3D POSITIONS
# ============================================================================

puts
puts "3D positions:"

Test("empty and populated 3D boards") do
  raise unless Dumper.dump(qi([2, 2, 4])) == "4/4//4/4 / C/c"

  pos = qi([2, 2, 2], board: {
    0 => "a", 1 => "b", 2 => "c", 3 => "d",
    4 => "A", 5 => "B", 6 => "C", 7 => "D"
  })
  raise unless Dumper.dump(pos) == "ab/cd//AB/CD / C/c"
end

# ============================================================================
# HANDS
# ============================================================================

puts
puts "hands:"

Test("empty, one-sided, and both hands") do
  raise unless Dumper.dump(qi([1], board: { 0 => "K" })).include?(" / ")
  raise unless Dumper.dump(qi([8], first_hand: { "P": 2, "N": 1 })) == "8 2PN/ C/c"
  raise unless Dumper.dump(qi([8], first_hand: { "P": 2, "N": 1 }, second_hand: { "p": 1 })) == "8 2PN/p C/c"
end

Test("complex hands") do
  pos = qi([8, 8], first_hand: { "B": 3, "P": 2, "N": 1, "R": 1 }, second_hand: { "q": 2, "p": 1 })
  raise unless Dumper.dump(pos).include?("3B2PNR/2qp")
end

# ============================================================================
# STYLES AND TURN
# ============================================================================

puts
puts "styles and turn:"

Test("first and second player to move") do
  raise unless Dumper.dump(qi([1], board: { 0 => "K" }, turn: :first)).end_with?("C/c")
  raise unless Dumper.dump(qi([1], board: { 0 => "K" }, turn: :second)).end_with?("c/C")
end

Test("cross-style both directions") do
  raise unless Dumper.dump(qi([1], board: { 0 => "K" }, first_style: "C", second_style: "s", turn: :first)).end_with?("C/s")
  raise unless Dumper.dump(qi([1], board: { 0 => "K" }, first_style: "C", second_style: "s", turn: :second)).end_with?("s/C")
end

# ============================================================================
# FORMAT & MODULE PROPERTIES
# ============================================================================

puts
puts "format and module properties:"

Test("three non-empty space-separated fields") do
  result = Dumper.dump(qi([1], board: { 0 => "K" }))
  fields = result.split(" ", -1)
  raise unless fields.size == 3
  raise if fields.any?(&:empty?)
end

Test("returns String, module is frozen") do
  raise unless Dumper.dump(qi([1], board: { 0 => "K" })).is_a?(String)
  raise unless Dumper.frozen?
end

puts
puts "All Dumper tests passed!"
puts
