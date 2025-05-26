# frozen_string_literal: true

require_relative "../../../lib/feen/parser/piece_placement"

# Helper method to simplify test assertions
def assert_equal(expected, actual, message = nil)
  if expected == actual
    true
  else
    message ||= "Expected #{expected.inspect}, but got #{actual.inspect}"
    raise message
  end
end

def assert_raises(exception_class, message = nil)
  yield
  raise "Expected #{exception_class} to be raised, but no exception was raised"
rescue StandardError => e
  unless e.is_a?(exception_class)
    message ||= "Expected #{exception_class} to be raised, but got #{e.class}: #{e.message}"
    raise message
  end
  e
end

puts "Testing Feen::Parser::PiecePlacement..."

# -------------------------------------------------------
# Test parsing basic piece placement strings
# -------------------------------------------------------

# Test a single rank with pieces
result = Feen::Parser::PiecePlacement.parse("rnbqkbnr")
assert_equal(%w[r n b q k b n r], result)

# Test a single rank with empty spaces
result = Feen::Parser::PiecePlacement.parse("r1b2k1r")
assert_equal(["r", "", "b", "", "", "k", "", "r"], result)

# Test multiple consecutive empty spaces
result = Feen::Parser::PiecePlacement.parse("8")
assert_equal(["", "", "", "", "", "", "", ""], result)

# Test double-digit number of empty spaces
result = Feen::Parser::PiecePlacement.parse("13")
assert_equal(["", "", "", "", "", "", "", "", "", "", "", "", ""], result)

# -------------------------------------------------------
# Test parsing 2D board representations
# -------------------------------------------------------

