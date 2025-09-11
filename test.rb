# frozen_string_literal: true

require "simplecov"
SimpleCov.command_name "Unit Tests"
SimpleCov.start

# Tests for Sashite::Feen (Forsyth–Edwards Enhanced Notation)
#
# This suite assumes the existence of:
# - lib/sashite/feen.rb  (public API)
# - and its sub-files already required by that entry point.
#
# It also assumes runtime deps are available:
# - sashite-epin
# - sashite-sin
#
# NOTE: No test framework is used; failures exit(1).

# Try to load the gem entry point; fallback to the direct path if needed.
begin
  require_relative "lib/sashite-feen"
rescue LoadError
  require_relative "lib/sashite/feen"
end

# Helper to run a test and report
def run_test(name)
  print "  #{name}... "
  yield
  puts "✓ Success"
rescue StandardError => e
  warn "✗ Failure: #{e.message}"
  warn "    #{e.backtrace.first}"
  exit(1)
end

puts
puts "Tests for Sashite::Feen"
puts

Feen      = Sashite::Feen
Parser    = Sashite::Feen::Parser
PP        = Sashite::Feen::Parser::PiecePlacement
PH        = Sashite::Feen::Parser::PiecesInHand
ST        = Sashite::Feen::Parser::StyleTurn
Err       = Sashite::Feen::Error

# -----------------------------------------------------------------------------
# StyleTurn (strict FEEN+SIN) — valid cases
# -----------------------------------------------------------------------------
run_test("StyleTurn: accepts valid style/turn pairs with SIN letters") do
  valid = ["C/c", "c/C", "S/o", "x/Y", "M/n", "Z/z".sub("Z/z", "Z/z".downcase).sub("z/z", "z/Z")]
  # Normalize examples:
  valid = ["C/c", "c/C", "S/o"]

  valid.each do |s|
    obj = ST.parse(s)
    raise "parse returned nil for #{s}" unless obj
  end
end

# -----------------------------------------------------------------------------
# StyleTurn — invalid formats (spaces, single letter, both upper/lower)
# -----------------------------------------------------------------------------
run_test("StyleTurn: rejects invalid formats and ambiguous turn") do
  invalid = [
    "w", "b", "C c", "C / c", "Cc", "c/c", "C/C", "x/y ",
    "", " A/a", "A/a\n", "a/a", "A/A"
  ]

  invalid.each do |s|
    begin
      ST.parse(s)
      raise "Should have raised for #{s.inspect}"
    rescue Err::Syntax, Err::Style
      # expected
    end
  end
end

# -----------------------------------------------------------------------------
# PiecePlacement — basic empty board, consistent width
# -----------------------------------------------------------------------------
run_test("PiecePlacement: parses 8x8 all-empty board with slashes") do
  placement = PP.parse("8/8/8/8/8/8/8/8")
  grid = placement.grid
  raise "grid should be 8 rows" unless grid.size == 8
  raise "each row should be 8 wide" unless grid.all? { |r| r.size == 8 }
  empties = grid.flatten.count(&:nil?)
  raise "should be 64 empty cells" unless empties == 64
end

# -----------------------------------------------------------------------------
# PiecePlacement — digits + dot + separators tolerance
# -----------------------------------------------------------------------------
run_test("PiecePlacement: digits + single piece + commas/spaces tolerated within rank") do
  # First rank: 3 empties, 1 piece, 4 empties => 8
  # Last rank : 2 empties, 1 piece, 5 empties => 8
  placement = PP.parse("3P4/8/8/8/8/8/8/2k5")
  grid = placement.grid
  raise "grid should be 8 rows" unless grid.size == 8
  raise "row width should be 8" unless grid.all? { |r| r.size == 8 }
  raise "rank1 col4 should be non-empty" if grid[0][3].nil?
  raise "rank8 col3 should be non-empty" if grid[7][2].nil?
end

# -----------------------------------------------------------------------------
# PiecePlacement — inconsistent width must fail
# -----------------------------------------------------------------------------
run_test("PiecePlacement: inconsistent width raises Error::Bounds") do
  begin
    PP.parse("2/3")
    raise "Should have raised Error::Bounds for inconsistent widths"
  rescue Err::Bounds
    # expected
  end
