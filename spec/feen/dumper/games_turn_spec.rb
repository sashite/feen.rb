# frozen_string_literal: true

require_relative "../../spec_helper"
require_relative "../../../lib/feen/dumper/games_turn"

RSpec.describe Feen::Dumper::GamesTurn do
  describe ".dump" do
    context "with valid inputs" do
      it "formats CHESS/chess correctly" do
        games_turn = {
          active_player:   "CHESS",
          inactive_player: "chess"
        }

        expect(described_class.dump(games_turn)).to eq("CHESS/chess")
      end

      it "formats chess/CHESS correctly" do
        games_turn = {
          active_player:   "chess",
          inactive_player: "CHESS"
        }

        expect(described_class.dump(games_turn)).to eq("chess/CHESS")
      end

      it "formats OGI/ogi correctly" do
        games_turn = {
          active_player:   "OGI",
          inactive_player: "ogi"
        }

        expect(described_class.dump(games_turn)).to eq("OGI/ogi")
      end

      it "formats XIONGQI/xiongqi correctly" do
        games_turn = {
          active_player:   "XIONGQI",
          inactive_player: "xiongqi"
        }

        expect(described_class.dump(games_turn)).to eq("XIONGQI/xiongqi")
      end

      it "handles longer game identifiers" do
        games_turn = {
          active_player:   "INTERNATIONALDRAUGHT",
          inactive_player: "internationaldraught"
        }

        expect(described_class.dump(games_turn)).to eq("INTERNATIONALDRAUGHT/internationaldraught")
      end

      it "handles short game identifiers" do
        games_turn = {
          active_player:   "GO",
          inactive_player: "go"
        }

        expect(described_class.dump(games_turn)).to eq("GO/go")
      end

      it "handles single-character game identifiers" do
        games_turn = {
          active_player:   "X",
          inactive_player: "x"
        }

        expect(described_class.dump(games_turn)).to eq("X/x")
      end
    end

    context "with invalid inputs" do
      context "with missing keys" do
        it "raises an error when active_player is missing" do
          games_turn = {
            inactive_player: "chess"
          }

          expect do
            described_class.dump(games_turn)
          end.to raise_exception(ArgumentError)
        end

        it "raises an error when inactive_player is missing" do
          games_turn = {
            active_player: "CHESS"
          }

          expect do
            described_class.dump(games_turn)
          end.to raise_exception(ArgumentError)
        end

        it "raises an error when both keys are missing" do
          games_turn = {}

          expect do
            described_class.dump(games_turn)
          end.to raise_exception(ArgumentError)
        end
      end

      context "with invalid types" do
        it "raises an error when active_player is not a string" do
          games_turn = {
            active_player:   123,
            inactive_player: "chess"
          }

          expect do
            described_class.dump(games_turn)
          end.to raise_exception(ArgumentError)
        end

        it "raises an error when inactive_player is not a string" do
          games_turn = {
            active_player:   "CHESS",
            inactive_player: nil
          }

          expect do
            described_class.dump(games_turn)
          end.to raise_exception(ArgumentError)
        end

        it "raises an error when games_turn is not a hash" do
          expect do
            described_class.dump("CHESS/chess")
          end.to raise_exception(NoMethodError)
        end

        it "raises an error when games_turn is nil" do
          expect do
            described_class.dump(nil)
          end.to raise_exception(NoMethodError)
        end
      end

      context "with empty strings" do
        it "raises an error when active_player is empty" do
          games_turn = {
            active_player:   "",
            inactive_player: "chess"
          }

          expect do
            described_class.dump(games_turn)
          end.to raise_exception(ArgumentError)
        end

        it "raises an error when inactive_player is empty" do
          games_turn = {
            active_player:   "CHESS",
            inactive_player: ""
          }

          expect do
            described_class.dump(games_turn)
          end.to raise_exception(ArgumentError)
        end
      end

      context "with casing violations" do
        it "raises an error when both games are uppercase" do
          games_turn = {
            active_player:   "CHESS",
            inactive_player: "OGI"
          }

          expect do
            described_class.dump(games_turn)
          end.to raise_exception(ArgumentError)
        end

        it "raises an error when both games are lowercase" do
          games_turn = {
            active_player:   "chess",
            inactive_player: "ogi"
          }

          expect do
            described_class.dump(games_turn)
          end.to raise_exception(ArgumentError)
        end

        it "raises an error when active_player has mixed case" do
          games_turn = {
            active_player:   "ChEsS",
            inactive_player: "ogi"
          }

          expect do
            described_class.dump(games_turn)
          end.to raise_exception(ArgumentError)
        end

        it "raises an error when inactive_player has mixed case" do
          games_turn = {
            active_player:   "CHESS",
            inactive_player: "oGi"
          }

          expect do
            described_class.dump(games_turn)
          end.to raise_exception(ArgumentError)
        end
      end

      context "with invalid characters" do
        it "raises an error when active_player contains numbers" do
          games_turn = {
            active_player:   "CHESS123",
            inactive_player: "chess"
          }

          expect do
            described_class.dump(games_turn)
          end.to raise_exception(ArgumentError)
        end

        it "raises an error when inactive_player contains special characters" do
          games_turn = {
            active_player:   "CHESS",
            inactive_player: "chess!"
          }

          expect do
            described_class.dump(games_turn)
          end.to raise_exception(ArgumentError)
        end

        it "raises an error when active_player contains spaces" do
          games_turn = {
            active_player:   "CHESS GAME",
            inactive_player: "chess"
          }

          expect do
            described_class.dump(games_turn)
          end.to raise_exception(ArgumentError)
        end

        it "raises an error when inactive_player contains underscores" do
          games_turn = {
            active_player:   "CHESS",
            inactive_player: "chess_game"
          }

          expect do
            described_class.dump(games_turn)
          end.to raise_exception(ArgumentError)
        end

        it "raises an error when active_player contains non-ASCII characters" do
          games_turn = {
            active_player:   "ÉCHECS",
            inactive_player: "chess"
          }

          expect do
            described_class.dump(games_turn)
          end.to raise_exception(ArgumentError)
        end
      end

      context "with edge cases" do
        it "raises an error with exotic values" do
          games_turn = {
            active_player:   "CHESS\n",
            inactive_player: "chess"
          }

          expect do
            described_class.dump(games_turn)
          end.to raise_exception(ArgumentError)
        end

        it "raises an error with symbols as keys" do
          games_turn = {
            "active_player"   => "CHESS",
            "inactive_player" => "chess"
          }

          expect do
            described_class.dump(games_turn)
          end.to raise_exception(ArgumentError)
        end
      end
    end
  end

  describe ".validate_games_turn" do
    it "returns true when validation passes" do
      games_turn = {
        active_player:   "CHESS",
        inactive_player: "chess"
      }

      expect(described_class.validate_games_turn(games_turn)).to eq(true)
    end
  end
end
