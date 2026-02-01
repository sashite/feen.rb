#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/shared/ascii"

puts
puts "=== Ascii Tests ==="
puts

# ============================================================================
# CONSTANTS - DIGITS
# ============================================================================

puts "Constants - Digits:"

run_test("ZERO equals 0x30") do
  result = Sashite::Feen::Ascii::ZERO
  raise "expected 0x30, got #{result.inspect}" unless result == 0x30
end

run_test("ZERO equals '0'.ord") do
  result = Sashite::Feen::Ascii::ZERO
  raise "expected #{('0'.ord).inspect}, got #{result.inspect}" unless result == "0".ord
end

run_test("NINE equals 0x39") do
  result = Sashite::Feen::Ascii::NINE
  raise "expected 0x39, got #{result.inspect}" unless result == 0x39
end

run_test("NINE equals '9'.ord") do
  result = Sashite::Feen::Ascii::NINE
  raise "expected #{('9'.ord).inspect}, got #{result.inspect}" unless result == "9".ord
end

# ============================================================================
# CONSTANTS - UPPERCASE LETTERS
# ============================================================================

puts
puts "Constants - Uppercase letters:"

run_test("UPPER_A equals 0x41") do
  result = Sashite::Feen::Ascii::UPPER_A
  raise "expected 0x41, got #{result.inspect}" unless result == 0x41
end

run_test("UPPER_A equals 'A'.ord") do
  result = Sashite::Feen::Ascii::UPPER_A
  raise "expected #{('A'.ord).inspect}, got #{result.inspect}" unless result == "A".ord
end

run_test("UPPER_Z equals 0x5A") do
  result = Sashite::Feen::Ascii::UPPER_Z
  raise "expected 0x5A, got #{result.inspect}" unless result == 0x5A
end

run_test("UPPER_Z equals 'Z'.ord") do
  result = Sashite::Feen::Ascii::UPPER_Z
  raise "expected #{('Z'.ord).inspect}, got #{result.inspect}" unless result == "Z".ord
end

# ============================================================================
# CONSTANTS - LOWERCASE LETTERS
# ============================================================================

puts
puts "Constants - Lowercase letters:"

run_test("LOWER_A equals 0x61") do
  result = Sashite::Feen::Ascii::LOWER_A
  raise "expected 0x61, got #{result.inspect}" unless result == 0x61
end

run_test("LOWER_A equals 'a'.ord") do
  result = Sashite::Feen::Ascii::LOWER_A
  raise "expected #{('a'.ord).inspect}, got #{result.inspect}" unless result == "a".ord
end

run_test("LOWER_Z equals 0x7A") do
  result = Sashite::Feen::Ascii::LOWER_Z
  raise "expected 0x7A, got #{result.inspect}" unless result == 0x7A
end

run_test("LOWER_Z equals 'z'.ord") do
  result = Sashite::Feen::Ascii::LOWER_Z
  raise "expected #{('z'.ord).inspect}, got #{result.inspect}" unless result == "z".ord
end

# ============================================================================
# CONSTANTS - SPECIAL CHARACTERS
# ============================================================================

puts
puts "Constants - Special characters:"

run_test("PLUS equals 0x2B") do
  result = Sashite::Feen::Ascii::PLUS
  raise "expected 0x2B, got #{result.inspect}" unless result == 0x2B
end

run_test("PLUS equals '+'.ord") do
  result = Sashite::Feen::Ascii::PLUS
  expected = "+".ord
  raise "expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("MINUS equals 0x2D") do
  result = Sashite::Feen::Ascii::MINUS
  raise "expected 0x2D, got #{result.inspect}" unless result == 0x2D
end

run_test("MINUS equals '-'.ord") do
  result = Sashite::Feen::Ascii::MINUS
  raise "expected #{('-'.ord).inspect}, got #{result.inspect}" unless result == "-".ord
end

run_test("SLASH equals 0x2F") do
  result = Sashite::Feen::Ascii::SLASH
  raise "expected 0x2F, got #{result.inspect}" unless result == 0x2F
