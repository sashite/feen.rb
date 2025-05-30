# frozen_string_literal: true

# Tests for Feen::Parser::GamesTurn conforming to FEEN Specification v1.0.0
#
# FEEN specifies that games turn must be parsed from format:
# - Two game identifiers separated by "/"
# - First identifier represents the active player (to move)
# - Second identifier represents the inactive player (opponent)
# - One identifier must be uppercase, the other lowercase
# - Both identifiers must contain only alphabetic characters (a-z, A-Z)
# - Returns array [active_player, inactive_player]
#
# This test assumes the existence of the following files:
# - lib/feen/parser/games_turn.rb

require_relative "../../../lib/feen/parser/games_turn"

# Helper function to run a test and report errors
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
puts "Tests for Feen::Parser::GamesTurn"
puts

# Valid cases - uppercase first
run_test("Valid uppercase first, lowercase second") do
  result = Feen::Parser::GamesTurn.parse("CHESS/chess")
  expected = %w[CHESS chess]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Valid uppercase first with different games") do
  result = Feen::Parser::GamesTurn.parse("MAKRUK/xiangqi")
  expected = %w[MAKRUK xiangqi]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Valid single letter identifiers (uppercase first)") do
  result = Feen::Parser::GamesTurn.parse("A/b")
  expected = %w[A b]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Valid long identifiers (uppercase first)") do
  result = Feen::Parser::GamesTurn.parse("VERYLONGGAMENAME/anotherlonggame")
  expected = %w[VERYLONGGAMENAME anotherlonggame]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

# Valid cases - lowercase first
run_test("Valid lowercase first, uppercase second") do
  result = Feen::Parser::GamesTurn.parse("shogi/SHOGI")
  expected = %w[shogi SHOGI]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Valid lowercase first with different games") do
  result = Feen::Parser::GamesTurn.parse("chess/MAKRUK")
  expected = %w[chess MAKRUK]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Valid single letter identifiers (lowercase first)") do
  result = Feen::Parser::GamesTurn.parse("a/B")
  expected = %w[a B]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Valid long identifiers (lowercase first)") do
  result = Feen::Parser::GamesTurn.parse("verylonggamename/ANOTHERLONGGAME")
  expected = %w[verylonggamename ANOTHERLONGGAME]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

# Cross-game scenarios
run_test("Cross-game with hybrid names") do
  result = Feen::Parser::GamesTurn.parse("FOO/bar")
  expected = %w[FOO bar]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Cross-game reverse order") do
  result = Feen::Parser::GamesTurn.parse("ogi/CHESS")
  expected = %w[ogi CHESS]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

# All possible alphabetic characters
run_test("All uppercase vs all lowercase") do
  result = Feen::Parser::GamesTurn.parse("ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz")
  expected = %w[ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

# Error cases - invalid input types
run_test("Raises error for non-string input") do
  Feen::Parser::GamesTurn.parse(123)
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Games turn must be a string")
end

run_test("Raises error for nil input") do
  Feen::Parser::GamesTurn.parse(nil)
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Games turn must be a string")
end

run_test("Raises error for array input") do
  Feen::Parser::GamesTurn.parse(%w[CHESS chess])
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Games turn must be a string")
end

# Error cases - empty string
run_test("Raises error for empty string") do
  Feen::Parser::GamesTurn.parse("")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Games turn string cannot be empty")
end

# Error cases - invalid format
run_test("Raises error for missing separator") do
  Feen::Parser::GamesTurn.parse("CHESSchess")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid games turn format")
end

run_test("Raises error for multiple separators") do
  Feen::Parser::GamesTurn.parse("CHESS/chess/extra")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid games turn format")
end

run_test("Raises error for empty first identifier") do
  Feen::Parser::GamesTurn.parse("/chess")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid games turn format")
end

run_test("Raises error for empty second identifier") do
  Feen::Parser::GamesTurn.parse("CHESS/")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid games turn format")
end

run_test("Raises error for only separator") do
  Feen::Parser::GamesTurn.parse("/")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid games turn format")
end

# Error cases - invalid characters
run_test("Raises error for numbers in first identifier") do
  Feen::Parser::GamesTurn.parse("CHESS123/chess")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid games turn format")
end

run_test("Raises error for numbers in second identifier") do
  Feen::Parser::GamesTurn.parse("CHESS/chess123")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid games turn format")
end

run_test("Raises error for special characters in first identifier") do
  Feen::Parser::GamesTurn.parse("CHE-SS/chess")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid games turn format")
end

run_test("Raises error for special characters in second identifier") do
  Feen::Parser::GamesTurn.parse("CHESS/che@ss")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid games turn format")
end

run_test("Raises error for spaces in first identifier") do
  Feen::Parser::GamesTurn.parse("CHE SS/chess")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid games turn format")
end

run_test("Raises error for spaces in second identifier") do
  Feen::Parser::GamesTurn.parse("CHESS/che ss")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid games turn format")
end

# Error cases - mixed case within identifier
run_test("Raises error for mixed case in first identifier") do
  Feen::Parser::GamesTurn.parse("ChEsS/chess")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid games turn format")
end

run_test("Raises error for mixed case in second identifier") do
  Feen::Parser::GamesTurn.parse("CHESS/ChEsS")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid games turn format")
end

run_test("Raises error for mixed case in both identifiers") do
  Feen::Parser::GamesTurn.parse("ChEsS/ShOgI")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid games turn format")
end

# Error cases - same casing
run_test("Raises error for both uppercase identifiers") do
  Feen::Parser::GamesTurn.parse("CHESS/SHOGI")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid games turn format")
end

run_test("Raises error for both lowercase identifiers") do
  Feen::Parser::GamesTurn.parse("chess/shogi")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid games turn format")
end

# Error cases - extra whitespace
run_test("Raises error for leading whitespace") do
  Feen::Parser::GamesTurn.parse(" CHESS/chess")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid games turn format")
end

run_test("Raises error for trailing whitespace") do
  Feen::Parser::GamesTurn.parse("CHESS/chess ")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid games turn format")
end

run_test("Raises error for whitespace around separator") do
  Feen::Parser::GamesTurn.parse("CHESS / chess")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid games turn format")
end

# Edge cases with minimal valid input
run_test("Minimal valid input (single letters)") do
  result = Feen::Parser::GamesTurn.parse("X/y")
  expected = %w[X y]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Minimal valid input (reverse order)") do
  result = Feen::Parser::GamesTurn.parse("z/Z")
  expected = %w[z Z]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

puts
puts "All tests passed! ✓"
