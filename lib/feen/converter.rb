# frozen_string_literal: true

require_relative File.join("converter", "from_fen")
require_relative File.join("converter", "to_fen")

module Feen
  module Converter
    def self.from_fen(...)
      FromFen.call(...)
    end

    def self.to_fen(...)
      ToFen.call(...)
    end
  end
end
