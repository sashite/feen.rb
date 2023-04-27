# frozen_string_literal: true

require "simplecov"

::SimpleCov.command_name "Brutal test suite"
::SimpleCov.start

begin
  require_relative "../../lib/feen"
rescue ::LoadError
  # :nocov:
  require "../../lib/feen"
  # :nocov:
end

# ------------------------------------------------------------------------------

# Starting a test

actual = Feen.parse("8/8/8/8/8/8/8/8//8/8/8/8/8/8/8/8//8/8/8/8/8/8/8/8 0", regex: Regexp.new("[A-Za-z]"))

raise if actual.to_h != { board_shape: [3, 8, 8], piece_placement: {}, side_to_move: "0" }

# Finishing a test

# ------------------------------------------------------------------------------

# Starting a test

actual = Feen.parse("3yRyNyByKyQyByNyR3/3yPyPyPyPyPyPyPyP3/14/bRbP10gPgR/bNbP10gPgN/bBbP10gPgB/bKbP10gPgQ/bQbP10gPgK/bBbP10gPgB/bNbP10gPgN/bRbP10gPgR/14/3rPrPrPrPrPrPrPrP3/3rRrNrBrQrKrBrNrR3 0", regex: Regexp.new("[A-Za-z]"))

if actual.to_h != { board_shape: [14, 22], piece_placement: { 3 => "y", 4 => "R", 5 => "y", 6 => "N", 7 => "y", 8 => "B", 9 => "y", 10 => "K", 11 => "y", 12 => "Q", 13 => "y", 14 => "B", 15 => "y", 16 => "N", 17 => "y", 18 => "R", 25 => "y", 26 => "P", 27 => "y", 28 => "P", 29 => "y", 30 => "P", 31 => "y", 32 => "P", 33 => "y", 34 => "P", 35 => "y", 36 => "P", 37 => "y", 38 => "P", 39 => "y", 40 => "P", 58 => "b", 59 => "R", 60 => "b", 61 => "P", 72 => "g", 73 => "P", 74 => "g", 75 => "R", 76 => "b", 77 => "N", 78 => "b", 79 => "P", 90 => "g", 91 => "P", 92 => "g", 93 => "N", 94 => "b", 95 => "B", 96 => "b", 97 => "P", 108 => "g", 109 => "P", 110 => "g", 111 => "B", 112 => "b", 113 => "K", 114 => "b", 115 => "P", 126 => "g", 127 => "P", 128 => "g", 129 => "Q", 130 => "b", 131 => "Q", 132 => "b", 133 => "P", 144 => "g", 145 => "P", 146 => "g", 147 => "K", 148 => "b", 149 => "B", 150 => "b", 151 => "P", 162 => "g", 163 => "P", 164 => "g", 165 => "B", 166 => "b", 167 => "N", 168 => "b", 169 => "P", 180 => "g", 181 => "P", 182 => "g", 183 => "N", 184 => "b", 185 => "R", 186 => "b", 187 => "P", 198 => "g", 199 => "P", 200 => "g", 201 => "R", 219 => "r", 220 => "P", 221 => "r", 222 => "P", 223 => "r", 224 => "P", 225 => "r", 226 => "P", 227 => "r", 228 => "P", 229 => "r", 230 => "P", 231 => "r", 232 => "P", 233 => "r", 234 => "P", 241 => "r", 242 => "R", 243 => "r", 244 => "N", 245 => "r", 246 => "B", 247 => "r", 248 => "Q", 249 => "r", 250 => "K", 251 => "r", 252 => "B", 253 => "r", 254 => "N", 255 => "r", 256 => "R" }, side_to_move: "0" }
  raise
end

# Finishing a test

# ------------------------------------------------------------------------------

# Starting a test

actual = Feen.parse("♜♞♝♛♚♝♞♜/♟♟♟♟♟♟♟♟/8/8/8/8/♙♙♙♙♙♙♙♙/♖♘♗♕♔♗♘♖ 0", regex: Regexp.new("[A-Za-z]"))

raise if actual.to_h != { board_shape: [8, 0], piece_placement: {}, side_to_move: "0" }

