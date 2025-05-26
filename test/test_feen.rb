# frozen_string_literal: true

require_relative "../lib/feen"

# File: test/test_feen.rb

# --- Test parse method ---

# Test 1: Basic parse functionality with standard chess position
begin
  feen_string = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR - CHESS/chess"
  parsed = Feen.parse(feen_string)
  raise "Test 1 failed: parse returned nil" if parsed.nil?
  raise "Test 1 failed: parse returned incorrect data structure" unless parsed.is_a?(Hash)

  puts "Test 1 passed: parse works with standard chess position"
end

# Test 2: Parse with pieces in hand
begin
  feen_string = "lnsgk2nl/1r4gs1/p1pppp1pp/1p4p2/7P1/2P6/PP1PPPP1P/1SG4R1/LN2KGSNL Bb SHOGI/shogi"
  parsed = Feen.parse(feen_string)
  expected_pieces_in_hand = %w[B b]
  raise "Test 2 failed: pieces in hand not parsed correctly" unless parsed[:pieces_in_hand] == expected_pieces_in_hand

  puts "Test 2 passed: parse works with pieces in hand"
end

# Test 3: Parse with 3D position
begin
  feen_string = "rnb/qkp//PR1/1KQ - FOO/bar"
  parsed = Feen.parse(feen_string)
  raise "Test 3 failed: 3D position not parsed correctly" unless parsed[:piece_placement].is_a?(Array) &&
                                                                 parsed[:piece_placement].all? do |dim|
                                                                   dim.is_a?(Array)
                                                                 end &&
                                                                 parsed[:piece_placement][0][0].is_a?(Array)

  puts "Test 3 passed: parse works with 3D position"
end

# Test 4: Parse with modified pieces (prefixes/suffixes)
begin
  feen_string = "rnbqkbnr/pppppppp/8/4+P3/8/8/PPPP1PPP/RNBQKBNR - CHESS/chess"
  parsed = Feen.parse(feen_string)
  modified_pawn = parsed[:piece_placement][3][4] # 5th rank, 5th file
  white_rook = parsed[:piece_placement][7][0] # 1st rank, 1st file
  black_rook = parsed[:piece_placement][0][0] # 8th rank, 1st file
  raise "Test 4 failed: modified pawn not correctly parsed" unless modified_pawn == "+P"
  raise "Test 4 failed: white rook not correctly parsed" unless white_rook == "R"
  raise "Test 4 failed: black rook not correctly parsed" unless black_rook == "r"

  puts "Test 4 passed: parse works with piece modifications"
end

# Test 5: Parse throws exception on invalid input
begin
  invalid_feen = "invalid feen string"
  exception_thrown = false
  begin
    Feen.parse(invalid_feen)
  rescue ArgumentError
    exception_thrown = true
  end
  raise "Test 5 failed: parse didn't raise exception on invalid input" unless exception_thrown

  puts "Test 5 passed: parse raises exception on invalid input"
end

# --- Test safe_parse method ---

# Test 6: safe_parse with valid input
begin
  feen_string = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR - CHESS/chess"
  result = Feen.safe_parse(feen_string)
  raise "Test 6 failed: safe_parse returned nil for valid input" if result.nil?
  raise "Test 6 failed: safe_parse returned incorrect data" unless result[:games_turn] == %w[CHESS chess]

  puts "Test 6 passed: safe_parse works with valid input"
end

# Test 7: safe_parse with invalid input
begin
  invalid_feen = "invalid feen string"
  result = Feen.safe_parse(invalid_feen)
  raise "Test 7 failed: safe_parse didn't return nil for invalid input" unless result.nil?

  puts "Test 7 passed: safe_parse returns nil for invalid input"
end

# --- Test dump method ---

