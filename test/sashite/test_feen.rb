#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../helper"
require_relative "../../lib/sashite/feen"

puts
puts "=== Feen Integration Tests ==="
puts

Feen = Sashite::Feen

# ============================================================================
# PARSE - VALID INPUTS
# ============================================================================

puts "parse - valid inputs:"

Test("minimal, 1D, and EPIN-decorated positions") do
  pos = Feen.parse("K / C/c")
  raise unless pos.is_a?(Qi)

  pos = Feen.parse("K2Q3R / C/c")
  raise unless pos.board.size == 8
  raise unless pos.shape == [8]

  pos = Feen.parse("+K^'-q^' / C/c")
  raise unless pos.board.compact == ["+K^'", "-q^'"]
end

Test("Chess initial position") do
  pos = Feen.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c")
  raise unless pos.board.size == 64
  raise unless pos.board.compact.size == 32
  raise unless pos.shape == [8, 8]
end

Test("Shogi initial position") do
  pos = Feen.parse("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s")
  raise unless pos.board.size == 81
  raise unless pos.board.compact.size == 40
  raise unless pos.shape == [9, 9]
end

Test("Xiangqi initial position") do
  pos = Feen.parse("rheagaehr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RHEAGAEHR / X/x")
  raise unless pos.board.size == 90
  raise unless pos.shape == [10, 9]
end

Test("3D position") do
  pos = Feen.parse("4/4//4/4 / C/c")
  raise if pos.board[0].is_a?(Array)
  raise unless pos.shape == [2, 2, 4]
end

Test("hands, styles, and turn") do
  pos = Feen.parse("8/8/8/8/8/8/8/8 3B2PNR/2qp C/c")
  raise unless pos.first_player_hand.values.sum == 7
  raise unless pos.second_player_hand.values.sum == 3

  pos = Feen.parse("K / C/s")
  raise unless pos.first_player_style == "C"
  raise unless pos.second_player_style == "s"
  raise unless pos.turn == :first

  pos = Feen.parse("K / c/C")
  raise unless pos.turn == :second
end

# ============================================================================
# PARSE - INVALID INPUTS
# ============================================================================

puts
puts "parse - invalid inputs:"

Test("raises specific errors per field") do
  begin; Feen.parse(""); raise "x"; rescue Feen::ParseError; end
  begin; Feen.parse("K"); raise "x"; rescue Feen::ParseError; end
  begin; Feen.parse("/K / C/c"); raise "x"; rescue Feen::PiecePlacementError; end
  begin; Feen.parse("K PP/ C/c"); raise "x"; rescue Feen::HandsError; end
  begin; Feen.parse("K / C/C"); raise "x"; rescue Feen::StyleTurnError; end
  begin; Feen.parse("K 2P/ C/c"); raise "x"; rescue Feen::CardinalityError; end
  begin; Feen.parse("K" * 4097 + " / C/c"); raise "x"; rescue Feen::ParseError; end
end

Test("all errors rescuable as Feen::Error and ArgumentError") do
  begin; Feen.parse("invalid"); rescue Feen::Error; end
  begin; Feen.parse("invalid"); rescue ArgumentError; end
end

# ============================================================================
# VALID?
# ============================================================================

puts
puts "valid?:"

Test("true for valid FEEN strings") do
  valid = [
    "K / C/c",
    "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c",
    "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s",
    "rheagaehr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RHEAGAEHR / X/x",
    "8/8/8/8/8/8/8/8 3B2PNR/2qp C/c",
    "4/4//4/4 / C/c",
    "K / C/s",
    "K / c/C",
    "8 / C/c",
    "K2Q3R / C/c",
    "+K^'-q^' / C/c"
  ]
  valid.each { |s| raise "expected valid: #{s}" unless Feen.valid?(s) }
end

Test("false for invalid inputs") do
  invalid = [
    nil, 123, :symbol, [], {}, "",
    "K",                                        # wrong field count
    "K /",                                      # two fields
    "K / C/c extra",                            # four fields
    "/K / C/c",                                 # invalid piece placement
    "K@Q / C/c",                                # invalid character
    "K PP/ C/c",                                # invalid hands
    "K / C/C",                                  # same case
    "K 2P/ C/c",                                # cardinality violation
    "K" * 4097 + " / C/c",                     # too long
    "256 / C/c",                                # dimension size exceeded
    "1/1//1/1///1/1//1/1////1 / C/c",          # exceeds dimensions
    "0 / C/c",                                  # invalid empty count
    "01 / C/c"                                  # leading zeros
  ]
  invalid.each { |s| raise "expected invalid: #{s.inspect}" if Feen.valid?(s) }