# Finishing a test

# ------------------------------------------------------------------------------

# Starting a test

actual = Feen.parse("♜♞♝♛♚♝♞♜/♟♟♟♟♟♟♟♟/8/8/4♙3/8/♙♙♙♙1♙♙♙/♖♘♗♕♔♗♘♖ 1", regex: Regexp.new("[A-Za-z]"))

raise if actual.to_h != { board_shape: [8, 0], piece_placement: {}, side_to_move: "1" }

# Finishing a test

# ------------------------------------------------------------------------------

# Starting a test

actual = Feen.parse("♜♞♝♛♚♝♞♜/♟♟♟♟1♟♟♟/8/4♟3/4♙3/8/♙♙♙♙1♙♙♙/♖♘♗♕♔♗♘♖ 0", regex: Regexp.new("[A-Za-z]"))

raise if actual.to_h != { board_shape: [8, 0], piece_placement: {}, side_to_move: "0" }

# Finishing a test

# ------------------------------------------------------------------------------

# Starting a test

actual = Feen.parse("♜♞♝♛♚♝♞♜/8/♟♟♟♟♟♟♟♟/8/8/♙♙♙♙♙♙♙♙/8/♖♘♗♔♕♗♘♖ 0", regex: Regexp.new("[A-Za-z]"))

raise if actual.to_h != { board_shape: [8, 0], piece_placement: {}, side_to_move: "0" }

# Finishing a test

# ------------------------------------------------------------------------------

# Starting a test

actual = Feen.parse("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL 0", regex: Regexp.new("[A-Za-z]"))

if actual.to_h != { board_shape: [9, 9], piece_placement: { 0 => "l", 1 => "n", 2 => "s", 3 => "g", 4 => "k", 5 => "g", 6 => "s", 7 => "n", 8 => "l", 10 => "r", 16 => "b", 18 => "p", 19 => "p", 20 => "p", 21 => "p", 22 => "p", 23 => "p", 24 => "p", 25 => "p", 26 => "p", 54 => "P", 55 => "P", 56 => "P", 57 => "P", 58 => "P", 59 => "P", 60 => "P", 61 => "P", 62 => "P", 64 => "B", 70 => "R", 72 => "L", 73 => "N", 74 => "S", 75 => "G", 76 => "K", 77 => "G", 78 => "S", 79 => "N", 80 => "L" }, side_to_move: "0" }
  raise
end

# Finishing a test

# ------------------------------------------------------------------------------

# Starting a test

actual = Feen.parse("3sks3/9/4+P4/9/7+B1/9/9/9/9 0", regex: Regexp.new("[A-Za-z]"))

if actual.to_h != { board_shape: [9, 9], piece_placement: { 3 => "s", 4 => "k", 5 => "s", 22 => "P", 43 => "B" }, side_to_move: "0" }
  raise
end

# Finishing a test

# ------------------------------------------------------------------------------

# Starting a test

actual = Feen.parse("車馬象士將士象馬車/9/1砲5砲1/卒1卒1卒1卒1卒/9/9/兵1兵1兵1兵1兵/1炮5炮1/9/俥傌相仕帥仕相傌俥 0", regex: Regexp.new("[A-Za-z]"))

raise if actual.to_h != { board_shape: [10, 0], piece_placement: {}, side_to_move: "0" }

# Finishing a test

# ------------------------------------------------------------------------------

# Starting a test

actual = Feen.parse("8/8/8/8/8/8/8/8//8/8/8/8/8/8/8/8//8/8/8/8/8/8/8/8 0", regex: Regexp.new("[A-Za-z]{2}"))

raise if actual.to_h != { board_shape: [3, 8, 8], piece_placement: {}, side_to_move: "0" }

# Finishing a test

# ------------------------------------------------------------------------------

# Starting a test

actual = Feen.parse("3yRyNyByKyQyByNyR3/3yPyPyPyPyPyPyPyP3/14/bRbP10gPgR/bNbP10gPgN/bBbP10gPgB/bKbP10gPgQ/bQbP10gPgK/bBbP10gPgB/bNbP10gPgN/bRbP10gPgR/14/3rPrPrPrPrPrPrPrP3/3rRrNrBrQrKrBrNrR3 0", regex: Regexp.new("[A-Za-z]{2}"))

