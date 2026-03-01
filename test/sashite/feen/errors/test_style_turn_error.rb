#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/errors/style_turn_error"

puts
puts "=== StyleTurnError Tests ==="
puts

StyleTurnError = Sashite::Feen::StyleTurnError

EXPECTED_CONSTANTS = %i[
  INVALID_DELIMITER
  INVALID_STYLE_TOKEN
  SAME_CASE
].freeze

# ============================================================================
# INHERITANCE
# ============================================================================

puts "inheritance:"

Test("inherits from ParseError, Error, and ArgumentError") do
  raise unless StyleTurnError < Sashite::Feen::ParseError
  raise unless StyleTurnError < Sashite::Feen::Error
  raise unless StyleTurnError < ArgumentError
end

# ============================================================================
# CONSTANTS
# ============================================================================

puts
puts "constants:"

Test("all error message constants are defined strings") do
  EXPECTED_CONSTANTS.each do |const|
    raise "#{const} missing" unless StyleTurnError.const_defined?(const)
    raise "#{const} not String" unless StyleTurnError.const_get(const).is_a?(String)
  end
end

# ============================================================================
# RAISING
# ============================================================================

puts
puts "raising:"

Test("raises with correct message for each constant") do
  EXPECTED_CONSTANTS.each do |const|
    msg = StyleTurnError.const_get(const)
    begin
      raise StyleTurnError, msg
    rescue StyleTurnError => e
      raise "wrong message for #{const}" unless e.message == msg
    end
  end
end

Test("rescuable as all ancestor types") do
  begin; raise StyleTurnError, "test"; rescue Sashite::Feen::ParseError; end
  begin; raise StyleTurnError, "test"; rescue Sashite::Feen::Error; end
  begin; raise StyleTurnError, "test"; rescue ArgumentError; end
end

# ============================================================================
# IMMUTABILITY
# ============================================================================

puts
puts "immutability:"

Test("class is frozen") do
  raise unless StyleTurnError.frozen?
end

puts
puts "All StyleTurnError tests passed!"
puts