end

# -----------------------------------------------------------------------------
# PiecesInHand — basic forms ('-', token, NxTOKEN, TOKEN*2)
# -----------------------------------------------------------------------------
run_test("PiecesInHand: parses '-', single tokens, and counted entries") do
  h0 = PH.parse("-")
  raise "hands should be empty" unless h0.map.empty?

  h1 = PH.parse("P")
  raise "single P should count to 1" unless h1.map.values.sum == 1

  h2 = PH.parse("2xP")
  raise "2xP should count to 2" unless h2.map.values.sum == 2

  h3 = PH.parse("P*2")
  raise "P*2 should count to 2" unless h3.map.values.sum == 2

  h4 = PH.parse("P,2xP")
  raise "P + 2xP should count to 3" unless h4.map.values.sum == 3
end

# -----------------------------------------------------------------------------
# PiecesInHand — invalid counts and malformed fields
# -----------------------------------------------------------------------------
run_test("PiecesInHand: rejects zero/negative counts and malformed fields") do
  begin
    PH.parse("0xP")
    raise "Should have raised for 0xP"
  rescue Err::Count
    # expected
  end

  begin
    PH.parse("")
    raise "Should have raised for empty field"
  rescue Err::Syntax
    # expected
  end

  begin
    PH.parse(" , , ")
    raise "Should have raised for commas only"
  rescue Err::Syntax
    # expected
  end
end

# -----------------------------------------------------------------------------
# Top-level FEEN.parse — minimal empty board with hands '-' and style-turn
# -----------------------------------------------------------------------------
run_test("Feen.parse: accepts minimal FEEN with multiple spaces between fields") do
  feen = "8/8/8/8/8/8/8/8   -   C/c"
  pos = Feen.parse(feen)
  raise "parse returned nil" unless pos
  raise "position should be frozen" unless pos.frozen?

  grid = pos.placement.grid
  raise "grid should be 8x8" unless grid.size == 8 && grid.all? { |r| r.size == 8 }
  raise "hands should be empty" unless pos.hands.map.empty?
end

# -----------------------------------------------------------------------------
# Top-level FEEN.parse — invalid (missing fields, or bad style_turn)
# -----------------------------------------------------------------------------
run_test("Feen.parse: rejects invalid FEEN strings") do
  invalid = [
    "",                            # empty
    "8/8/8/8/8/8/8/8 -",           # missing 3rd field
    "8/8/8/8/8/8/8/8 C/c",         # missing hands separator/field
    "8/8/8/8/8/8/8/8 - c/c",       # ambiguous turn (both lowercase)
    "8/8/8/8/8/8/8/8 - C/C",       # ambiguous turn (both uppercase)
    "8/8/8/8/8/8/8/8 - C / c"      # whitespace not allowed inside style_turn
  ]

  invalid.each do |s|
    begin
      Feen.parse(s)
      raise "Should have raised for #{s.inspect}"
    rescue Err::Syntax, Err::Style
      # expected
    end
  end
end

# -----------------------------------------------------------------------------
# Feen.valid? — true for valid, false for invalid
# -----------------------------------------------------------------------------
run_test("Feen.valid?: true for valid FEEN, false otherwise") do
  valid   = "8/8/8/8/8/8/8/8 - C/c"
  invalid = "8/8/8/8/8/8/8/8 - c/c"

  raise "valid? should be true"  unless Feen.valid?(valid)
  raise "valid? should be false" if     Feen.valid?(invalid)
end

# -----------------------------------------------------------------------------
# Parser coercion and error normalization
# -----------------------------------------------------------------------------
run_test("Parser: String() coercion and empty input handled as syntax error") do
  begin
    Feen.parse(nil)  # String(nil) => "", then empty => Error::Syntax
    raise "Should have raised Error::Syntax for nil coerced to empty"
  rescue Err::Syntax
    # expected
  end

  begin
    Parser.parse("   ")
    raise "Should have raised Error::Syntax for whitespace-only"
  rescue Err::Syntax
    # expected
  end
end

puts
puts "All FEEN tests passed!"
puts
