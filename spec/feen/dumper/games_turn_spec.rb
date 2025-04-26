# frozen_string_literal: true

require_relative "../../spec_helper"
require_relative "../../../lib/feen/dumper/games_turn"

RSpec.describe Feen::Dumper::GamesTurn do
  describe ".dump" do
    context "with valid inputs" do
      it "formats CHESS/chess correctly" do
        expect(described_class.dump("CHESS", "chess")).to eq("CHESS/chess")
      end

      it "formats chess/CHESS correctly" do
        expect(described_class.dump("chess", "CHESS")).to eq("chess/CHESS")
      end

      it "formats OGI/ogi correctly" do
        expect(described_class.dump("OGI", "ogi")).to eq("OGI/ogi")
      end

      it "formats XIONGQI/xiongqi correctly" do
        expect(described_class.dump("XIONGQI", "xiongqi")).to eq("XIONGQI/xiongqi")
      end

      it "handles longer game identifiers" do
        expect(described_class.dump("INTERNATIONALDRAUGHT", "internationaldraught"))
          .to eq("INTERNATIONALDRAUGHT/internationaldraught")
      end

      it "handles short game identifiers" do
        expect(described_class.dump("GO", "go")).to eq("GO/go")
      end

      it "handles single-character game identifiers" do
        expect(described_class.dump("X", "x")).to eq("X/x")
      end
    end

    context "with invalid inputs" do
      context "with invalid types" do
        it "raises an error when active_variant is not a string" do
          expect do
            described_class.dump(123, "chess")
          end.to raise_exception(ArgumentError)
        end

        it "raises an error when inactive_variant is not a string" do
          expect do
            described_class.dump("CHESS", nil)
          end.to raise_exception(ArgumentError)
        end

        it "raises an error when both parameters are nil" do
          expect do
            described_class.dump(nil, nil)
          end.to raise_exception(ArgumentError)
        end
      end

      context "with empty strings" do
        it "raises an error when active_variant is empty" do
          expect do
            described_class.dump("", "chess")
          end.to raise_exception(ArgumentError)
        end

        it "raises an error when inactive_variant is empty" do
          expect do
            described_class.dump("CHESS", "")
          end.to raise_exception(ArgumentError)
        end
      end

      context "with casing violations" do
        it "raises an error when both variants are uppercase" do
          expect do
            described_class.dump("CHESS", "OGI")
          end.to raise_exception(ArgumentError)
        end

        it "raises an error when both variants are lowercase" do
          expect do
            described_class.dump("chess", "ogi")
          end.to raise_exception(ArgumentError)
        end

        it "raises an error when active_variant has mixed case" do
          expect do
            described_class.dump("ChEsS", "ogi")
          end.to raise_exception(ArgumentError)
        end

        it "raises an error when inactive_variant has mixed case" do
          expect do
            described_class.dump("CHESS", "oGi")
          end.to raise_exception(ArgumentError)
        end
      end

      context "with invalid characters" do
        it "raises an error when active_variant contains numbers" do
          expect do
            described_class.dump("CHESS123", "chess")
          end.to raise_exception(ArgumentError)
        end

        it "raises an error when inactive_variant contains special characters" do
          expect do
            described_class.dump("CHESS", "chess!")
          end.to raise_exception(ArgumentError)
        end

        it "raises an error when active_variant contains spaces" do
          expect do
            described_class.dump("CHESS GAME", "chess")
          end.to raise_exception(ArgumentError)
        end

        it "raises an error when inactive_variant contains underscores" do
          expect do
            described_class.dump("CHESS", "chess_game")
          end.to raise_exception(ArgumentError)
        end

        it "raises an error when active_variant contains non-ASCII characters" do
          expect do
            described_class.dump("ÉCHECS", "chess")
          end.to raise_exception(ArgumentError)
        end
      end

      context "with edge cases" do
        it "raises an error with exotic values" do
          expect do
            described_class.dump("CHESS\n", "chess")
          end.to raise_exception(ArgumentError)
        end
      end
    end
  end

  describe ".validate_variants" do
    it "returns true when validation passes" do
      # Utilise la méthode private_class_method pour accéder à la méthode privée pour les tests
      method = described_class.method(:validate_variants)
      expect(method.call("CHESS", "chess")).to eq(true)
    end
  end
end
