# frozen_string_literal: true

require_relative "../lib/feen"

# File: test/test_feen.rb

# --- Test for basic module functionality ---

# --- Test 1: Round-trip parsing and dumping ---
# This tests that a FEEN string can be parsed and then dumped back to the same string
feen_string = "rnbqk=bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK=BNR - CHESS/chess"
parsed = Feen.parse(feen_string)
dumped = Feen.dump(
  piece_placement: parsed[:piece_placement],
  pieces_in_hand:  parsed[:pieces_in_hand],
  games_turn:      parsed[:games_turn]
)
raise "Test 1 failed: Round-trip parsing and dumping does not match" unless dumped == feen_string

# --- Test 5: Validation of valid FEEN string ---
feen_string = "rnbqk=bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK=BNR - CHESS/chess"
raise "Test 5 failed: Valid FEEN string not recognized" unless Feen.valid?(feen_string)

# --- Test 6: Validation of invalid FEEN string ---
invalid_feen = "invalid feen string"
raise "Test 6 failed: Invalid FEEN string incorrectly recognized as valid" if Feen.valid?(invalid_feen)

# --- Test 7: Parsing Shogi position with pieces in hand ---
feen_string = "lnsgk2nl/1r4gs1/p1pppp1pp/1p4p2/7P1/2P6/PP1PPPP1P/1SG4R1/LN2KGSNL Bb SHOGI/shogi"
result = Feen.parse(feen_string)
expected_pieces_in_hand = %w[B b]
raise "Test 7 failed: Pieces in hand not parsed correctly" unless result[:pieces_in_hand] == expected_pieces_in_hand

# --- Test 8: Parsing and dumping 3D position ---
feen_string = "rnb/qkp//PR1/1KQ - FOO/bar"
parsed = Feen.parse(feen_string)
dumped = Feen.dump(
  piece_placement: parsed[:piece_placement],
  pieces_in_hand:  parsed[:pieces_in_hand],
  games_turn:      parsed[:games_turn]
)
raise "Test 8 failed: 3D position parsing and dumping does not match" unless dumped == feen_string

# --- Test 9: Different game types ---
feen_string = "rheagaehr/9/1c5c1/s1s1s1s1s/9/9/S1S1S1S1S/1C5C1/9/RHEAGAEHR - XIANGQI/xiangqi"
parsed = Feen.parse(feen_string)
expected_games_turn = %w[XIANGQI xiangqi]
raise "Test 9 failed: Games turn not parsed correctly" unless parsed[:games_turn] == expected_games_turn

# --- Test 12: Edge cases ---
# Empty board
feen_string = "8/8/8/8/8/8/8/8 - CHESS/chess"
parsed = Feen.parse(feen_string)
dumped = Feen.dump(
  piece_placement: parsed[:piece_placement],
  pieces_in_hand:  parsed[:pieces_in_hand],
  games_turn:      parsed[:games_turn]
)
raise "Test 12 failed: Empty board parsing and dumping does not match" unless dumped == feen_string

# --- Test 15: Modified pieces with prefixes/suffixes ---
feen_string = "rnbqk<bnr/pppppppp/8/4+P3/8/8/PPPP1PPP/RNBQK>BNR - CHESS/chess"
parsed = Feen.parse(feen_string)
modified_pawn = parsed[:piece_placement][3][4] # 5th rank, 5th file
white_king = parsed[:piece_placement][7][4] # 1st rank, 5th file
black_king = parsed[:piece_placement][0][4] # 8th rank, 5th file

raise "Test 15a failed: Modified pawn not correctly parsed" unless modified_pawn == "+P"
raise "Test 15b failed: White king castling rights not correctly parsed" unless white_king == "K>"
raise "Test 15c failed: Black king castling rights not correctly parsed" unless black_king == "k<"

puts "All tests passed successfully!"
