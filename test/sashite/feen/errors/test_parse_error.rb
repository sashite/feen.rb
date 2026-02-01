#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/errors/parse_error"

puts
puts "=== ParseError Tests ==="
puts

# ============================================================================
# INHERITANCE
# ============================================================================

puts "Inheritance:"

run_test("inherits from Sashite::Feen::Error") do
  result = Sashite::Feen::ParseError.superclass
  raise "expected Sashite::Feen::Error, got #{result.inspect}" unless result == Sashite::Feen::Error
end

run_test("is a subclass of ArgumentError") do
  result = Sashite::Feen::ParseError < ::ArgumentError
  raise "expected to be subclass of ArgumentError" unless result == true
end

run_test("is a subclass of StandardError") do
  result = Sashite::Feen::ParseError < ::StandardError
  raise "expected to be subclass of StandardError" unless result == true
end

# ============================================================================
# ERROR MESSAGE CONSTANTS
# ============================================================================

puts
puts "Error message constants:"

run_test("INPUT_TOO_LONG is defined") do
  result = Sashite::Feen::ParseError::INPUT_TOO_LONG
  raise "expected String, got #{result.class}" unless ::String === result
end

run_test("INPUT_TOO_LONG has meaningful message") do
  result = Sashite::Feen::ParseError::INPUT_TOO_LONG
  raise "expected non-empty message" if result.empty?
  raise "expected to mention length" unless result.include?("length")
end

run_test("INVALID_FIELD_COUNT is defined") do
  result = Sashite::Feen::ParseError::INVALID_FIELD_COUNT
  raise "expected String, got #{result.class}" unless ::String === result
end

run_test("INVALID_FIELD_COUNT has meaningful message") do
  result = Sashite::Feen::ParseError::INVALID_FIELD_COUNT
  raise "expected non-empty message" if result.empty?
  raise "expected to mention field" unless result.include?("field")
end

# ============================================================================
# INSTANTIATION
# ============================================================================

puts
puts "Instantiation:"

run_test("can be instantiated without message") do
  error = Sashite::Feen::ParseError.new
  raise "expected ParseError instance" unless Sashite::Feen::ParseError === error
end

run_test("can be instantiated with message") do
  error = Sashite::Feen::ParseError.new("test message")
  raise "expected ParseError instance" unless Sashite::Feen::ParseError === error
end

run_test("can be instantiated with constant message") do
  error = Sashite::Feen::ParseError.new(Sashite::Feen::ParseError::INPUT_TOO_LONG)
  raise "message mismatch" unless error.message == Sashite::Feen::ParseError::INPUT_TOO_LONG
end

run_test("stores message correctly") do
  error = Sashite::Feen::ParseError.new("custom parse error")
  raise "expected 'custom parse error', got #{error.message.inspect}" unless error.message == "custom parse error"
end

# ============================================================================
# RAISING AND CATCHING
# ============================================================================

puts
puts "Raising and catching:"

run_test("can be raised") do
  raised = false
  begin
    raise Sashite::Feen::ParseError, "test"
  rescue Sashite::Feen::ParseError
    raised = true
  end
  raise "expected error to be raised" unless raised
end

run_test("can be caught as ParseError") do
  caught_class = nil
  begin
    raise Sashite::Feen::ParseError, "test"
  rescue Sashite::Feen::ParseError => e
    caught_class = e.class
  end
  raise "expected ParseError" unless caught_class == Sashite::Feen::ParseError
end

run_test("can be caught as Sashite::Feen::Error") do
  caught = false
  begin
    raise Sashite::Feen::ParseError, "test"
  rescue Sashite::Feen::Error
    caught = true
  end
  raise "expected to be caught as Sashite::Feen::Error" unless caught
end

run_test("can be caught as ArgumentError") do
  caught = false
  begin
    raise Sashite::Feen::ParseError, "test"
  rescue ::ArgumentError
    caught = true
  end
  raise "expected to be caught as ArgumentError" unless caught
end

run_test("can be raised with constant message") do
  message = nil
  begin
    raise Sashite::Feen::ParseError, Sashite::Feen::ParseError::INPUT_TOO_LONG
  rescue Sashite::Feen::ParseError => e
    message = e.message
  end
  raise "message mismatch" unless message == Sashite::Feen::ParseError::INPUT_TOO_LONG
end

# ============================================================================
# TYPE CHECKING
# ============================================================================

puts
puts "Type checking:"

run_test("instance is a ParseError") do
  error = Sashite::Feen::ParseError.new("test")
  raise "expected ParseError === error" unless Sashite::Feen::ParseError === error
end

run_test("instance is a Sashite::Feen::Error") do
  error = Sashite::Feen::ParseError.new("test")
  raise "expected Error === error" unless Sashite::Feen::Error === error
end

run_test("instance is an ArgumentError") do
  error = Sashite::Feen::ParseError.new("test")
  raise "expected ArgumentError === error" unless ::ArgumentError === error
end

# ============================================================================
# CONSTANTS ARE DISTINCT
# ============================================================================

puts
puts "Constants are distinct:"

run_test("error messages are unique") do
  messages = [
    Sashite::Feen::ParseError::INPUT_TOO_LONG,
    Sashite::Feen::ParseError::INVALID_FIELD_COUNT
  ]
  unique_messages = messages.uniq
  raise "expected unique messages" unless messages.length == unique_messages.length
end

puts
puts "All ParseError tests passed!"
puts
