#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/errors/hands_error"

puts
puts "=== HandsError Tests ==="
puts

HandsError = Sashite::Feen::HandsError

EXPECTED_CONSTANTS = %i[
  INVALID_DELIMITER
  INVALID_COUNT
  INVALID_PIECE_TOKEN
  NOT_AGGREGATED
  NOT_CANONICAL
].freeze

# ============================================================================
# INHERITANCE
# ============================================================================

puts "inheritance:"

Test("inherits from ParseError, Error, and ArgumentError") do
  raise unless HandsError < Sashite::Feen::ParseError
  raise unless HandsError < Sashite::Feen::Error
  raise unless HandsError < ArgumentError
end

# ============================================================================
# CONSTANTS
# ============================================================================

puts
puts "constants:"

Test("all error message constants are defined strings") do
  EXPECTED_CONSTANTS.each do |const|
    raise "#{const} missing" unless HandsError.const_defined?(const)
    raise "#{const} not String" unless HandsError.const_get(const).is_a?(String)
  end
end

# ============================================================================
# RAISING
# ============================================================================

puts
puts "raising:"

Test("raises with correct message for each constant") do
  EXPECTED_CONSTANTS.each do |const|
    msg = HandsError.const_get(const)
    begin
      raise HandsError, msg
    rescue HandsError => e
      raise "wrong message for #{const}" unless e.message == msg
    end
  end
end

Test("rescuable as all ancestor types") do
  begin; raise HandsError, "test"; rescue Sashite::Feen::ParseError; end
  begin; raise HandsError, "test"; rescue Sashite::Feen::Error; end
  begin; raise HandsError, "test"; rescue ArgumentError; end
end

# ============================================================================
# IMMUTABILITY
# ============================================================================

puts
puts "immutability:"

Test("class is frozen") do
  raise unless HandsError.frozen?
end

puts
puts "All HandsError tests passed!"
puts
