# frozen_string_literal: true

# Tests for Feen::Dumper::GamesTurn conforming to FEEN Specification v1.0.0
#
# FEEN specifies that games turn must be formatted as:
# - Two game identifiers separated by "/"
# - First identifier represents the active player (to move)
# - Second identifier represents the inactive player (opponent)
# - One identifier must be uppercase, the other lowercase
# - Both identifiers must contain only alphabetic characters (a-z, A-Z)
# - Neither identifier can be empty
#
# This test assumes the existence of the following files:
# - lib/feen/dumper/games_turn.rb

require_relative "../../../lib/feen/dumper/games_turn"

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
puts "Tests for Feen::Dumper::GamesTurn"
puts

# Valid cases
run_test("Valid uppercase first, lowercase second") do
  result = Feen::Dumper::GamesTurn.dump("CHESS", "chess")
  raise "Expected 'CHESS/chess', got '#{result}'" unless result == "CHESS/chess"
end

run_test("Valid lowercase first, uppercase second") do
  result = Feen::Dumper::GamesTurn.dump("shogi", "SHOGI")
  raise "Expected 'shogi/SHOGI', got '#{result}'" unless result == "shogi/SHOGI"
end

run_test("Valid different game variants") do
  result = Feen::Dumper::GamesTurn.dump("MAKRUK", "xiongqi")
  raise "Expected 'MAKRUK/xiongqi', got '#{result}'" unless result == "MAKRUK/xiongqi"
end

run_test("Valid single letter identifiers") do
  result = Feen::Dumper::GamesTurn.dump("A", "b")
  raise "Expected 'A/b', got '#{result}'" unless result == "A/b"
end

run_test("Valid long identifiers") do
  result = Feen::Dumper::GamesTurn.dump("VERYLONGGAMENAME", "anotherlonggame")
  unless result == "VERYLONGGAMENAME/anotherlonggame"
    raise "Expected 'VERYLONGGAMENAME/anotherlonggame', got '#{result}'"
  end
end

# Invalid type cases
run_test("Raises error for non-string active variant") do
  Feen::Dumper::GamesTurn.dump(123, "chess")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Active variant must be a String")
end

run_test("Raises error for non-string inactive variant") do
  Feen::Dumper::GamesTurn.dump("CHESS", 456)
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Inactive variant must be a String")
end

run_test("Raises error for nil active variant") do
  Feen::Dumper::GamesTurn.dump(nil, "chess")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Active variant must be a String")
end

# Empty string cases
run_test("Raises error for empty active variant") do
  Feen::Dumper::GamesTurn.dump("", "chess")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Active variant cannot be empty")
end

run_test("Raises error for empty inactive variant") do
  Feen::Dumper::GamesTurn.dump("CHESS", "")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Inactive variant cannot be empty")
end

# Invalid character cases
run_test("Raises error for active variant with numbers") do
  Feen::Dumper::GamesTurn.dump("CHESS123", "chess")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  unless e.message.include?("Active variant must contain only alphabetic characters")
    raise "Wrong error message: #{e.message}"
  end
end

run_test("Raises error for inactive variant with special characters") do
  Feen::Dumper::GamesTurn.dump("CHESS", "che-ss")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  unless e.message.include?("Inactive variant must contain only alphabetic characters")
    raise "Wrong error message: #{e.message}"
  end
end

run_test("Raises error for active variant with spaces") do
  Feen::Dumper::GamesTurn.dump("CHE SS", "chess")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  unless e.message.include?("Active variant must contain only alphabetic characters")
    raise "Wrong error message: #{e.message}"
  end
end

# Mixed case validation
run_test("Raises error for mixed case active variant") do
  Feen::Dumper::GamesTurn.dump("ChEsS", "chess")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Active variant has mixed case")
end

run_test("Raises error for mixed case inactive variant") do
  Feen::Dumper::GamesTurn.dump("CHESS", "ChEsS")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Inactive variant has mixed case")
end

# Same casing validation
run_test("Raises error for both uppercase variants") do
  Feen::Dumper::GamesTurn.dump("CHESS", "MAKRUK")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  unless e.message.include?("One variant must be uppercase and the other lowercase")
    raise "Wrong error message: #{e.message}"
  end
end

run_test("Raises error for both lowercase variants") do
  Feen::Dumper::GamesTurn.dump("chess", "ogi")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  unless e.message.include?("One variant must be uppercase and the other lowercase")
    raise "Wrong error message: #{e.message}"
  end
end

puts
puts "All tests passed! ✓"
