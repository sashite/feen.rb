#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/errors/style_turn_error"

puts
puts "=== StyleTurnError Tests ==="
puts

# ============================================================================
# INHERITANCE
# ============================================================================

puts "Inheritance:"

run_test("inherits from Sashite::Feen::ParseError") do
  result = Sashite::Feen::StyleTurnError.superclass
  raise "expected ParseError, got #{result.inspect}" unless result == Sashite::Feen::ParseError
end

run_test("is a subclass of Sashite::Feen::Error") do
  result = Sashite::Feen::StyleTurnError < Sashite::Feen::Error
  raise "expected to be subclass of Error" unless result == true
end

run_test("is a subclass of ArgumentError") do
  result = Sashite::Feen::StyleTurnError < ::ArgumentError
  raise "expected to be subclass of ArgumentError" unless result == true
end

# ============================================================================
# ERROR MESSAGE CONSTANTS - DELIMITER ERRORS
# ============================================================================

puts
puts "Error message constants - Delimiter errors:"

run_test("INVALID_DELIMITER is defined") do
  result = Sashite::Feen::StyleTurnError::INVALID_DELIMITER
  raise "expected String" unless ::String === result
end

run_test("INVALID_DELIMITER has meaningful message") do
  result = Sashite::Feen::StyleTurnError::INVALID_DELIMITER
  raise "expected to mention style-turn or delimiter" unless result.include?("style") || result.include?("delimiter")
end

# ============================================================================
# ERROR MESSAGE CONSTANTS - TOKEN ERRORS
# ============================================================================

puts
puts "Error message constants - Token errors:"

run_test("INVALID_STYLE_TOKEN is defined") do
  result = Sashite::Feen::StyleTurnError::INVALID_STYLE_TOKEN
  raise "expected String" unless ::String === result
end

run_test("INVALID_STYLE_TOKEN has meaningful message") do
  result = Sashite::Feen::StyleTurnError::INVALID_STYLE_TOKEN
  raise "expected to mention style or token" unless result.include?("style") || result.include?("token")
end

# ============================================================================
# ERROR MESSAGE CONSTANTS - CASE ERRORS
# ============================================================================

puts
puts "Error message constants - Case errors:"

run_test("SAME_CASE is defined") do
  result = Sashite::Feen::StyleTurnError::SAME_CASE
  raise "expected String" unless ::String === result
end

run_test("SAME_CASE has meaningful message") do
  result = Sashite::Feen::StyleTurnError::SAME_CASE
  raise "expected to mention case or opposite" unless result.include?("case") || result.include?("opposite")
end

# ============================================================================
# RAISING AND CATCHING
# ============================================================================

puts
puts "Raising and catching:"

run_test("can be raised") do
  raised = false
  begin
    raise Sashite::Feen::StyleTurnError, "test"
  rescue Sashite::Feen::StyleTurnError
    raised = true
  end
  raise "expected error to be raised" unless raised
end

run_test("can be caught as StyleTurnError") do
  caught_class = nil
  begin
    raise Sashite::Feen::StyleTurnError, "test"
  rescue Sashite::Feen::StyleTurnError => e
    caught_class = e.class
  end
  raise "expected StyleTurnError" unless caught_class == Sashite::Feen::StyleTurnError
end

run_test("can be caught as ParseError") do
  caught = false
  begin
    raise Sashite::Feen::StyleTurnError, "test"
  rescue Sashite::Feen::ParseError
    caught = true
  end
  raise "expected to be caught as ParseError" unless caught
end

run_test("can be caught as Sashite::Feen::Error") do
  caught = false
  begin
    raise Sashite::Feen::StyleTurnError, "test"
  rescue Sashite::Feen::Error
    caught = true
  end
  raise "expected to be caught as Error" unless caught
end

run_test("can be caught as ArgumentError") do
  caught = false
  begin
    raise Sashite::Feen::StyleTurnError, "test"
  rescue ::ArgumentError
    caught = true
  end
  raise "expected to be caught as ArgumentError" unless caught
end

run_test("can be raised with constant message") do
  message = nil
  begin
    raise Sashite::Feen::StyleTurnError, Sashite::Feen::StyleTurnError::SAME_CASE
  rescue Sashite::Feen::StyleTurnError => e
    message = e.message
  end
  raise "message mismatch" unless message == Sashite::Feen::StyleTurnError::SAME_CASE
end

# ============================================================================
# TYPE CHECKING
# ============================================================================

puts
puts "Type checking:"

run_test("instance is a StyleTurnError") do
  error = Sashite::Feen::StyleTurnError.new("test")
  raise "expected StyleTurnError === error" unless Sashite::Feen::StyleTurnError === error
end

run_test("instance is a ParseError") do
  error = Sashite::Feen::StyleTurnError.new("test")
  raise "expected ParseError === error" unless Sashite::Feen::ParseError === error
end

run_test("instance is a Sashite::Feen::Error") do
  error = Sashite::Feen::StyleTurnError.new("test")
  raise "expected Error === error" unless Sashite::Feen::Error === error
end

# ============================================================================
# CONSTANTS ARE DISTINCT
# ============================================================================

puts
puts "Constants are distinct:"

run_test("all error messages are unique") do
  messages = [
    Sashite::Feen::StyleTurnError::INVALID_DELIMITER,
    Sashite::Feen::StyleTurnError::INVALID_STYLE_TOKEN,
    Sashite::Feen::StyleTurnError::SAME_CASE
  ]
  unique_messages = messages.uniq
  raise "expected unique messages, got duplicates" unless messages.length == unique_messages.length
end

puts
puts "All StyleTurnError tests passed!"
puts
