#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../helper"
require_relative "../../../lib/sashite/feen/parser"

puts
puts "=== Parser Tests ==="
puts

Parser = Sashite::Feen::Parser

# ============================================================================
# PARSE - Qi OBJECT STRUCTURE
# ============================================================================

puts "parse - Qi object structure:"

Test("returns a Qi with all expected accessors") do
  r = Parser.parse("K / C/c")
  raise unless r.is_a?(Qi)
  %i[board shape first_player_hand second_player_hand
     first_player_style second_player_style turn].each do |m|
    raise "missing #{m}" unless r.respond_to?(m)
  end
end

# ============================================================================
# PARSE - BOARD (FLAT ARRAY)
# ============================================================================

puts
puts "parse - board:"

Test("1D board") do
  r = Parser.parse("K2Q / C/c")
  raise unless r.board == ["K", nil, nil, "Q"]
  raise unless r.shape == [4]
end

Test("2D board") do
  r = Parser.parse("8/8/8/8/8/8/8/8 / C/c")
  raise unless r.board.size == 64
  raise if r.board[0].is_a?(Array)
  raise unless r.shape == [8, 8]
end

Test("3D board") do
  r = Parser.parse("2/2//2/2 / C/c")
  raise unless r.board.size == 8
  raise unless r.shape == [2, 2, 2]
end

Test("pieces are EPIN strings") do
  r = Parser.parse("K^+p / C/c")
  raise unless r.board[0] == "K^"
  raise unless r.board[1] == "+p"
end

# ============================================================================
# PARSE - HANDS (COUNT MAPS)
# ============================================================================

puts
puts "parse - hands:"

Test("empty hands") do
  r = Parser.parse("K / C/c")
  raise unless r.first_player_hand == {}
  raise unless r.second_player_hand == {}
end

Test("hands with pieces are Hash{String => Integer}") do
  r = Parser.parse("8 2PN/p C/c")
  raise unless r.first_player_hand == { "P" => 2, "N" => 1 }
  raise unless r.second_player_hand == { "p" => 1 }
  raise unless r.first_player_hand.keys.all? { |k| k.is_a?(String) }
  raise unless r.first_player_hand.values.all? { |v| v.is_a?(Integer) }
end

# ============================================================================
# PARSE - STYLES AND TURN
# ============================================================================

puts
puts "parse - styles and turn:"

Test("first player to move") do
  r = Parser.parse("K / C/c")
  raise unless r.turn == :first
  raise unless r.first_player_style == "C"
  raise unless r.second_player_style == "c"
end

Test("second player to move") do
  r = Parser.parse("K / c/C")
  raise unless r.turn == :second
end

Test("cross-style game") do
  r = Parser.parse("K / C/s")
  raise unless r.first_player_style == "C"
  raise unless r.second_player_style == "s"
end

# ============================================================================
# PARSE - REAL POSITIONS
# ============================================================================

puts
puts "parse - real positions:"

Test("Chess initial") do
  r = Parser.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c")
  raise unless r.board.size == 64
  raise unless r.shape == [8, 8]
  raise unless r.board.compact.size == 32
end

Test("Shogi initial") do
  r = Parser.parse("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s")
  raise unless r.board.size == 81
  raise unless r.shape == [9, 9]
end

Test("Xiangqi initial") do
  r = Parser.parse("rheagaehr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RHEAGAEHR / X/x")
  raise unless r.board.size == 90
  raise unless r.shape == [10, 9]
end

Test("position with hands") do
  r = Parser.parse("8/8/8/8/8/8/8/8 3B2PNR/2qp C/c")
  raise unless r.first_player_hand.values.sum == 7
  raise unless r.second_player_hand.values.sum == 3
end

# ============================================================================
# PARSE - CARDINALITY VALIDATION
# ============================================================================

puts
puts "parse - cardinality:"

Test("accepts pieces equal to or less than squares") do
  raise unless Parser.parse("K / C/c").is_a?(Qi)
  raise unless Parser.parse("8 / C/c").is_a?(Qi)
end

Test("raises CardinalityError when pieces exceed squares") do
  ["K 2P/ C/c", "K1 2P/ C/c"].each do |input|
    begin; Parser.parse(input); raise "should raise for #{input.inspect}"
    rescue Sashite::Feen::CardinalityError; end
  end
end

# ============================================================================
# PARSE - INVALID INPUTS
# ============================================================================

puts
puts "parse - invalid inputs:"

Test("raises ParseError for wrong field count") do
  ["", "K", "K /", "K / C/c extra"].each do |input|
    begin; Parser.parse(input); raise "should raise for #{input.inspect}"
    rescue Sashite::Feen::ParseError; end
  end
end

Test("raises ParseError for string too long") do
  begin; Parser.parse("K" * 4097 + " / C/c"); raise "should raise"
  rescue Sashite::Feen::ParseError; end
end

Test("raises specific error for each field") do
  begin; Parser.parse("/K / C/c"); raise "x"
  rescue Sashite::Feen::PiecePlacementError; end

  begin; Parser.parse("K PP/ C/c"); raise "x"
  rescue Sashite::Feen::HandsError; end

  begin; Parser.parse("K / C/C"); raise "x"
  rescue Sashite::Feen::StyleTurnError; end
end

# ============================================================================
# VALID?
# ============================================================================

puts
puts "valid?:"

Test("true for valid FEEN strings") do
  raise unless Parser.valid?("K / C/c")
  raise unless Parser.valid?("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c")
  raise unless Parser.valid?("8/8/8/8/8/8/8/8 / C/c")
end

Test("false for invalid inputs") do
  raise if Parser.valid?("invalid")
  raise if Parser.valid?("")
  raise if Parser.valid?(nil)
  raise if Parser.valid?(123)
  raise if Parser.valid?(:symbol)
  raise if Parser.valid?("K PP/ C/c")             # invalid hands
  raise if Parser.valid?("rkr//PPPP / G/g")        # dimensional coherence
  raise if Parser.valid?("K 2P/ C/c")              # cardinality violation
end

Test("never raises for any input") do
  [nil, 123, :symbol, [], {}, "", "invalid", "K", "K / C/C", "x" * 10_000].each do |input|
    begin
      result = Parser.valid?(input)
      raise "non-boolean for #{input.inspect}" unless result == true || result == false
    rescue StandardError => e
      raise "raised for #{input.inspect}: #{e.message}"
    end
  end
end

# ============================================================================
# MODULE PROPERTIES
# ============================================================================

puts
puts "module properties:"

Test("module is frozen") do
  raise unless Parser.frozen?
end

puts
puts "All Parser tests passed!"
puts
