#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/errors/hands_error"

puts
puts "=== HandsError Tests ==="
puts

HandsError = Sashite::Feen::HandsError unless defined?(HandsError)

# ============================================================================
# INHERITANCE
# ============================================================================

puts "inheritance:"

Test("inherits from ParseError") do
  raise "wrong parent" unless HandsError < Sashite::Feen::ParseError
end

Test("inherits from Sashite::Feen::Error") do
  raise "wrong ancestor" unless HandsError < Sashite::Feen::Error
end

Test("inherits from ArgumentError") do
  raise "wrong ancestor" unless HandsError < ArgumentError
end

# ============================================================================
# CONSTANTS
# ============================================================================

puts
puts "constants:"

expected_constants = %i[
  INVALID_DELIMITER
  INVALID_COUNT
  INVALID_PIECE_TOKEN
  NOT_AGGREGATED
  NOT_CANONICAL
].freeze

expected_constants.each do |const|
  Test("#{const} is defined") do
    raise "missing constant" unless HandsError.const_defined?(const)
  end

  Test("#{const} is a String") do
    raise "wrong type" unless HandsError.const_get(const).is_a?(String)
  end
end

# ============================================================================
# RAISING
# ============================================================================

puts
puts "raising:"

Test("can be raised and rescued as HandsError") do
  raise HandsError, HandsError::INVALID_DELIMITER
rescue HandsError => e
  raise "wrong message" unless e.message == HandsError::INVALID_DELIMITER
end

Test("can be rescued as ParseError") do
  raise HandsError, "test"
rescue Sashite::Feen::ParseError
  # Expected
end

Test("can be rescued as Sashite::Feen::Error") do
  raise HandsError, "test"
rescue Sashite::Feen::Error
  # Expected
end

Test("can be rescued as ArgumentError") do
  raise HandsError, "test"
rescue ArgumentError
  # Expected
end

# ============================================================================
# IMMUTABILITY
# ============================================================================

puts
puts "immutability:"

Test("class is frozen") do
  raise "expected frozen" unless HandsError.frozen?
end

puts
puts "All HandsError tests passed!"
puts
