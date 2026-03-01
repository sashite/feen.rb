#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/errors/parse_error"

puts
puts "=== ParseError Tests ==="
puts

ParseError = Sashite::Feen::ParseError

# ============================================================================
# INHERITANCE
# ============================================================================

puts "inheritance:"

Test("inherits from Error and ArgumentError") do
  raise unless ParseError < Sashite::Feen::Error
  raise unless ParseError < ArgumentError
end

# ============================================================================
# CONSTANTS
# ============================================================================

puts
puts "constants:"

Test("error message constants are defined strings") do
  raise unless ParseError::INPUT_TOO_LONG.is_a?(String)
  raise unless ParseError::INVALID_FIELD_COUNT.is_a?(String)
end

# ============================================================================
# RAISING
# ============================================================================

puts
puts "raising:"

Test("raises and rescues with correct messages") do
  [ParseError::INPUT_TOO_LONG, ParseError::INVALID_FIELD_COUNT].each do |msg|
    begin
      raise ParseError, msg
    rescue ParseError => e
      raise "wrong message" unless e.message == msg
    end
  end
end

Test("rescuable as ancestor types") do
  begin; raise ParseError, "test"; rescue Sashite::Feen::Error; end
  begin; raise ParseError, "test"; rescue ArgumentError; end
end

# ============================================================================
# IMMUTABILITY
# ============================================================================

puts
puts "immutability:"

Test("class is frozen") do
  raise unless ParseError.frozen?
end

puts
puts "All ParseError tests passed!"
puts
