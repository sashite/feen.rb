# frozen_string_literal: true

# Tests for Feen::Dumper::StyleTurn conforming to FEEN Specification v1.0.0
#
# FEEN specifies that style turn must be formatted as:
# - Two style identifiers separated by "/"
# - First identifier represents the active player (to move)
# - Second identifier represents the inactive player (opponent)
# - One identifier must be uppercase, the other lowercase
# - Both identifiers must follow SNN specification (letters + digits, starting with letter)
# - Neither identifier can be empty
#
# This test assumes the existence of the following files:
# - lib/feen/dumper/style_turn.rb

require_relative "../../../lib/feen/dumper/style_turn"

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
puts "Tests for Feen::Dumper::StyleTurn"
puts

# Valid cases
run_test("Valid uppercase first, lowercase second") do
  result = Feen::Dumper::StyleTurn.dump("CHESS", "chess")
  raise "Expected 'CHESS/chess', got '#{result}'" unless result == "CHESS/chess"
end

run_test("Valid lowercase first, uppercase second") do
  result = Feen::Dumper::StyleTurn.dump("shogi", "SHOGI")
  raise "Expected 'shogi/SHOGI', got '#{result}'" unless result == "shogi/SHOGI"
end

run_test("Valid different style variants") do
  result = Feen::Dumper::StyleTurn.dump("MAKRUK", "xiangqi")
  raise "Expected 'MAKRUK/xiangqi', got '#{result}'" unless result == "MAKRUK/xiangqi"
end

run_test("Valid single letter identifiers") do
  result = Feen::Dumper::StyleTurn.dump("A", "b")
  raise "Expected 'A/b', got '#{result}'" unless result == "A/b"
end

run_test("Valid long identifiers") do
  result = Feen::Dumper::StyleTurn.dump("VERYLONGSTYLENAME", "anotherlongstyle")
  unless result == "VERYLONGSTYLENAME/anotherlongstyle"
    raise "Expected 'VERYLONGSTYLENAME/anotherlongstyle', got '#{result}'"
  end
end

# Valid cases with SNN v1.0.0 numeric identifiers
run_test("Valid numeric identifiers (SNN v1.0.0)") do
  result = Feen::Dumper::StyleTurn.dump("CHESS960", "makruk")
  raise "Expected 'CHESS960/makruk', got '#{result}'" unless result == "CHESS960/makruk"
end

run_test("Valid complex numeric identifiers") do
  result = Feen::Dumper::StyleTurn.dump("SHOGI9", "chess960")
  raise "Expected 'SHOGI9/chess960', got '#{result}'" unless result == "SHOGI9/chess960"
end

run_test("Valid mixed alphanumeric identifiers") do
  result = Feen::Dumper::StyleTurn.dump("GAME123", "variant456")
  raise "Expected 'GAME123/variant456', got '#{result}'" unless result == "GAME123/variant456"
end

run_test("Valid complex SNN identifiers") do
  result = Feen::Dumper::StyleTurn.dump("CHESS2D3D", "minishogi")
  raise "Expected 'CHESS2D3D/minishogi', got '#{result}'" unless result == "CHESS2D3D/minishogi"
end

# Invalid type cases
run_test("Raises error for non-string active style") do
  Feen::Dumper::StyleTurn.dump(123, "chess")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Active style must be a String")
end

run_test("Raises error for non-string inactive style") do
  Feen::Dumper::StyleTurn.dump("CHESS", 456)
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Inactive style must be a String")
end

run_test("Raises error for nil active style") do
  Feen::Dumper::StyleTurn.dump(nil, "chess")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Active style must be a String")
end

# Empty string cases
run_test("Raises error for empty active style") do
  Feen::Dumper::StyleTurn.dump("", "chess")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Active style cannot be empty")
end

run_test("Raises error for empty inactive style") do
  Feen::Dumper::StyleTurn.dump("CHESS", "")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Inactive style cannot be empty")
end

# Invalid SNN format cases
run_test("Raises error for active style starting with number") do
  Feen::Dumper::StyleTurn.dump("123CHESS", "chess")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Active style must be valid SNN notation")
end

run_test("Raises error for inactive style with special characters") do
  Feen::Dumper::StyleTurn.dump("CHESS", "che-ss")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Inactive style must be valid SNN notation")
end

run_test("Raises error for active style with spaces") do
  Feen::Dumper::StyleTurn.dump("CHE SS", "chess")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Active style must be valid SNN notation")
end

run_test("Raises error for inactive style with invalid characters") do
  Feen::Dumper::StyleTurn.dump("CHESS", "che@ss")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Inactive style must be valid SNN notation")
end

run_test("Raises error for mixed case active style") do
  Feen::Dumper::StyleTurn.dump("ChEsS", "chess")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Active style must be valid SNN notation")
end

run_test("Raises error for mixed case inactive style") do
  Feen::Dumper::StyleTurn.dump("CHESS", "ChEsS")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Inactive style must be valid SNN notation")
end

# Same casing validation
run_test("Raises error for both uppercase styles") do
  Feen::Dumper::StyleTurn.dump("CHESS", "MAKRUK")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  unless e.message.include?("One style must be uppercase and the other lowercase")
    raise "Wrong error message: #{e.message}"
  end
end

run_test("Raises error for both lowercase styles") do
  Feen::Dumper::StyleTurn.dump("chess", "shogi")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  unless e.message.include?("One style must be uppercase and the other lowercase")
    raise "Wrong error message: #{e.message}"
  end
end

# Edge cases
run_test("Handles minimal valid input") do
  result = Feen::Dumper::StyleTurn.dump("A", "b")
  raise "Expected 'A/b', got '#{result}'" unless result == "A/b"
end

run_test("Handles reverse minimal input") do
  result = Feen::Dumper::StyleTurn.dump("z", "Z")
  raise "Expected 'z/Z', got '#{result}'" unless result == "z/Z"
end

puts
puts "All tests passed! ✓"
