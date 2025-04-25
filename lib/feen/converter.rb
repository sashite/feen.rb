# frozen_string_literal: true

require_relative File.join("converter", "from_fen")
require_relative File.join("converter", "to_fen")

module Feen
  module Converter
    def self.from_fen(fen_string)
      FromFen.call(fen_string)
    end

    def self.to_fen(feen_string)
      ToFen.call(feen_string)
    end
  end
end
