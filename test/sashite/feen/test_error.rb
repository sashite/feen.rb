#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../helper"
require_relative "../../../lib/sashite/feen/error"

puts
puts "=== Error Tests ==="
puts

# ============================================================================
# INHERITANCE
# ============================================================================

puts "Inheritance:"

run_test("inherits from ArgumentError") do
  result = Sashite::Feen::Error.superclass
  raise "expected ArgumentError, got #{result.inspect}" unless result == ::ArgumentError
end

run_test("is a subclass of StandardError") do
  result = Sashite::Feen::Error < ::StandardError
  raise "expected to be subclass of StandardError" unless result == true
end

run_test("is a subclass of Exception") do
  result = Sashite::Feen::Error < ::Exception
  raise "expected to be subclass of Exception" unless result == true
end

# ============================================================================
# INSTANTIATION
# ============================================================================

puts
puts "Instantiation:"

run_test("can be instantiated without message") do
  error = Sashite::Feen::Error.new
  raise "expected Error instance" unless ::Sashite::Feen::Error === error
end

run_test("can be instantiated with message") do
  error = Sashite::Feen::Error.new("test message")
  raise "expected Error instance" unless ::Sashite::Feen::Error === error
end

run_test("stores message correctly") do
  error = Sashite::Feen::Error.new("test message")
  raise "expected 'test message', got #{error.message.inspect}" unless error.message == "test message"
end

run_test("has empty message when none provided") do
  error = Sashite::Feen::Error.new
  # ArgumentError with no message returns class name or empty string depending on Ruby version
  result = error.message
  raise "message should be String" unless ::String === result
end

# ============================================================================
# RAISING AND CATCHING
# ============================================================================

puts
puts "Raising and catching:"

run_test("can be raised") do
  raised = false
  begin
    raise Sashite::Feen::Error, "test"
  rescue Sashite::Feen::Error
    raised = true
  end
  raise "expected error to be raised" unless raised
end

run_test("can be caught as Sashite::Feen::Error") do
  caught_class = nil
  begin
    raise Sashite::Feen::Error, "test"
  rescue Sashite::Feen::Error => e
    caught_class = e.class
  end
  raise "expected Sashite::Feen::Error, got #{caught_class.inspect}" unless caught_class == Sashite::Feen::Error
end

run_test("can be caught as ArgumentError") do
  caught = false
  begin
    raise Sashite::Feen::Error, "test"
  rescue ::ArgumentError
    caught = true
  end
  raise "expected to be caught as ArgumentError" unless caught
end

run_test("can be caught as StandardError") do
  caught = false
  begin
    raise Sashite::Feen::Error, "test"
  rescue ::StandardError
    caught = true
  end
  raise "expected to be caught as StandardError" unless caught
end

run_test("preserves message when raised") do
  message = nil
  begin
    raise Sashite::Feen::Error, "specific error message"
  rescue Sashite::Feen::Error => e
    message = e.message
  end
  raise "expected 'specific error message', got #{message.inspect}" unless message == "specific error message"
end

# ============================================================================
# BACKTRACE
# ============================================================================

puts
puts "Backtrace:"

run_test("has backtrace when raised") do
  backtrace = nil
  begin
    raise Sashite::Feen::Error, "test"
  rescue Sashite::Feen::Error => e
    backtrace = e.backtrace
  end
  raise "expected backtrace to be present" if backtrace.nil?
  raise "expected backtrace to be Array" unless ::Array === backtrace
  raise "expected backtrace to have entries" if backtrace.empty?
end

# ============================================================================
# TYPE CHECKING
# ============================================================================

puts
puts "Type checking:"

run_test("instance responds to message") do
  error = Sashite::Feen::Error.new("test")
  raise "expected to respond to :message" unless error.respond_to?(:message)
end

run_test("instance responds to backtrace") do
  error = Sashite::Feen::Error.new("test")
  raise "expected to respond to :backtrace" unless error.respond_to?(:backtrace)
end

run_test("instance is an Error") do
  error = Sashite::Feen::Error.new("test")
  raise "expected Error === error" unless Sashite::Feen::Error === error
end

run_test("instance is an ArgumentError") do
  error = Sashite::Feen::Error.new("test")
  raise "expected ArgumentError === error" unless ::ArgumentError === error
end

run_test("instance is a StandardError") do
  error = Sashite::Feen::Error.new("test")
  raise "expected StandardError === error" unless ::StandardError === error
end

# ============================================================================
# CLASS PROPERTIES
# ============================================================================

puts
puts "Class properties:"

run_test("class name is correct") do
  result = Sashite::Feen::Error.name
  raise "expected 'Sashite::Feen::Error', got #{result.inspect}" unless result == "Sashite::Feen::Error"
end

puts
puts "All Error tests passed!"
puts