end

run_test("SLASH equals '/'.ord") do
  result = Sashite::Feen::Ascii::SLASH
  raise "expected #{('/'.ord).inspect}, got #{result.inspect}" unless result == "/".ord
end

run_test("CARET equals 0x5E") do
  result = Sashite::Feen::Ascii::CARET
  raise "expected 0x5E, got #{result.inspect}" unless result == 0x5E
end

run_test("CARET equals '^'.ord") do
  result = Sashite::Feen::Ascii::CARET
  raise "expected #{('^'.ord).inspect}, got #{result.inspect}" unless result == "^".ord
end

run_test("APOSTROPHE equals 0x27") do
  result = Sashite::Feen::Ascii::APOSTROPHE
  raise "expected 0x27, got #{result.inspect}" unless result == 0x27
end

run_test("APOSTROPHE equals \"'\".ord") do
  result = Sashite::Feen::Ascii::APOSTROPHE
  raise "expected #{("'".ord).inspect}, got #{result.inspect}" unless result == "'".ord
end

# ============================================================================
# digit? PREDICATE
# ============================================================================

puts
puts "digit? predicate:"

run_test("returns true for '0'") do
  result = Sashite::Feen::Ascii.digit?("0".ord)
  raise "expected true, got #{result.inspect}" unless result == true
end

run_test("returns true for '5'") do
  result = Sashite::Feen::Ascii.digit?("5".ord)
  raise "expected true, got #{result.inspect}" unless result == true
end

run_test("returns true for '9'") do
  result = Sashite::Feen::Ascii.digit?("9".ord)
  raise "expected true, got #{result.inspect}" unless result == true
end

run_test("returns true for all digits 0-9") do
  ("0".."9").each do |char|
    result = Sashite::Feen::Ascii.digit?(char.ord)
    raise "expected true for '#{char}', got #{result.inspect}" unless result == true
  end
end

run_test("returns false for 'A'") do
  result = Sashite::Feen::Ascii.digit?("A".ord)
  raise "expected false, got #{result.inspect}" unless result == false
end

run_test("returns false for 'z'") do
  result = Sashite::Feen::Ascii.digit?("z".ord)
  raise "expected false, got #{result.inspect}" unless result == false
end

run_test("returns false for '+'") do
  result = Sashite::Feen::Ascii.digit?("+".ord)
  raise "expected false, got #{result.inspect}" unless result == false
end

run_test("returns false for nil") do
  result = Sashite::Feen::Ascii.digit?(nil)
  raise "expected false, got #{result.inspect}" unless result == false
end

run_test("returns false for byte just before '0'") do
  result = Sashite::Feen::Ascii.digit?(0x2F)
  raise "expected false for 0x2F, got #{result.inspect}" unless result == false
end

run_test("returns false for byte just after '9'") do
  result = Sashite::Feen::Ascii.digit?(0x3A)
  raise "expected false for 0x3A, got #{result.inspect}" unless result == false
end

# ============================================================================
# letter? PREDICATE
# ============================================================================

puts
puts "letter? predicate:"

run_test("returns true for 'A'") do
  result = Sashite::Feen::Ascii.letter?("A".ord)
  raise "expected true, got #{result.inspect}" unless result == true
end

run_test("returns true for 'Z'") do
  result = Sashite::Feen::Ascii.letter?("Z".ord)
  raise "expected true, got #{result.inspect}" unless result == true
end

run_test("returns true for 'a'") do
  result = Sashite::Feen::Ascii.letter?("a".ord)
  raise "expected true, got #{result.inspect}" unless result == true
end

run_test("returns true for 'z'") do
  result = Sashite::Feen::Ascii.letter?("z".ord)
  raise "expected true, got #{result.inspect}" unless result == true
end

run_test("returns true for all uppercase letters A-Z") do
  ("A".."Z").each do |char|
    result = Sashite::Feen::Ascii.letter?(char.ord)
    raise "expected true for '#{char}', got #{result.inspect}" unless result == true
  end