# Test 8: Basic dump functionality
begin
  piece_placement = [
    ["r", "n", "b", "q", "k", "b", "n", "r"],
    ["p", "p", "p", "p", "p", "p", "p", "p"],
    ["", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", ""],
    ["P", "P", "P", "P", "P", "P", "P", "P"],
    ["R", "N", "B", "Q", "K", "B", "N", "R"]
  ]
  feen_string = Feen.dump(
    piece_placement: piece_placement,
    pieces_in_hand:  [],
    games_turn:      %w[CHESS chess]
  )
  expected = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR - CHESS/chess"
  raise "Test 8 failed: dump didn't produce expected FEEN string" unless feen_string == expected

  puts "Test 8 passed: dump works with standard position"
end

# Test 9: Dump with pieces in hand
begin
  piece_placement = [
    ["l", "n", "s", "g", "k", "", "", "n", "l"],
    ["", "r", "", "", "", "", "g", "s", ""],
    ["p", "", "p", "p", "p", "p", "", "p", "p"],
    ["", "p", "", "", "", "", "p", "", ""],
    ["", "", "", "", "", "", "", "P", ""],
    ["", "", "P", "", "", "", "", "", ""],
    ["P", "P", "", "P", "P", "P", "P", "", "P"],
    ["", "S", "G", "", "", "", "", "R", ""],
    ["L", "N", "", "", "K", "G", "S", "N", "L"]
  ]
  feen_string = Feen.dump(
    piece_placement: piece_placement,
    pieces_in_hand:  %w[B b],
    games_turn:      %w[SHOGI shogi]
  )
  raise "Test 9 failed: dump didn't include pieces in hand" unless feen_string.include?(" Bb ")

  puts "Test 9 passed: dump works with pieces in hand"
end

# Test 10: Round-trip consistency
begin
  original = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR - CHESS/chess"
  parsed = Feen.parse(original)
  regenerated = Feen.dump(
    piece_placement: parsed[:piece_placement],
    pieces_in_hand:  parsed[:pieces_in_hand],
    games_turn:      parsed[:games_turn]
  )
  raise "Test 10 failed: round-trip parsing and dumping not consistent" unless original == regenerated

  puts "Test 10 passed: round-trip parse/dump maintains consistency"
end

# --- Test valid? method ---

# Test 11: valid? with canonical form
begin
  canonical_feen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR - CHESS/chess"
  raise "Test 11 failed: valid? rejected a canonical FEEN" unless Feen.valid?(canonical_feen)

  puts "Test 11 passed: valid? accepts canonical form"
end

# Test 12: valid? with invalid syntax
begin
  invalid_feen = "invalid feen format"
  raise "Test 12 failed: valid? accepted an invalid FEEN" if Feen.valid?(invalid_feen)

  puts "Test 12 passed: valid? rejects invalid syntax"
end

# --- Test error cases and edge cases ---

# Test 13: Empty board
begin
  feen_string = "8/8/8/8/8/8/8/8 - CHESS/chess"
  parsed = Feen.parse(feen_string)
  dumped = Feen.dump(
    piece_placement: parsed[:piece_placement],
    pieces_in_hand:  parsed[:pieces_in_hand],
    games_turn:      parsed[:games_turn]
  )
  raise "Test 13 failed: empty board parsing/dumping not consistent" unless dumped == feen_string

  puts "Test 13 passed: handles empty board correctly"
end

# Test 14: Multiple pieces in hand with counts (canonical ordering)
begin
  # Original FEEN string with non-canonical pieces in hand order
  # "N2P2gln2s" needs to be reordered canonically

  # Let's determine the canonical order:
  # Pieces: N(1), P(2), g(2), l(1), n(1), s(2)
  # Canonical order: by quantity desc, then alphabetical
  # Quantities: P(2), g(2), s(2), N(1), l(1), n(1)
  # Alphabetical within same quantity:
  #   - Quantity 2: P < g < s -> 2P2g2s
  #   - Quantity 1: N < l < n -> Nln
  # Final canonical order: 2P2g2sNln

  feen_string = "lnsgk3l/5g3/p1ppB2pp/9/8B/2P6/P2PPPPPP/3K3R1/5rSNL 2P2g2sNln SHOGI/shogi"
  parsed = Feen.parse(feen_string)

  # Verify the parsed pieces in hand are in the expected canonical order
  expected_pieces = %w[P P g g s s N l n]
  actual_pieces = parsed[:pieces_in_hand]

  unless actual_pieces == expected_pieces
    raise "Test 14 failed: Expected pieces #{expected_pieces.inspect}, got #{actual_pieces.inspect}"
  end

  # Count occurrences of each piece to verify correctness
  piece_counts = {}
  parsed[:pieces_in_hand].each do |piece|
    piece_counts[piece] ||= 0
    piece_counts[piece] += 1
  end

  # Verify correct counts for each piece type
  expected_counts = { "N" => 1, "P" => 2, "g" => 2, "l" => 1, "n" => 1, "s" => 2 }
  expected_counts.each do |piece, count|
    actual_count = piece_counts[piece] || 0
    raise "Test 14 failed: expected #{count} of piece '#{piece}', got #{actual_count}" if actual_count != count
  end

  # Verify no extra or missing piece types
  if piece_counts.keys.sort != expected_counts.keys.sort
    raise "Test 14 failed: piece types don't match, got #{piece_counts.keys.sort.inspect}"
  end

  puts "✓ Test 14 passed: handles multiple pieces in hand with canonical ordering"
rescue ArgumentError => e
  raise "Test 14 failed: Unexpected error: #{e.message}"
end

# Test 15: Different game types
begin
  feen_string = "rheagaehr/9/1c5c1/s1s1s1s1s/9/9/S1S1S1S1S/1C5C1/9/RHEAGAEHR - XIANGQI/xiangqi"
  parsed = Feen.parse(feen_string)
  expected_games_turn = %w[XIANGQI xiangqi]
  raise "Test 15 failed: games turn not parsed correctly" unless parsed[:games_turn] == expected_games_turn

  puts "Test 15 passed: handles different game types"
end

puts "All tests passed successfully!"
