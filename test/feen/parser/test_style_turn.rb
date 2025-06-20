# frozen_string_literal: true

# Tests for Feen::Parser::StyleTurn conforming to FEEN Specification v1.0.0
#
# FEEN specifies that style turn must be parsed from format:
# - Two style identifiers separated by "/"
# - First identifier represents the active player (to move)
# - Second identifier represents the inactive player (opponent)
# - One identifier must be uppercase, the other lowercase
# - Both identifiers must follow SNN specification (letters + digits, starting with letter)
# - Returns array [active_style, inactive_style]
#
# This test assumes the existence of the following files:
# - lib/feen/parser/style_turn.rb

require_relative "../../../lib/feen/parser/style_turn"

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
puts "Tests for Feen::Parser::StyleTurn"
puts

# Valid cases - uppercase first
run_test("Valid uppercase first, lowercase second") do
  result = Feen::Parser::StyleTurn.parse("CHESS/chess")
  expected = %w[CHESS chess]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Valid uppercase first with different styles") do
  result = Feen::Parser::StyleTurn.parse("MAKRUK/xiangqi")
  expected = %w[MAKRUK xiangqi]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Valid single letter identifiers (uppercase first)") do
  result = Feen::Parser::StyleTurn.parse("A/b")
  expected = %w[A b]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Valid long identifiers (uppercase first)") do
  result = Feen::Parser::StyleTurn.parse("VERYLONGSTYLENAME/anotherlongstyle")
  expected = %w[VERYLONGSTYLENAME anotherlongstyle]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

# Valid cases - lowercase first
run_test("Valid lowercase first, uppercase second") do
  result = Feen::Parser::StyleTurn.parse("shogi/SHOGI")
  expected = %w[shogi SHOGI]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Valid lowercase first with different styles") do
  result = Feen::Parser::StyleTurn.parse("chess/MAKRUK")
  expected = %w[chess MAKRUK]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Valid single letter identifiers (lowercase first)") do
  result = Feen::Parser::StyleTurn.parse("a/B")
  expected = %w[a B]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Valid long identifiers (lowercase first)") do
  result = Feen::Parser::StyleTurn.parse("verylongstylename/ANOTHERLONGSTYLE")
  expected = %w[verylongstylename ANOTHERLONGSTYLE]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

# Valid cases - SNN v1.0.0 with numeric identifiers
run_test("Valid numeric identifiers (SNN v1.0.0)") do
  result = Feen::Parser::StyleTurn.parse("CHESS960/makruk")
  expected = %w[CHESS960 makruk]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Valid complex numeric identifiers") do
  result = Feen::Parser::StyleTurn.parse("SHOGI9/chess960")
  expected = %w[SHOGI9 chess960]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Valid identifiers starting with letter then numbers") do
  result = Feen::Parser::StyleTurn.parse("GAME123/variant456")
  expected = %w[GAME123 variant456]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Valid mixed alphanumeric") do
  result = Feen::Parser::StyleTurn.parse("CHESS2D3D/shogi9x9")
  expected = %w[CHESS2D3D shogi9x9]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

# Cross-style scenarios
run_test("Cross-style with hybrid names") do
  result = Feen::Parser::StyleTurn.parse("FOO/bar")
  expected = %w[FOO bar]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Cross-style reverse order") do
  result = Feen::Parser::StyleTurn.parse("ogi/CHESS")
  expected = %w[ogi CHESS]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

