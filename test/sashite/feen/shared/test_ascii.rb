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

Test("byte values match ASCII table") do
  raise unless Ascii::ZERO       == 0x30
  raise unless Ascii::NINE       == 0x39
  raise unless Ascii::UPPER_A    == 0x41
  raise unless Ascii::UPPER_Z    == 0x5A
  raise unless Ascii::LOWER_A    == 0x61
  raise unless Ascii::LOWER_Z    == 0x7A
  raise unless Ascii::PLUS       == 0x2B
  raise unless Ascii::MINUS      == 0x2D
  raise unless Ascii::SLASH      == 0x2F
  raise unless Ascii::CARET      == 0x5E
  raise unless Ascii::APOSTROPHE == 0x27
end

# ============================================================================
# digit?
# ============================================================================

puts
puts "digit?:"

Test("true at boundaries and midrange") do
  raise unless Ascii.digit?(0x30)  # '0'
  raise unless Ascii.digit?(0x35)  # '5'
  raise unless Ascii.digit?(0x39)  # '9'
end

Test("false just outside range") do
  raise if Ascii.digit?(0x2F)  # '/' = 0x30 - 1
  raise if Ascii.digit?(0x3A)  # ':' = 0x39 + 1
end

Test("false for letters and nil") do
  raise if Ascii.digit?(0x41)  # 'A'
  raise if Ascii.digit?(0x61)  # 'a'
  raise if Ascii.digit?(nil)
end

# ============================================================================
# letter? (bit trick: byte | 0x20 maps A-Z to a-z range)
# ============================================================================

puts
puts "letter?:"

Test("true at all four boundaries") do
  raise unless Ascii.letter?(0x41)  # 'A'
  raise unless Ascii.letter?(0x5A)  # 'Z'
  raise unless Ascii.letter?(0x61)  # 'a'
  raise unless Ascii.letter?(0x7A)  # 'z'
end

Test("false just outside letter ranges") do
  raise if Ascii.letter?(0x40)  # '@' = A - 1
  raise if Ascii.letter?(0x5B)  # '[' = Z + 1 (bit trick maps to 0x7B > 'z')
  raise if Ascii.letter?(0x60)  # '`' = a - 1
  raise if Ascii.letter?(0x7B)  # '{' = z + 1
end

Test("false for gap between Z and a") do
  # 0x5B..0x60 are non-letter chars; bit trick must not produce false positives
  (0x5B..0x60).each do |byte|
    raise "false positive for 0x#{byte.to_s(16)}" if Ascii.letter?(byte)
  end
end

Test("false for digits, symbols, nil") do
  raise if Ascii.letter?(0x30)  # '0'
  raise if Ascii.letter?(0x2B)  # '+'
  raise if Ascii.letter?(0x5E)  # '^'
  raise if Ascii.letter?(nil)
end

# ============================================================================
# uppercase?
# ============================================================================

puts
puts "uppercase?:"

Test("true at boundaries and midrange") do
  raise unless Ascii.uppercase?(0x41)  # 'A'
  raise unless Ascii.uppercase?(0x4B)  # 'K'
  raise unless Ascii.uppercase?(0x5A)  # 'Z'
end

Test("false for lowercase, digits, nil") do
  raise if Ascii.uppercase?(0x61)  # 'a'
  raise if Ascii.uppercase?(0x30)  # '0'
  raise if Ascii.uppercase?(nil)
end

# ============================================================================
# lowercase?
# ============================================================================

puts
puts "lowercase?:"

Test("true at boundaries and midrange") do
  raise unless Ascii.lowercase?(0x61)  # 'a'
  raise unless Ascii.lowercase?(0x6B)  # 'k'
  raise unless Ascii.lowercase?(0x7A)  # 'z'
end

Test("false for uppercase, digits, nil") do
  raise if Ascii.lowercase?(0x41)  # 'A'
  raise if Ascii.lowercase?(0x30)  # '0'
  raise if Ascii.lowercase?(nil)
end

# ============================================================================
# MODULE PROPERTIES
# ============================================================================

puts
puts "module properties:"

Test("module is frozen") do
  raise unless Ascii.frozen?
end

puts
puts "All Ascii tests passed!"
puts