# Test a standard chess initial position
result = Feen::Parser::PiecePlacement.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR")
expected = [
  ["r", "n", "b", "q", "k", "b", "n", "r"],
  ["p", "p", "p", "p", "p", "p", "p", "p"],
  ["", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", ""],
  ["P", "P", "P", "P", "P", "P", "P", "P"],
  ["R", "N", "B", "Q", "K", "B", "N", "R"]
]
assert_equal(expected, result)

# Test a Shogi initial position (9x9 board)
result = Feen::Parser::PiecePlacement.parse("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL")
expected = [
  ["l", "n", "s", "g", "k", "g", "s", "n", "l"],
  ["", "r", "", "", "", "", "", "b", ""],
  ["p", "p", "p", "p", "p", "p", "p", "p", "p"],
  ["", "", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", "", ""],
  ["P", "P", "P", "P", "P", "P", "P", "P", "P"],
  ["", "B", "", "", "", "", "", "R", ""],
  ["L", "N", "S", "G", "K", "G", "S", "N", "L"]
]
assert_equal(expected, result)

# Test a position with pieces having modifiers (prefixes and suffixes)
result = Feen::Parser::PiecePlacement.parse("rnbqkbnr/pppppppp/8/3+P4/8/5K2/PPPP1PPP/RNBQ1BNR")
expected = [
  ["r", "n", "b", "q", "k", "b", "n", "r"],
  ["p", "p", "p", "p", "p", "p", "p", "p"],
  ["", "", "", "", "", "", "", ""],
  ["", "", "", "+P", "", "", "", ""],
  ["", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "K", "", ""],
  ["P", "P", "P", "P", "", "P", "P", "P"],
  ["R", "N", "B", "Q", "", "B", "N", "R"]
]
assert_equal(expected, result)

# -------------------------------------------------------
# Test parsing 3D board representations
# -------------------------------------------------------

# Test a simple 3D board (2x2x2)
result = Feen::Parser::PiecePlacement.parse("kp/qr//KP/QR")
expected = [
  [
    %w[k p],
    %w[q r]
  ],
  [
    %w[K P],
    %w[Q R]
  ]
]
assert_equal(expected, result)

# Test a more complex 3D board with empty spaces
result = Feen::Parser::PiecePlacement.parse("k1p/1qr//K1P/1QR")
expected = [
  [
    ["k", "", "p"],
    ["", "q", "r"]
  ],
  [
    ["K", "", "P"],
    ["", "Q", "R"]
  ]
]
assert_equal(expected, result)

# -------------------------------------------------------
# Test validation errors
# -------------------------------------------------------

# Test with non-string input
assert_raises(ArgumentError) do
  Feen::Parser::PiecePlacement.parse(nil)
end

# Test with empty string
assert_raises(ArgumentError) do
  Feen::Parser::PiecePlacement.parse("")
end

# Test with trailing separator
assert_raises(ArgumentError) do
  Feen::Parser::PiecePlacement.parse("rnbqkbnr/")
end

# Test with invalid prefix (nothing after prefix)
assert_raises(ArgumentError) do
  Feen::Parser::PiecePlacement.parse("rnbqk+")
end

# Test with inconsistent rank size
assert_raises(ArgumentError) do
  Feen::Parser::PiecePlacement.parse("rnbqkbnr/ppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR")
end

# Test with inconsistent dimension size
assert_raises(ArgumentError) do
  Feen::Parser::PiecePlacement.parse("kp/qr//KP")
end

# -------------------------------------------------------
# Test shape validation
# -------------------------------------------------------

# Test rectangular 2D board
result = Feen::Parser::PiecePlacement.parse("kq/pp/NN/QK")
expected = [
  %w[k q],
  %w[p p],
  %w[N N],
  %w[Q K]
]
assert_equal(expected, result)

# Test non-square 3D board
result = Feen::Parser::PiecePlacement.parse("kp/qr//KP/QR//xp/yr")
expected = [
  [
    %w[k p],
    %w[q r]
  ],
  [
    %w[K P],
    %w[Q R]
  ],
  [
    %w[x p],
    %w[y r]
  ]
]
assert_equal(expected, result)

# -------------------------------------------------------
# Test special piece modifiers
# -------------------------------------------------------

# Test all valid piece prefixes
result = Feen::Parser::PiecePlacement.parse("+P-P")
expected = ["+P", "-P"]
assert_equal(expected, result)

# Test all valid piece suffixes
result = Feen::Parser::PiecePlacement.parse("P'P'P'")
expected = ["P'", "P'", "P'"]
assert_equal(expected, result)

# Test both prefix and suffix
result = Feen::Parser::PiecePlacement.parse("+P'-P'+P'")
expected = ["+P'", "-P'", "+P'"]
assert_equal(expected, result)

# -------------------------------------------------------
# Test with real-world examples
# -------------------------------------------------------

# Chess after 1. e4
result = Feen::Parser::PiecePlacement.parse("rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR")
expected = [
  ["r", "n", "b", "q", "k", "b", "n", "r"],
  ["p", "p", "p", "p", "p", "p", "p", "p"],
  ["", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", ""],
  ["", "", "", "", "P", "", "", ""],
  ["", "", "", "", "", "", "", ""],
  ["P", "P", "P", "P", "", "P", "P", "P"],
  ["R", "N", "B", "Q", "K", "B", "N", "R"]
]
assert_equal(expected, result)

# Shogi position with promoted pieces
result = Feen::Parser::PiecePlacement.parse("9/9/9/9/4+P4/9/5+B3/9/9")
expected = [
  ["", "", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", "", ""],
  ["", "", "", "", "+P", "", "", "", ""],
  ["", "", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "+B", "", "", ""],
  ["", "", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", "", ""]
]
assert_equal(expected, result)

# Xiangqi (Chinese Chess) initial position
result = Feen::Parser::PiecePlacement.parse("rheagaehr/9/1c5c1/s1s1s1s1s/9/9/S1S1S1S1S/1C5C1/9/RHEAGAEHR")
expected = [
  ["r", "h", "e", "a", "g", "a", "e", "h", "r"],
  ["", "", "", "", "", "", "", "", ""],
  ["", "c", "", "", "", "", "", "c", ""],
  ["s", "", "s", "", "s", "", "s", "", "s"],
  ["", "", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", "", ""],
  ["S", "", "S", "", "S", "", "S", "", "S"],
  ["", "C", "", "", "", "", "", "C", ""],
  ["", "", "", "", "", "", "", "", ""],
  ["R", "H", "E", "A", "G", "A", "E", "H", "R"]
]
assert_equal(expected, result)

puts "✅ All PiecePlacement tests passed."
