#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../helper"
require_relative "../../../lib/sashite/feen/errors"

puts
puts "=== Errors Tests ==="
puts

# ============================================================================
# MODULE DEFINITION
# ============================================================================

puts "Module definition:"

run_test("Errors is defined") do
  raise "not defined" unless defined?(Sashite::Feen::Errors)
end

run_test("Errors is a Module") do
  raise "wrong type" unless Sashite::Feen::Errors.is_a?(Module)
end

run_test("Errors is nested under Sashite::Feen") do
  raise "wrong nesting" unless Sashite::Feen.const_defined?(:Errors)
end

# ============================================================================
# SUBMODULE LOADING
# ============================================================================

puts
puts "Submodule loading:"

run_test("Argument class is loaded") do
  raise "not loaded" unless defined?(Sashite::Feen::Errors::Argument)
end

run_test("Argument is accessible via Errors::Argument") do
  raise "not accessible" unless Sashite::Feen::Errors.const_defined?(:Argument)
end

run_test("Argument::Messages is loaded") do
  raise "not loaded" unless defined?(Sashite::Feen::Errors::Argument::Messages)
end

# ============================================================================
# INTEGRATION
# ============================================================================

puts
puts "Integration:"

run_test("can raise Errors::Argument") do
  raise Sashite::Feen::Errors::Argument, "test"
rescue Sashite::Feen::Errors::Argument
  # Expected
end

run_test("can access error messages via Errors") do
  msg = Sashite::Feen::Errors::Argument::Messages::INVALID_FIELD_COUNT
  raise "wrong message" unless msg == "invalid field count"
end

run_test("full error flow works") do
  raise Sashite::Feen::Errors::Argument, Sashite::Feen::Errors::Argument::Messages::INPUT_TOO_LONG
rescue ArgumentError => e
  raise "wrong message" unless e.message == "input exceeds 4096 characters"
end

puts
puts "All Errors tests passed!"
puts