end

run_test("returns true for all lowercase letters a-z") do
  ("a".."z").each do |char|
    result = Sashite::Feen::Ascii.letter?(char.ord)
    raise "expected true for '#{char}', got #{result.inspect}" unless result == true
  end
end

run_test("returns false for '0'") do
  result = Sashite::Feen::Ascii.letter?("0".ord)
  raise "expected false, got #{result.inspect}" unless result == false
end

run_test("returns false for '+'") do
  result = Sashite::Feen::Ascii.letter?("+".ord)
  raise "expected false, got #{result.inspect}" unless result == false
end

run_test("returns false for nil") do
  result = Sashite::Feen::Ascii.letter?(nil)
  raise "expected false, got #{result.inspect}" unless result == false
end

# ============================================================================
# uppercase? PREDICATE
# ============================================================================

puts
puts "uppercase? predicate:"

run_test("returns true for 'A'") do
  result = Sashite::Feen::Ascii.uppercase?("A".ord)
  raise "expected true, got #{result.inspect}" unless result == true
end

run_test("returns true for 'K'") do
  result = Sashite::Feen::Ascii.uppercase?("K".ord)
  raise "expected true, got #{result.inspect}" unless result == true
end

run_test("returns true for 'Z'") do
  result = Sashite::Feen::Ascii.uppercase?("Z".ord)
  raise "expected true, got #{result.inspect}" unless result == true
end

run_test("returns true for all uppercase letters A-Z") do
  ("A".."Z").each do |char|
    result = Sashite::Feen::Ascii.uppercase?(char.ord)
    raise "expected true for '#{char}', got #{result.inspect}" unless result == true
  end
end

run_test("returns false for 'a'") do
  result = Sashite::Feen::Ascii.uppercase?("a".ord)
  raise "expected false, got #{result.inspect}" unless result == false
end

run_test("returns false for 'z'") do
  result = Sashite::Feen::Ascii.uppercase?("z".ord)
  raise "expected false, got #{result.inspect}" unless result == false
end

run_test("returns false for '5'") do
  result = Sashite::Feen::Ascii.uppercase?("5".ord)
  raise "expected false, got #{result.inspect}" unless result == false
end

run_test("returns false for nil") do
  result = Sashite::Feen::Ascii.uppercase?(nil)
  raise "expected false, got #{result.inspect}" unless result == false
end

run_test("returns false for byte just before 'A'") do
  result = Sashite::Feen::Ascii.uppercase?(0x40)
  raise "expected false for 0x40, got #{result.inspect}" unless result == false
end

run_test("returns false for byte just after 'Z'") do
  result = Sashite::Feen::Ascii.uppercase?(0x5B)
  raise "expected false for 0x5B, got #{result.inspect}" unless result == false
end

# ============================================================================
# lowercase? PREDICATE
# ============================================================================

puts
puts "lowercase? predicate:"

run_test("returns true for 'a'") do
  result = Sashite::Feen::Ascii.lowercase?("a".ord)
  raise "expected true, got #{result.inspect}" unless result == true
end

run_test("returns true for 'k'") do
  result = Sashite::Feen::Ascii.lowercase?("k".ord)
  raise "expected true, got #{result.inspect}" unless result == true
end

run_test("returns true for 'z'") do
  result = Sashite::Feen::Ascii.lowercase?("z".ord)
  raise "expected true, got #{result.inspect}" unless result == true
end

run_test("returns true for all lowercase letters a-z") do
  ("a".."z").each do |char|
    result = Sashite::Feen::Ascii.lowercase?(char.ord)
    raise "expected true for '#{char}', got #{result.inspect}" unless result == true
  end
end

run_test("returns false for 'A'") do
  result = Sashite::Feen::Ascii.lowercase?("A".ord)
  raise "expected false, got #{result.inspect}" unless result == false
end

