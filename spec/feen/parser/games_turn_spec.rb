# frozen_string_literal: true

require_relative "../../spec_helper"
require_relative "../../../lib/feen/parser/games_turn"

RSpec.describe Feen::Parser::GamesTurn do
  describe ".parse" do
    context "with valid inputs" do
      it "parses CHESS/chess correctly" do
        result = described_class.parse("CHESS/chess")

        expect(result).to eq({
                               active_player:        "CHESS",
                               inactive_player:      "chess",
                               uppercase_game:       "CHESS",
                               lowercase_game:       "chess",
                               active_player_casing: :uppercase
                             })
      end

      it "parses chess/CHESS correctly" do
        result = described_class.parse("chess/CHESS")

        expect(result).to eq({
                               active_player:        "chess",
                               inactive_player:      "CHESS",
                               uppercase_game:       "CHESS",
                               lowercase_game:       "chess",
                               active_player_casing: :lowercase
                             })
      end

      it "parses OGI/ogi correctly" do
        result = described_class.parse("OGI/ogi")

        expect(result).to eq({
                               active_player:        "OGI",
                               inactive_player:      "ogi",
                               uppercase_game:       "OGI",
                               lowercase_game:       "ogi",
                               active_player_casing: :uppercase
                             })
      end

      it "parses xiongqi/XIONGQI correctly" do
        result = described_class.parse("xiongqi/XIONGQI")

        expect(result).to eq({
                               active_player:        "xiongqi",
                               inactive_player:      "XIONGQI",
                               uppercase_game:       "XIONGQI",
                               lowercase_game:       "xiongqi",
                               active_player_casing: :lowercase
                             })
      end

      it "handles longer game identifiers" do
        result = described_class.parse("INTERNATIONALDRAUGHT/internationaldraught")

        expect(result).to eq({
                               active_player:        "INTERNATIONALDRAUGHT",
                               inactive_player:      "internationaldraught",
                               uppercase_game:       "INTERNATIONALDRAUGHT",
                               lowercase_game:       "internationaldraught",
                               active_player_casing: :uppercase
                             })
      end

      it "handles short game identifiers" do
        result = described_class.parse("go/GO")

        expect(result).to eq({
                               active_player:        "go",
                               inactive_player:      "GO",
                               uppercase_game:       "GO",
                               lowercase_game:       "go",
                               active_player_casing: :lowercase
                             })
      end

      it "handles single-character game identifiers" do
        result = described_class.parse("X/x")

        expect(result).to eq({
                               active_player:        "X",
                               inactive_player:      "x",
                               uppercase_game:       "X",
                               lowercase_game:       "x",
                               active_player_casing: :uppercase
                             })
      end
    end

    context "with invalid inputs" do
      context "with invalid structure" do
        it "raises an error when given a non-string input" do
          expect do
            described_class.parse(123)
          end.to raise_exception(ArgumentError)
        end

        it "raises an error when given nil" do
          expect do
            described_class.parse(nil)
          end.to raise_exception(ArgumentError)
        end

        it "raises an error with an empty string" do
          expect do
            described_class.parse("")
          end.to raise_exception(ArgumentError)
        end

        it "raises an error with missing separator" do
          expect do
            described_class.parse("CHESSchess")
          end.to raise_exception(ArgumentError)
        end

        it "raises an error with multiple separators" do
          expect do
            described_class.parse("CHESS/chess/extra")
          end.to raise_exception(ArgumentError)
        end
      end

      context "with invalid game identifiers" do
        it "raises an error when the active game identifier is empty" do
          expect do
            described_class.parse("/chess")
          end.to raise_exception(ArgumentError)
        end

        it "raises an error when the inactive game identifier is empty" do
          expect do
            described_class.parse("CHESS/")
          end.to raise_exception(NoMethodError)
        end

        it "raises an error when the active game identifier contains non-alphabetic characters" do
          expect do
            described_class.parse("CHESS123/chess")
          end.to raise_exception(ArgumentError)
        end

        it "raises an error when the inactive game identifier contains non-alphabetic characters" do
          expect do
            described_class.parse("CHESS/chess!")
          end.to raise_exception(ArgumentError)
        end

        it "raises an error when the active game identifier contains spaces" do
          expect do
            described_class.parse("CHESS GAME/chess")
          end.to raise_exception(ArgumentError)
        end

        it "raises an error when the inactive game identifier contains underscores" do
          expect do
            described_class.parse("CHESS/chess_game")
          end.to raise_exception(ArgumentError)
        end

        it "raises an error when the active game identifier contains non-ASCII characters" do
          expect do
            described_class.parse("ÉCHECS/chess")
          end.to raise_exception(ArgumentError)
        end
      end

      context "with casing violations" do
        it "raises an error when both games are uppercase" do
          expect do
            described_class.parse("CHESS/OGI")
          end.to raise_exception(ArgumentError)
        end

        it "raises an error when both games are lowercase" do
          expect do
            described_class.parse("chess/ogi")
          end.to raise_exception(ArgumentError)
        end

        it "raises an error when active game has mixed case" do
          expect do
            described_class.parse("ChEsS/ogi")
          end.to raise_exception(ArgumentError)
        end

        it "raises an error when inactive game has mixed case" do
          expect do
            described_class.parse("CHESS/oGi")
          end.to raise_exception(ArgumentError)
        end
      end

      context "with edge cases" do
        it "raises an error with exotic values" do
          expect do
            described_class.parse("CHESS\n/chess")
          end.to raise_exception(ArgumentError)
        end

        it "raises an error with leading/trailing whitespace" do
          expect do
            described_class.parse(" CHESS/chess ")
          end.to raise_exception(ArgumentError)
        end
      end
    end
  end

  describe ".validate_games_turn_string" do
    it "does not raise an error for valid input" do
      expect do
        described_class.validate_games_turn_string("CHESS/chess")
      end.not_to raise_exception(StandardError)
    end
  end

  describe ".contains_uppercase?" do
    it "returns true for strings with uppercase letters" do
      expect(described_class.contains_uppercase?("CHESS")).to be true
      expect(described_class.contains_uppercase?("Chess")).to be true
    end

    it "returns false for strings without uppercase letters" do
      expect(described_class.contains_uppercase?("chess")).to be false
      expect(described_class.contains_uppercase?("")).to be false
    end
  end

  describe ".contains_lowercase?" do
    it "returns true for strings with lowercase letters" do
      expect(described_class.contains_lowercase?("chess")).to be true
      expect(described_class.contains_lowercase?("Chess")).to be true
    end

    it "returns false for strings without lowercase letters" do
      expect(described_class.contains_lowercase?("CHESS")).to be false
      expect(described_class.contains_lowercase?("")).to be false
    end
  end
end
