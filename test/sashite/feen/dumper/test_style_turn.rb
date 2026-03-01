#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/dumper/style_turn"

puts
puts "=== Dumper::StyleTurn Tests ==="
puts

ST = Sashite::Feen::Dumper::StyleTurn

# ============================================================================
# FIRST PLAYER TO MOVE
# ============================================================================

puts "first player to move:"

Test("active style is first player's") do
  [%w[C c], %w[S s], %w[X x], %w[G g]].each do |first, second|
    raise "#{first}/#{second}" unless ST.dump(first, second, :first) == "#{first}/#{second}"
  end
end

# ============================================================================
# SECOND PLAYER TO MOVE
# ============================================================================

puts
puts "second player to move:"

Test("active style is second player's") do
  [%w[C c], %w[S s], %w[X x]].each do |first, second|
    raise "#{second}/#{first}" unless ST.dump(first, second, :second) == "#{second}/#{first}"
  end
end

# ============================================================================
# CROSS-STYLE
# ============================================================================

puts
puts "cross-style:"

Test("different letters, both turn directions") do
  raise unless ST.dump("C", "s", :first)  == "C/s"
  raise unless ST.dump("C", "s", :second) == "s/C"
  raise unless ST.dump("A", "z", :first)  == "A/z"
  raise unless ST.dump("A", "z", :second) == "z/A"
end

# ============================================================================
# RETURN TYPE & MODULE PROPERTIES
# ============================================================================

puts
puts "module properties:"

Test("returns String, module is frozen") do
  raise unless ST.dump("C", "c", :first).is_a?(String)
  raise unless ST.frozen?
end

puts
puts "All Dumper::StyleTurn tests passed!"
puts
