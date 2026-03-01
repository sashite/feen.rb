#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/errors/style_turn_error"

puts
puts "=== StyleTurnError Tests ==="
puts

StyleTurnError = Sashite::Feen::StyleTurnError

# ============================================================================
# INHERITANCE
# ============================================================================

puts "inheritance:"

Test("inherits from ParseError") do
  raise "wrong parent" unless StyleTurnError < Sashite::Feen::ParseError
end

Test("inherits from Sashite::Feen::Error") do
  raise "wrong ancestor" unless StyleTurnError < Sashite::Feen::Error
end

Test("inherits from ArgumentError") do
  raise "wrong ancestor" unless StyleTurnError < ArgumentError
end

# ============================================================================
# CONSTANTS
# ============================================================================

puts
puts "constants:"

expected_constants = %i[
  INVALID_DELIMITER
  INVALID_STYLE_TOKEN
  SAME_CASE
].freeze

expected_constants.each do |const|
  Test("#{const} is defined") do
    raise "missing constant" unless StyleTurnError.const_defined?(const)
  end

  Test("#{const} is a String") do
    raise "wrong type" unless StyleTurnError.const_get(const).is_a?(String)
  end
end

# ============================================================================
# RAISING
# ============================================================================

puts
puts "raising:"

Test("can be raised and rescued as StyleTurnError") do
  raise StyleTurnError, StyleTurnError::INVALID_DELIMITER
rescue StyleTurnError => e
  raise "wrong message" unless e.message == StyleTurnError::INVALID_DELIMITER
end

Test("can be rescued as ParseError") do
  raise StyleTurnError, "test"
rescue Sashite::Feen::ParseError
  # Expected
end

Test("can be rescued as Sashite::Feen::Error") do
  raise StyleTurnError, "test"
rescue Sashite::Feen::Error
  # Expected
end

Test("can be rescued as ArgumentError") do
  raise StyleTurnError, "test"
rescue ArgumentError
  # Expected
end

# ============================================================================
# IMMUTABILITY
# ============================================================================

puts
puts "immutability:"

Test("class is frozen") do
  raise "expected frozen" unless StyleTurnError.frozen?
end

puts
puts "All StyleTurnError tests passed!"
puts
