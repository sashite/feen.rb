#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/errors/hands_error"

puts
puts "=== HandsError Tests ==="
puts

# ============================================================================
# INHERITANCE
# ============================================================================

puts "Inheritance:"

run_test("inherits from Sashite::Feen::ParseError") do
  result = Sashite::Feen::HandsError.superclass
  raise "expected ParseError, got #{result.inspect}" unless result == Sashite::Feen::ParseError
end

run_test("is a subclass of Sashite::Feen::Error") do
  result = Sashite::Feen::HandsError < Sashite::Feen::Error
  raise "expected to be subclass of Error" unless result == true
end

run_test("is a subclass of ArgumentError") do
  result = Sashite::Feen::HandsError < ::ArgumentError
  raise "expected to be subclass of ArgumentError" unless result == true
end

# ============================================================================
# ERROR MESSAGE CONSTANTS - DELIMITER ERRORS
# ============================================================================

puts
puts "Error message constants - Delimiter errors:"

run_test("INVALID_DELIMITER is defined") do
  result = Sashite::Feen::HandsError::INVALID_DELIMITER
  raise "expected String" unless ::String === result
end

run_test("INVALID_DELIMITER has meaningful message") do
  result = Sashite::Feen::HandsError::INVALID_DELIMITER
  raise "expected to mention hands or delimiter" unless result.include?("hands") || result.include?("delimiter")
end

# ============================================================================
# ERROR MESSAGE CONSTANTS - COUNT ERRORS
# ============================================================================

puts
puts "Error message constants - Count errors:"

run_test("INVALID_COUNT is defined") do
  result = Sashite::Feen::HandsError::INVALID_COUNT
  raise "expected String" unless ::String === result
end

run_test("INVALID_COUNT has meaningful message") do
  result = Sashite::Feen::HandsError::INVALID_COUNT
  raise "expected to mention hand or count" unless result.include?("hand") || result.include?("count")
end

# ============================================================================
# ERROR MESSAGE CONSTANTS - TOKEN ERRORS
# ============================================================================

puts
puts "Error message constants - Token errors:"

run_test("INVALID_PIECE_TOKEN is defined") do
  result = Sashite::Feen::HandsError::INVALID_PIECE_TOKEN
  raise "expected String" unless ::String === result
end

run_test("INVALID_PIECE_TOKEN has meaningful message") do
  result = Sashite::Feen::HandsError::INVALID_PIECE_TOKEN
  raise "expected to mention piece or token" unless result.include?("piece") || result.include?("token")
end

# ============================================================================
# ERROR MESSAGE CONSTANTS - CANONICALIZATION ERRORS
# ============================================================================

puts
puts "Error message constants - Canonicalization errors:"

run_test("NOT_AGGREGATED is defined") do
  result = Sashite::Feen::HandsError::NOT_AGGREGATED
  raise "expected String" unless ::String === result
end

run_test("NOT_AGGREGATED has meaningful message") do
  result = Sashite::Feen::HandsError::NOT_AGGREGATED
  raise "expected to mention aggregated" unless result.include?("aggregated")
end

run_test("NOT_CANONICAL is defined") do
  result = Sashite::Feen::HandsError::NOT_CANONICAL
  raise "expected String" unless ::String === result
end

run_test("NOT_CANONICAL has meaningful message") do
  result = Sashite::Feen::HandsError::NOT_CANONICAL
  raise "expected to mention canonical or order" unless result.include?("canonical") || result.include?("order")
end

# ============================================================================
# RAISING AND CATCHING
# ============================================================================

puts
puts "Raising and catching:"

run_test("can be raised") do
  raised = false
  begin
    raise Sashite::Feen::HandsError, "test"
  rescue Sashite::Feen::HandsError
    raised = true
  end
  raise "expected error to be raised" unless raised
end

run_test("can be caught as HandsError") do
  caught_class = nil
  begin
    raise Sashite::Feen::HandsError, "test"
  rescue Sashite::Feen::HandsError => e
    caught_class = e.class
  end
  raise "expected HandsError" unless caught_class == Sashite::Feen::HandsError
end

run_test("can be caught as ParseError") do
  caught = false
  begin
    raise Sashite::Feen::HandsError, "test"
  rescue Sashite::Feen::ParseError
    caught = true
  end
  raise "expected to be caught as ParseError" unless caught
end

run_test("can be caught as Sashite::Feen::Error") do
  caught = false
  begin
    raise Sashite::Feen::HandsError, "test"
  rescue Sashite::Feen::Error
    caught = true
  end
  raise "expected to be caught as Error" unless caught
end

run_test("can be caught as ArgumentError") do
  caught = false
  begin
    raise Sashite::Feen::HandsError, "test"
  rescue ::ArgumentError
    caught = true
  end
  raise "expected to be caught as ArgumentError" unless caught
end

run_test("can be raised with constant message") do
  message = nil
  begin
    raise Sashite::Feen::HandsError, Sashite::Feen::HandsError::INVALID_DELIMITER
  rescue Sashite::Feen::HandsError => e
    message = e.message
  end
  raise "message mismatch" unless message == Sashite::Feen::HandsError::INVALID_DELIMITER
end

# ============================================================================
# TYPE CHECKING
# ============================================================================

puts
puts "Type checking:"

run_test("instance is a HandsError") do
  error = Sashite::Feen::HandsError.new("test")
  raise "expected HandsError === error" unless Sashite::Feen::HandsError === error
end

run_test("instance is a ParseError") do
  error = Sashite::Feen::HandsError.new("test")
  raise "expected ParseError === error" unless Sashite::Feen::ParseError === error
end

run_test("instance is a Sashite::Feen::Error") do
  error = Sashite::Feen::HandsError.new("test")
  raise "expected Error === error" unless Sashite::Feen::Error === error
end

# ============================================================================
# CONSTANTS ARE DISTINCT
# ============================================================================

puts
puts "Constants are distinct:"

run_test("all error messages are unique") do
  messages = [
    Sashite::Feen::HandsError::INVALID_DELIMITER,
    Sashite::Feen::HandsError::INVALID_COUNT,
    Sashite::Feen::HandsError::INVALID_PIECE_TOKEN,
    Sashite::Feen::HandsError::NOT_AGGREGATED,
    Sashite::Feen::HandsError::NOT_CANONICAL
  ]
  unique_messages = messages.uniq
  raise "expected unique messages, got duplicates" unless messages.length == unique_messages.length
end

puts
puts "All HandsError tests passed!"
puts