if actual.to_h != { board_shape: [14, 14], piece_placement: { 3 => "yR", 4 => "yN", 5 => "yB", 6 => "yK", 7 => "yQ", 8 => "yB", 9 => "yN", 10 => "yR", 17 => "yP", 18 => "yP", 19 => "yP", 20 => "yP", 21 => "yP", 22 => "yP", 23 => "yP", 24 => "yP", 42 => "bR", 43 => "bP", 54 => "gP", 55 => "gR", 56 => "bN", 57 => "bP", 68 => "gP", 69 => "gN", 70 => "bB", 71 => "bP", 82 => "gP", 83 => "gB", 84 => "bK", 85 => "bP", 96 => "gP", 97 => "gQ", 98 => "bQ", 99 => "bP", 110 => "gP", 111 => "gK", 112 => "bB", 113 => "bP", 124 => "gP", 125 => "gB", 126 => "bN", 127 => "bP", 138 => "gP", 139 => "gN", 140 => "bR", 141 => "bP", 152 => "gP", 153 => "gR", 171 => "rP", 172 => "rP", 173 => "rP", 174 => "rP", 175 => "rP", 176 => "rP", 177 => "rP", 178 => "rP", 185 => "rR", 186 => "rN", 187 => "rB", 188 => "rQ", 189 => "rK", 190 => "rB", 191 => "rN", 192 => "rR" }, side_to_move: "0" }
  raise
end

# Finishing a test

# ------------------------------------------------------------------------------

# Starting a test

actual = Feen.parse("♜♞♝♛♚♝♞♜/♟♟♟♟♟♟♟♟/8/8/8/8/♙♙♙♙♙♙♙♙/♖♘♗♕♔♗♘♖ 0", regex: Regexp.new("[A-Za-z]{2}"))

raise if actual.to_h != { board_shape: [8, 0], piece_placement: {}, side_to_move: "0" }

# Finishing a test

# ------------------------------------------------------------------------------

# Starting a test

actual = Feen.parse("♜♞♝♛♚♝♞♜/♟♟♟♟♟♟♟♟/8/8/4♙3/8/♙♙♙♙1♙♙♙/♖♘♗♕♔♗♘♖ 1", regex: Regexp.new("[A-Za-z]{2}"))

raise if actual.to_h != { board_shape: [8, 0], piece_placement: {}, side_to_move: "1" }

# Finishing a test

# ------------------------------------------------------------------------------

# Starting a test

actual = Feen.parse("♜♞♝♛♚♝♞♜/♟♟♟♟1♟♟♟/8/4♟3/4♙3/8/♙♙♙♙1♙♙♙/♖♘♗♕♔♗♘♖ 0", regex: Regexp.new("[A-Za-z]{2}"))

raise if actual.to_h != { board_shape: [8, 0], piece_placement: {}, side_to_move: "0" }

# Finishing a test

# ------------------------------------------------------------------------------

# Starting a test

actual = Feen.parse("♜♞♝♛♚♝♞♜/8/♟♟♟♟♟♟♟♟/8/8/♙♙♙♙♙♙♙♙/8/♖♘♗♔♕♗♘♖ 0", regex: Regexp.new("[A-Za-z]{2}"))

raise if actual.to_h != { board_shape: [8, 0], piece_placement: {}, side_to_move: "0" }

# Finishing a test

# ------------------------------------------------------------------------------

# Starting a test

actual = Feen.parse("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL 0", regex: Regexp.new("[A-Za-z]{2}"))

if actual.to_h != { board_shape: [9, 4], piece_placement: { 0 => "ln", 1 => "sg", 2 => "kg", 3 => "sn", 11 => "pp", 12 => "pp", 13 => "pp", 14 => "pp", 42 => "PP", 43 => "PP", 44 => "PP", 45 => "PP", 53 => "LN", 54 => "SG", 55 => "KG", 56 => "SN" }, side_to_move: "0" }
  raise
