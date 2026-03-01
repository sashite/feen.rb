#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/shared/ascii"

puts
puts "=== Ascii Tests ==="
puts

Ascii = Sashite::Feen::Ascii

# ============================================================================
# CONSTANTS
# ============================================================================

puts "constants:"

Test("ZERO is 0x30") do
  raise "wrong value" unless Ascii::ZERO == 0x30
end

Test("NINE is 0x39") do
  raise "wrong value" unless Ascii::NINE == 0x39
end

Test("UPPER_A is 0x41") do
  raise "wrong value" unless Ascii::UPPER_A == 0x41
end

Test("UPPER_Z is 0x5A") do
  raise "wrong value" unless Ascii::UPPER_Z == 0x5A
end

Test("LOWER_A is 0x61") do
  raise "wrong value" unless Ascii::LOWER_A == 0x61
end

Test("LOWER_Z is 0x7A") do
  raise "wrong value" unless Ascii::LOWER_Z == 0x7A
end

Test("PLUS is 0x2B") do
  raise "wrong value" unless Ascii::PLUS == 0x2B
end

Test("MINUS is 0x2D") do
  raise "wrong value" unless Ascii::MINUS == 0x2D
end

Test("SLASH is 0x2F") do
  raise "wrong value" unless Ascii::SLASH == 0x2F
end

Test("CARET is 0x5E") do
  raise "wrong value" unless Ascii::CARET == 0x5E
end

Test("APOSTROPHE is 0x27") do
  raise "wrong value" unless Ascii::APOSTROPHE == 0x27
end

# ============================================================================
# digit?
# ============================================================================

puts
puts "digit?:"

Test("returns true for '0'") do
  raise "expected true" unless Ascii.digit?(0x30)
end

Test("returns true for '5'") do
  raise "expected true" unless Ascii.digit?(0x35)
end

Test("returns true for '9'") do
  raise "expected true" unless Ascii.digit?(0x39)
end

Test("returns false for 'A'") do
  raise "expected false" if Ascii.digit?(0x41)
end

Test("returns false for 'a'") do
  raise "expected false" if Ascii.digit?(0x61)
end

Test("returns false for '/'") do
  raise "expected false" if Ascii.digit?(0x2F)
end

Test("returns false for nil") do
  raise "expected false" if Ascii.digit?(nil)
end

# ============================================================================
# letter?
# ============================================================================

puts
puts "letter?:"

Test("returns true for 'A'") do
  raise "expected true" unless Ascii.letter?(0x41)
end

Test("returns true for 'Z'") do
  raise "expected true" unless Ascii.letter?(0x5A)
end

Test("returns true for 'a'") do
  raise "expected true" unless Ascii.letter?(0x61)
end

Test("returns true for 'z'") do
  raise "expected true" unless Ascii.letter?(0x7A)
end

Test("returns false for '0'") do
  raise "expected false" if Ascii.letter?(0x30)
end

Test("returns false for '+'") do
  raise "expected false" if Ascii.letter?(0x2B)
end

Test("returns false for '^'") do
  raise "expected false" if Ascii.letter?(0x5E)
end

Test("returns false for nil") do
  raise "expected false" if Ascii.letter?(nil)
end

# ============================================================================
# uppercase?
# ============================================================================

puts
puts "uppercase?:"

Test("returns true for 'A'") do
  raise "expected true" unless Ascii.uppercase?(0x41)
end

Test("returns true for 'Z'") do
  raise "expected true" unless Ascii.uppercase?(0x5A)
end

Test("returns true for 'K'") do
  raise "expected true" unless Ascii.uppercase?(0x4B)
end

Test("returns false for 'a'") do
  raise "expected false" if Ascii.uppercase?(0x61)
end

Test("returns false for '0'") do
  raise "expected false" if Ascii.uppercase?(0x30)
end

Test("returns false for nil") do
  raise "expected false" if Ascii.uppercase?(nil)
end

# ============================================================================
# lowercase?
# ============================================================================

puts
puts "lowercase?:"

Test("returns true for 'a'") do
  raise "expected true" unless Ascii.lowercase?(0x61)
end

Test("returns true for 'z'") do
  raise "expected true" unless Ascii.lowercase?(0x7A)
end

Test("returns true for 'k'") do
  raise "expected true" unless Ascii.lowercase?(0x6B)
end

Test("returns false for 'A'") do
  raise "expected false" if Ascii.lowercase?(0x41)
end

Test("returns false for '0'") do
  raise "expected false" if Ascii.lowercase?(0x30)
end

Test("returns false for nil") do
  raise "expected false" if Ascii.lowercase?(nil)
end

# ============================================================================
# MODULE PROPERTIES
# ============================================================================

puts
puts "module properties:"

Test("module is frozen") do
  raise "expected frozen" unless Ascii.frozen?
end

puts
puts "All Ascii tests passed!"
puts
