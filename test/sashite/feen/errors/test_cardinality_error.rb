#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/errors/cardinality_error"

puts
puts "=== CardinalityError Tests ==="
puts

CardinalityError = Sashite::Feen::CardinalityError

EXPECTED_CONSTANTS = %i[
  TOO_MANY_PIECES
].freeze

# ============================================================================
# INHERITANCE
# ============================================================================

puts "inheritance:"

Test("inherits from ParseError, Error, and ArgumentError") do
  raise unless CardinalityError < Sashite::Feen::ParseError
  raise unless CardinalityError < Sashite::Feen::Error
  raise unless CardinalityError < ArgumentError
end

# ============================================================================
# CONSTANTS
# ============================================================================

puts
puts "constants:"

Test("all error message constants are defined strings") do
  EXPECTED_CONSTANTS.each do |const|
    raise "#{const} missing" unless CardinalityError.const_defined?(const)
    raise "#{const} not String" unless CardinalityError.const_get(const).is_a?(String)
  end
end

# ============================================================================
# RAISING
# ============================================================================

puts
puts "raising:"

Test("raises with correct message for each constant") do
  EXPECTED_CONSTANTS.each do |const|
    msg = CardinalityError.const_get(const)
    begin
      raise CardinalityError, msg
    rescue CardinalityError => e
      raise "wrong message for #{const}" unless e.message == msg
    end
  end
end

Test("rescuable as all ancestor types") do
  begin; raise CardinalityError, "test"; rescue Sashite::Feen::ParseError; end
  begin; raise CardinalityError, "test"; rescue Sashite::Feen::Error; end
  begin; raise CardinalityError, "test"; rescue ArgumentError; end
end

# ============================================================================
# IMMUTABILITY
# ============================================================================

puts
puts "immutability:"

Test("class is frozen") do
  raise unless CardinalityError.frozen?
end

puts
puts "All CardinalityError tests passed!"
puts
