#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/errors/cardinality_error"

puts
puts "=== CardinalityError Tests ==="
puts

# ============================================================================
# INHERITANCE
# ============================================================================

puts "Inheritance:"

run_test("inherits from Sashite::Feen::ParseError") do
  result = Sashite::Feen::CardinalityError.superclass
  raise "expected ParseError, got #{result.inspect}" unless result == Sashite::Feen::ParseError
end

run_test("is a subclass of Sashite::Feen::Error") do
  result = Sashite::Feen::CardinalityError < Sashite::Feen::Error
  raise "expected to be subclass of Error" unless result == true
end

run_test("is a subclass of ArgumentError") do
  result = Sashite::Feen::CardinalityError < ::ArgumentError
  raise "expected to be subclass of ArgumentError" unless result == true
end

# ============================================================================
# ERROR MESSAGE CONSTANTS
# ============================================================================

puts
puts "Error message constants:"

run_test("TOO_MANY_PIECES is defined") do
  result = Sashite::Feen::CardinalityError::TOO_MANY_PIECES
  raise "expected String" unless ::String === result
end

run_test("TOO_MANY_PIECES has meaningful message") do
  result = Sashite::Feen::CardinalityError::TOO_MANY_PIECES
  raise "expected to mention pieces or board" unless result.include?("pieces") || result.include?("board")
end

# ============================================================================
# RAISING AND CATCHING
# ============================================================================

puts
puts "Raising and catching:"

run_test("can be raised") do
  raised = false
  begin
    raise Sashite::Feen::CardinalityError, "test"
  rescue Sashite::Feen::CardinalityError
    raised = true
  end
  raise "expected error to be raised" unless raised
end

run_test("can be caught as CardinalityError") do
  caught_class = nil
  begin
    raise Sashite::Feen::CardinalityError, "test"
  rescue Sashite::Feen::CardinalityError => e
    caught_class = e.class
  end
  raise "expected CardinalityError" unless caught_class == Sashite::Feen::CardinalityError
end

run_test("can be caught as ParseError") do
  caught = false
  begin
    raise Sashite::Feen::CardinalityError, "test"
  rescue Sashite::Feen::ParseError
    caught = true
  end
  raise "expected to be caught as ParseError" unless caught
end

run_test("can be caught as Sashite::Feen::Error") do
  caught = false
  begin
    raise Sashite::Feen::CardinalityError, "test"
  rescue Sashite::Feen::Error
    caught = true
  end
  raise "expected to be caught as Error" unless caught
end

run_test("can be caught as ArgumentError") do
  caught = false
  begin
    raise Sashite::Feen::CardinalityError, "test"
  rescue ::ArgumentError
    caught = true
  end
  raise "expected to be caught as ArgumentError" unless caught
end

run_test("can be raised with constant message") do
  message = nil
  begin
    raise Sashite::Feen::CardinalityError, Sashite::Feen::CardinalityError::TOO_MANY_PIECES
  rescue Sashite::Feen::CardinalityError => e
    message = e.message
  end
  raise "message mismatch" unless message == Sashite::Feen::CardinalityError::TOO_MANY_PIECES
end

# ============================================================================
# TYPE CHECKING
# ============================================================================

puts
puts "Type checking:"

run_test("instance is a CardinalityError") do
  error = Sashite::Feen::CardinalityError.new("test")
  raise "expected CardinalityError === error" unless Sashite::Feen::CardinalityError === error
end

run_test("instance is a ParseError") do
  error = Sashite::Feen::CardinalityError.new("test")
  raise "expected ParseError === error" unless Sashite::Feen::ParseError === error
end

run_test("instance is a Sashite::Feen::Error") do
  error = Sashite::Feen::CardinalityError.new("test")
  raise "expected Error === error" unless Sashite::Feen::Error === error
end

# ============================================================================
# CLASS PROPERTIES
# ============================================================================

puts
puts "Class properties:"

run_test("class name is correct") do
  result = Sashite::Feen::CardinalityError.name
  raise "expected 'Sashite::Feen::CardinalityError', got #{result.inspect}" unless result == "Sashite::Feen::CardinalityError"
end

puts
puts "All CardinalityError tests passed!"
puts