# All possible alphabetic characters
run_test("All uppercase vs all lowercase") do
  result = Feen::Parser::StyleTurn.parse("ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz")
  expected = %w[ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

# Error cases - invalid input types
run_test("Raises error for non-string input") do
  Feen::Parser::StyleTurn.parse(123)
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Style turn must be a string")
end

run_test("Raises error for nil input") do
  Feen::Parser::StyleTurn.parse(nil)
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Style turn must be a string")
end

run_test("Raises error for array input") do
  Feen::Parser::StyleTurn.parse(%w[CHESS chess])
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Style turn must be a string")
end

# Error cases - empty string
run_test("Raises error for empty string") do
  Feen::Parser::StyleTurn.parse("")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Style turn string cannot be empty")
end

# Error cases - invalid format
run_test("Raises error for missing separator") do
  Feen::Parser::StyleTurn.parse("CHESSchess")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid style turn format")
end

run_test("Raises error for multiple separators") do
  Feen::Parser::StyleTurn.parse("CHESS/chess/extra")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid style turn format")
end

run_test("Raises error for empty first identifier") do
  Feen::Parser::StyleTurn.parse("/chess")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid style turn format")
end

run_test("Raises error for empty second identifier") do
  Feen::Parser::StyleTurn.parse("CHESS/")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid style turn format")
end

run_test("Raises error for only separator") do
  Feen::Parser::StyleTurn.parse("/")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid style turn format")
end

# Error cases - invalid SNN format
run_test("Raises error for starting with number") do
  Feen::Parser::StyleTurn.parse("123CHESS/chess")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid style turn format")
end

run_test("Raises error for special characters") do
  Feen::Parser::StyleTurn.parse("CHE-SS/chess")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  unless e.message.eql?("Invalid style turn format. Expected format: UPPERCASE/lowercase or lowercase/UPPERCASE")
    raise "Wrong error message: #{e.message}"
  end
end

run_test("Raises error for special characters in second identifier") do
  Feen::Parser::StyleTurn.parse("CHESS/che@ss")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  unless e.message.eql?("Invalid style turn format. Expected format: UPPERCASE/lowercase or lowercase/UPPERCASE")
    raise "Wrong error message: #{e.message}"
  end
end

run_test("Raises error for spaces in first identifier") do
  Feen::Parser::StyleTurn.parse("CHE SS/chess")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid style turn format")
end

run_test("Raises error for spaces in second identifier") do
  Feen::Parser::StyleTurn.parse("CHESS/che ss")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid style turn format")
end

# Error cases - mixed case within identifier (should be caught by SNN validation)
run_test("Raises error for mixed case in first identifier") do
  Feen::Parser::StyleTurn.parse("ChEsS/chess")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  unless e.message.eql?("Invalid style turn format. Expected format: UPPERCASE/lowercase or lowercase/UPPERCASE")
    raise "Wrong error message: #{e.message}"
  end
end

run_test("Raises error for mixed case in second identifier") do
  Feen::Parser::StyleTurn.parse("CHESS/ChEsS")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  unless e.message.eql?("Invalid style turn format. Expected format: UPPERCASE/lowercase or lowercase/UPPERCASE")
    raise "Wrong error message: #{e.message}"
  end
end

run_test("Raises error for mixed case in both identifiers") do
  Feen::Parser::StyleTurn.parse("ChEsS/ShOgI")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  unless e.message.eql?("Invalid style turn format. Expected format: UPPERCASE/lowercase or lowercase/UPPERCASE")
    raise "Wrong error message: #{e.message}"
  end
end

# Error cases - same casing
run_test("Raises error for both uppercase identifiers") do
  Feen::Parser::StyleTurn.parse("CHESS/SHOGI")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid style turn format")
end

run_test("Raises error for both lowercase identifiers") do
  Feen::Parser::StyleTurn.parse("chess/shogi")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid style turn format")
end

# Error cases - extra whitespace
run_test("Raises error for leading whitespace") do
  Feen::Parser::StyleTurn.parse(" CHESS/chess")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid style turn format")
end

run_test("Raises error for trailing whitespace") do
  Feen::Parser::StyleTurn.parse("CHESS/chess ")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid style turn format")
end

run_test("Raises error for whitespace around separator") do
  Feen::Parser::StyleTurn.parse("CHESS / chess")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid style turn format")
end

# Edge cases with minimal valid input
run_test("Minimal valid input (single letters)") do
  result = Feen::Parser::StyleTurn.parse("X/y")
  expected = %w[X y]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Minimal valid input (reverse order)") do
  result = Feen::Parser::StyleTurn.parse("z/Z")
  expected = %w[z Z]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

puts
puts "All tests passed! ✓"
