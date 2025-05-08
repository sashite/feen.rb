# frozen_string_literal: true

require_relative "../../../lib/feen/parser/games_turn"

# Test basic parsing with uppercase first
raise unless Feen::Parser::GamesTurn.parse("CHESS/shogi") == ["CHESS", "shogi"]
raise unless Feen::Parser::GamesTurn.parse("SHOGI/chess") == ["SHOGI", "chess"]

# Test parsing with lowercase first
raise unless Feen::Parser::GamesTurn.parse("ogi/CHESS") == ["ogi", "CHESS"]
raise unless Feen::Parser::GamesTurn.parse("makruk/GO") == ["makruk", "GO"]

# Test with standard games
raise unless Feen::Parser::GamesTurn.parse("CHESS/chess") == ["CHESS", "chess"]
raise unless Feen::Parser::GamesTurn.parse("chess/CHESS") == ["chess", "CHESS"]
raise unless Feen::Parser::GamesTurn.parse("SHOGI/shogi") == ["SHOGI", "shogi"]
raise unless Feen::Parser::GamesTurn.parse("shogi/SHOGI") == ["shogi", "SHOGI"]

# Test invalid formats
begin
  Feen::Parser::GamesTurn.parse("CHESS/SHOGI")
  raise "Expected error for CHESS/SHOGI"
rescue ArgumentError => e
  raise unless e.message.include?("Invalid games turn format")
end

begin
  Feen::Parser::GamesTurn.parse("chess/shogi")
  raise "Expected error for chess/shogi"
rescue ArgumentError => e
  raise unless e.message.include?("Invalid games turn format")
end

begin
  Feen::Parser::GamesTurn.parse("CHESS/SHOGI/EXTRA")
  raise "Expected error for CHESS/SHOGI/EXTRA"
rescue ArgumentError => e
  raise unless e.message.include?("Invalid games turn format")
end

# Test invalid input types
begin
  Feen::Parser::GamesTurn.parse(nil)
  raise "Expected error for nil input"
rescue ArgumentError => e
  raise unless e.message.include?("Games turn must be a string")
end

begin
  Feen::Parser::GamesTurn.parse(42)
  raise "Expected error for numeric input"
rescue ArgumentError => e
  raise unless e.message.include?("Games turn must be a string")
end

begin
  Feen::Parser::GamesTurn.parse("")
  raise "Expected error for empty string"
rescue ArgumentError => e
  raise unless e.message.include?("Games turn string cannot be empty")
end

# Test invalid characters
begin
  Feen::Parser::GamesTurn.parse("CHESS1/shogi")
  raise "Expected error for CHESS1/shogi"
rescue ArgumentError => e
  raise unless e.message.include?("Invalid games turn format")
end

begin
  Feen::Parser::GamesTurn.parse("CHESS/shogi!")
  raise "Expected error for CHESS/shogi!"
rescue ArgumentError => e
  raise unless e.message.include?("Invalid games turn format")
end

# Test edge cases
raise unless Feen::Parser::GamesTurn.parse("A/a") == ["A", "a"]
raise unless Feen::Parser::GamesTurn.parse("z/Z") == ["z", "Z"]

puts "✅ All GamesTurn parse tests passed."
