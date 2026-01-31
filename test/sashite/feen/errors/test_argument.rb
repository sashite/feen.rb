#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/errors/argument"

puts
puts "=== Errors::Argument Tests ==="
puts

# ============================================================================
# CLASS DEFINITION
# ============================================================================

puts "Class definition:"

run_test("Argument is defined") do
  raise "not defined" unless defined?(Sashite::Feen::Errors::Argument)
end

run_test("Argument is a Class") do
  raise "wrong type" unless Sashite::Feen::Errors::Argument.is_a?(Class)
end

run_test("Argument inherits from ArgumentError") do
  raise "wrong inheritance" unless Sashite::Feen::Errors::Argument < ArgumentError
end

run_test("Argument inherits from StandardError") do
  raise "wrong inheritance" unless Sashite::Feen::Errors::Argument < StandardError
end

run_test("Argument inherits from Exception") do
  raise "wrong inheritance" unless Sashite::Feen::Errors::Argument < Exception
end

# ============================================================================
# RAISING AND RESCUING
# ============================================================================

puts
puts "Raising and rescuing:"

run_test("can be raised with a message") do
  raise Sashite::Feen::Errors::Argument, "test message"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "test message"
end

run_test("can be raised without a message") do
  raise Sashite::Feen::Errors::Argument
rescue Sashite::Feen::Errors::Argument
  # Expected
end

run_test("can be rescued as Sashite::Feen::Errors::Argument") do
  rescued = false
  begin
    raise Sashite::Feen::Errors::Argument, "test"
  rescue Sashite::Feen::Errors::Argument
    rescued = true
  end
  raise "should be rescuable" unless rescued
end

run_test("can be rescued as ArgumentError") do
  rescued = false
  begin
    raise Sashite::Feen::Errors::Argument, "test"
  rescue ArgumentError
    rescued = true
  end
  raise "should be rescuable as ArgumentError" unless rescued
end

run_test("can be rescued as StandardError") do
  rescued = false
  begin
    raise Sashite::Feen::Errors::Argument, "test"
  rescue StandardError
    rescued = true
  end
  raise "should be rescuable as StandardError" unless rescued
end

run_test("preserves message when rescued as ArgumentError") do
  begin
    raise Sashite::Feen::Errors::Argument, "specific message"
  rescue ArgumentError => e
    raise "wrong message" unless e.message == "specific message"
  end
end

# ============================================================================
# MESSAGES MODULE ACCESS
# ============================================================================

puts
puts "Messages module access:"

run_test("Messages is accessible via Argument::Messages") do
  raise "not accessible" unless defined?(Sashite::Feen::Errors::Argument::Messages)
end

run_test("Messages is a Module") do
  raise "wrong type" unless Sashite::Feen::Errors::Argument::Messages.is_a?(Module)
end

run_test("can raise with Messages constant") do
  raise Sashite::Feen::Errors::Argument, Sashite::Feen::Errors::Argument::Messages::INVALID_FIELD_COUNT
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "invalid field count"
end

# ============================================================================
# INSTANCE BEHAVIOR
# ============================================================================

puts
puts "Instance behavior:"

run_test("instance responds to message") do
  error = Sashite::Feen::Errors::Argument.new("test")
  raise "should respond to message" unless error.respond_to?(:message)
end

run_test("instance responds to backtrace") do
  error = Sashite::Feen::Errors::Argument.new("test")
  raise "should respond to backtrace" unless error.respond_to?(:backtrace)
end

run_test("instance is an ArgumentError") do
  error = Sashite::Feen::Errors::Argument.new("test")
  raise "should be an ArgumentError" unless error.is_a?(ArgumentError)
end

run_test("instance class is Argument") do
  error = Sashite::Feen::Errors::Argument.new("test")
  raise "wrong class" unless error.class == Sashite::Feen::Errors::Argument
end

# ============================================================================
# MODULE STRUCTURE
# ============================================================================

puts
puts "Module structure:"

run_test("Argument is nested under Sashite::Feen::Errors") do
  raise "wrong nesting" unless Sashite::Feen::Errors.const_defined?(:Argument)
end

puts
puts "All Errors::Argument tests passed!"
puts