end

# Finishing a test

# ------------------------------------------------------------------------------

# Starting a test

actual = Feen.parse("3sks3/9/4+P4/9/7+B1/9/9/9/9 0", regex: Regexp.new("[A-Za-z]{2}"))

raise if actual.to_h != { board_shape: [9, 7], piece_placement: { 3=>"sk" }, side_to_move: "0" }

# Finishing a test

# ------------------------------------------------------------------------------

# Starting a test

actual = Feen.parse("車馬象士將士象馬車/9/1砲5砲1/卒1卒1卒1卒1卒/9/9/兵1兵1兵1兵1兵/1炮5炮1/9/俥傌相仕帥仕相傌俥 0", regex: Regexp.new("[A-Za-z]{2}"))

raise if actual.to_h != { board_shape: [10, 0], piece_placement: {}, side_to_move: "0" }

# Finishing a test

# ------------------------------------------------------------------------------

# Starting a test

actual = Feen.parse("8/8/8/8/8/8/8/8//8/8/8/8/8/8/8/8//8/8/8/8/8/8/8/8 0", regex: Regexp.new("[+]?[A-Za-z]"))

raise if actual.to_h != { board_shape: [3, 8, 8], piece_placement: {}, side_to_move: "0" }

# Finishing a test

# ------------------------------------------------------------------------------

# Starting a test

actual = Feen.parse("3yRyNyByKyQyByNyR3/3yPyPyPyPyPyPyPyP3/14/bRbP10gPgR/bNbP10gPgN/bBbP10gPgB/bKbP10gPgQ/bQbP10gPgK/bBbP10gPgB/bNbP10gPgN/bRbP10gPgR/14/3rPrPrPrPrPrPrPrP3/3rRrNrBrQrKrBrNrR3 0", regex: Regexp.new("[+]?[A-Za-z]"))

if actual.to_h != { board_shape: [14, 22], piece_placement: { 3 => "y", 4 => "R", 5 => "y", 6 => "N", 7 => "y", 8 => "B", 9 => "y", 10 => "K", 11 => "y", 12 => "Q", 13 => "y", 14 => "B", 15 => "y", 16 => "N", 17 => "y", 18 => "R", 25 => "y", 26 => "P", 27 => "y", 28 => "P", 29 => "y", 30 => "P", 31 => "y", 32 => "P", 33 => "y", 34 => "P", 35 => "y", 36 => "P", 37 => "y", 38 => "P", 39 => "y", 40 => "P", 58 => "b", 59 => "R", 60 => "b", 61 => "P", 72 => "g", 73 => "P", 74 => "g", 75 => "R", 76 => "b", 77 => "N", 78 => "b", 79 => "P", 90 => "g", 91 => "P", 92 => "g", 93 => "N", 94 => "b", 95 => "B", 96 => "b", 97 => "P", 108 => "g", 109 => "P", 110 => "g", 111 => "B", 112 => "b", 113 => "K", 114 => "b", 115 => "P", 126 => "g", 127 => "P", 128 => "g", 129 => "Q", 130 => "b", 131 => "Q", 132 => "b", 133 => "P", 144 => "g", 145 => "P", 146 => "g", 147 => "K", 148 => "b", 149 => "B", 150 => "b", 151 => "P", 162 => "g", 163 => "P", 164 => "g", 165 => "B", 166 => "b", 167 => "N", 168 => "b", 169 => "P", 180 => "g", 181 => "P", 182 => "g", 183 => "N", 184 => "b", 185 => "R", 186 => "b", 187 => "P", 198 => "g", 199 => "P", 200 => "g", 201 => "R", 219 => "r", 220 => "P", 221 => "r", 222 => "P", 223 => "r", 224 => "P", 225 => "r", 226 => "P", 227 => "r", 228 => "P", 229 => "r", 230 => "P", 231 => "r", 232 => "P", 233 => "r", 234 => "P", 241 => "r", 242 => "R", 243 => "r", 244 => "N", 245 => "r", 246 => "B", 247 => "r", 248 => "Q", 249 => "r", 250 => "K", 251 => "r", 252 => "B", 253 => "r", 254 => "N", 255 => "r", 256 => "R" }, side_to_move: "0" }
  raise