run_test("returns false for 'Z'") do
  result = Sashite::Feen::Ascii.lowercase?("Z".ord)
  raise "expected false, got #{result.inspect}" unless result == false
end

run_test("returns false for '5'") do
  result = Sashite::Feen::Ascii.lowercase?("5".ord)
  raise "expected false, got #{result.inspect}" unless result == false
end

run_test("returns false for nil") do
  result = Sashite::Feen::Ascii.lowercase?(nil)
  raise "expected false, got #{result.inspect}" unless result == false
end

run_test("returns false for byte just before 'a'") do
  result = Sashite::Feen::Ascii.lowercase?(0x60)
  raise "expected false for 0x60, got #{result.inspect}" unless result == false
end

run_test("returns false for byte just after 'z'") do
  result = Sashite::Feen::Ascii.lowercase?(0x7B)
  raise "expected false for 0x7B, got #{result.inspect}" unless result == false
end

# ============================================================================
# MUTUAL EXCLUSIVITY
# ============================================================================

puts
puts "Mutual exclusivity:"

run_test("digits are not letters") do
  ("0".."9").each do |char|
    byte = char.ord
    is_digit = Sashite::Feen::Ascii.digit?(byte)
    is_letter = Sashite::Feen::Ascii.letter?(byte)
    raise "'#{char}' should be digit" unless is_digit == true
    raise "'#{char}' should not be letter" unless is_letter == false
  end
end

run_test("uppercase letters are not digits or lowercase") do
  ("A".."Z").each do |char|
    byte = char.ord
    is_digit = Sashite::Feen::Ascii.digit?(byte)
    is_letter = Sashite::Feen::Ascii.letter?(byte)
    is_upper = Sashite::Feen::Ascii.uppercase?(byte)
    is_lower = Sashite::Feen::Ascii.lowercase?(byte)
    raise "'#{char}' should not be digit" unless is_digit == false
    raise "'#{char}' should be letter" unless is_letter == true
    raise "'#{char}' should be uppercase" unless is_upper == true
    raise "'#{char}' should not be lowercase" unless is_lower == false
  end
end

run_test("lowercase letters are not digits or uppercase") do
  ("a".."z").each do |char|
    byte = char.ord
    is_digit = Sashite::Feen::Ascii.digit?(byte)
    is_letter = Sashite::Feen::Ascii.letter?(byte)
    is_upper = Sashite::Feen::Ascii.uppercase?(byte)
    is_lower = Sashite::Feen::Ascii.lowercase?(byte)
    raise "'#{char}' should not be digit" unless is_digit == false
    raise "'#{char}' should be letter" unless is_letter == true
    raise "'#{char}' should not be uppercase" unless is_upper == false
    raise "'#{char}' should be lowercase" unless is_lower == true
  end
end

# ============================================================================
# TYPE SAFETY
# ============================================================================

puts
puts "Type safety:"

run_test("digit? returns false for String '5'") do
  result = Sashite::Feen::Ascii.digit?("5")
  raise "expected false for String, got #{result.inspect}" unless result == false
end

run_test("letter? returns false for String 'A'") do
  result = Sashite::Feen::Ascii.letter?("A")
  raise "expected false for String, got #{result.inspect}" unless result == false
end

run_test("uppercase? returns false for String 'A'") do
  result = Sashite::Feen::Ascii.uppercase?("A")
  raise "expected false for String, got #{result.inspect}" unless result == false
end

run_test("lowercase? returns false for String 'a'") do
  result = Sashite::Feen::Ascii.lowercase?("a")
  raise "expected false for String, got #{result.inspect}" unless result == false
end

run_test("digit? returns false for Float") do
  result = Sashite::Feen::Ascii.digit?(48.0)
  raise "expected false for Float, got #{result.inspect}" unless result == false
end

run_test("letter? returns false for Array") do
  result = Sashite::Feen::Ascii.letter?([65])
  raise "expected false for Array, got #{result.inspect}" unless result == false
end

puts
puts "All Ascii tests passed!"
puts