end

Test("never raises for any input") do
  [nil, 123, :symbol, [], {}, "", "invalid", "K", "x" * 10_000].each do |input|
    begin
      result = Feen.valid?(input)
      raise "non-boolean for #{input.inspect}" unless result == true || result == false
    rescue StandardError => e
      raise "raised for #{input.inspect}: #{e.message}"
    end
  end
end

# ============================================================================
# DUMP
# ============================================================================

puts
puts "dump:"

Test("dumps Qi positions to String") do
  pos = Qi.new([1], first_player_style: "C", second_player_style: "c").board_diff(0 => "K")
  raise unless Feen.dump(pos) == "K / C/c"
  raise unless Feen.dump(pos).is_a?(String)

  pos = Qi.new([8], first_player_style: "S", second_player_style: "s")
    .first_player_hand_diff("P": 2).second_player_hand_diff("p": 1)
  raise unless Feen.dump(pos) == "8 2P/p S/s"
end

# ============================================================================
# ROUND-TRIP (parse → dump)
# ============================================================================

puts
puts "round-trip (parse → dump):"

[
  "K / C/c",
  "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c",
  "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s",
  "rheagaehr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RHEAGAEHR / X/x",
  "8/8/8/8/8/8/8/8 3B2PNR/2qp C/c",
  "4/4//4/4 / C/c",
  "K / C/s",
  "K / c/C",
  "8 / C/c",
  "K2Q3R / C/c",
  "+K^'-q^' / C/c",
  "9/9/9/9/9/9/9/9/9 / G/g"
].each do |feen|
  Test("round-trip: #{feen}") do
    raise "failed" unless Feen.dump(Feen.parse(feen)) == feen
  end
end

# ============================================================================
# ROUND-TRIP (build → dump → parse)
# ============================================================================

puts
puts "round-trip (build → dump → parse):"

Test("1D, 2D, 3D, and hands positions") do
  [
    [Qi.new([8], first_player_style: "C", second_player_style: "c").board_diff(0 => "K", 7 => "k")],
    [Qi.new([2, 8], first_player_style: "C", second_player_style: "c").board_diff(0 => "K", 7 => "k")],
    [Qi.new([2, 2, 2], first_player_style: "C", second_player_style: "c")
      .board_diff(0 => "a", 1 => "b", 2 => "c", 3 => "d", 4 => "A", 5 => "B", 6 => "C", 7 => "D")],
    [Qi.new([8, 8], first_player_style: "C", second_player_style: "c")
      .first_player_hand_diff("B": 3, "P": 2, "N": 1, "R": 1)
      .second_player_hand_diff("q": 2, "p": 1)]
  ].each do |original,|
    restored = Feen.parse(Feen.dump(original))
    raise "board" unless restored.board == original.board
    raise "shape" unless restored.shape == original.shape
    raise "first hand" unless restored.first_player_hand == original.first_player_hand
    raise "second hand" unless restored.second_player_hand == original.second_player_hand
    raise "turn" unless restored.turn == original.turn
  end
end

# ============================================================================
# ERROR HIERARCHY & MODULE STRUCTURE
# ============================================================================

puts
puts "error hierarchy and module structure:"

Test("error hierarchy") do
  raise unless Feen::Error < ArgumentError
  raise unless Feen::ParseError < Feen::Error
  raise unless Feen::PiecePlacementError < Feen::ParseError
  raise unless Feen::HandsError < Feen::ParseError
  raise unless Feen::StyleTurnError < Feen::ParseError
  raise unless Feen::CardinalityError < Feen::ParseError
end

Test("module structure") do
  raise unless Feen.is_a?(Module)
  raise unless Sashite.const_defined?(:Feen)
  raise unless Feen.respond_to?(:parse)
  raise unless Feen.respond_to?(:valid?)
  raise unless Feen.respond_to?(:dump)
  raise unless defined?(Feen::Parser)
  raise unless defined?(Feen::Dumper)
  raise unless defined?(Qi)
end

puts
puts "All Feen integration tests passed!"
puts
