# frozen_string_literal: true

require_relative "../../../lib/feen/parser/games_turn"

# Test basic parsing with uppercase first
raise unless Feen::Parser::GamesTurn.parse("CHESS/shogi") == {
  active_player:            "CHESS",
  inactive_player:          "shogi",
  active_player_uppercase?: true
}

raise unless Feen::Parser::GamesTurn.parse("SHOGI/chess") == {
  active_player:            "SHOGI",
  inactive_player:          "chess",
  active_player_uppercase?: true
}

# Test parsing with lowercase first
raise unless Feen::Parser::GamesTurn.parse("ogi/CHESS") == {
  active_player:            "ogi",
  inactive_player:          "CHESS",
  active_player_uppercase?: false
}

raise unless Feen::Parser::GamesTurn.parse("makruk/GO") == {
  active_player:            "makruk",
  inactive_player:          "GO",
  active_player_uppercase?: false
}

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

puts "✅ All GamesTurn parse tests passed."