end

# Finishing a test

# ------------------------------------------------------------------------------

# Starting a test

actual = Feen.parse("♜♞♝♛♚♝♞♜/♟♟♟♟♟♟♟♟/8/8/8/8/♙♙♙♙♙♙♙♙/♖♘♗♕♔♗♘♖ 0", regex: Regexp.new("[+]?[A-Za-z]"))

raise if actual.to_h != { board_shape: [8, 0], piece_placement: {}, side_to_move: "0" }

# Finishing a test

# ------------------------------------------------------------------------------

# Starting a test

actual = Feen.parse("♜♞♝♛♚♝♞♜/♟♟♟♟♟♟♟♟/8/8/4♙3/8/♙♙♙♙1♙♙♙/♖♘♗♕♔♗♘♖ 1", regex: Regexp.new("[+]?[A-Za-z]"))

raise if actual.to_h != { board_shape: [8, 0], piece_placement: {}, side_to_move: "1" }

# Finishing a test

# ------------------------------------------------------------------------------

# Starting a test

actual = Feen.parse("♜♞♝♛♚♝♞♜/♟♟♟♟1♟♟♟/8/4♟3/4♙3/8/♙♙♙♙1♙♙♙/♖♘♗♕♔♗♘♖ 0", regex: Regexp.new("[+]?[A-Za-z]"))

raise if actual.to_h != { board_shape: [8, 0], piece_placement: {}, side_to_move: "0" }

# Finishing a test

# ------------------------------------------------------------------------------

# Starting a test

actual = Feen.parse("♜♞♝♛♚♝♞♜/8/♟♟♟♟♟♟♟♟/8/8/♙♙♙♙♙♙♙♙/8/♖♘♗♔♕♗♘♖ 0", regex: Regexp.new("[+]?[A-Za-z]"))

raise if actual.to_h != { board_shape: [8, 0], piece_placement: {}, side_to_move: "0" }

# Finishing a test

# ------------------------------------------------------------------------------

# Starting a test

actual = Feen.parse("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL 0", regex: Regexp.new("[+]?[A-Za-z]"))

if actual.to_h != { board_shape: [9, 9], piece_placement: { 0 => "l", 1 => "n", 2 => "s", 3 => "g", 4 => "k", 5 => "g", 6 => "s", 7 => "n", 8 => "l", 10 => "r", 16 => "b", 18 => "p", 19 => "p", 20 => "p", 21 => "p", 22 => "p", 23 => "p", 24 => "p", 25 => "p", 26 => "p", 54 => "P", 55 => "P", 56 => "P", 57 => "P", 58 => "P", 59 => "P", 60 => "P", 61 => "P", 62 => "P", 64 => "B", 70 => "R", 72 => "L", 73 => "N", 74 => "S", 75 => "G", 76 => "K", 77 => "G", 78 => "S", 79 => "N", 80 => "L" }, side_to_move: "0" }
  raise
end

# Finishing a test

# ------------------------------------------------------------------------------

# Starting a test

actual = Feen.parse("3sks3/9/4+P4/9/7+B1/9/9/9/9 0", regex: Regexp.new("[+]?[A-Za-z]"))

if actual.to_h != { board_shape: [9, 9], piece_placement: { 3 => "s", 4 => "k", 5 => "s", 22 => "+P", 43 => "+B" }, side_to_move: "0" }
  raise
end

# Finishing a test

# ------------------------------------------------------------------------------

# Starting a test

actual = Feen.parse("車馬象士將士象馬車/9/1砲5砲1/卒1卒1卒1卒1卒/9/9/兵1兵1兵1兵1兵/1炮5炮1/9/俥傌相仕帥仕相傌俥 0", regex: Regexp.new("[+]?[A-Za-z]"))

raise if actual.to_h != { board_shape: [10, 0], piece_placement: {}, side_to_move: "0" }

# Finishing a test

# ------------------------------------------------------------------------------

# End of the brutal test
