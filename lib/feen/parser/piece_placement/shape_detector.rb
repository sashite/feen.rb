# frozen_string_literal: true

module Feen
  module Parser
    module PiecePlacement
      # Detects board shape from FEEN string before parsing
      module ShapeDetector
        # Detects the shape from a piece placement string
        #
        # @param piece_placement_str [String] FEEN piece placement string
        # @return [Array<Integer>] Array of dimension sizes
        def self.detect_shape(piece_placement_str)
          separator_types = find_separator_types(piece_placement_str).sort

          # No separators = single rank
          return [calculate_rank_size(piece_placement_str)] if separator_types.empty?

          # Build shape by processing separators from highest to lowest
          detect_shape_recursive(piece_placement_str, separator_types.reverse)
        end

        # Recursively detects shape by processing separators
        #
        # @param current_str [String] Current string to process
        # @param remaining_separator_types [Array<Integer>] Remaining separator depths to process
        # @param accumulated_shape [Array<Integer>] Shape accumulated so far
        # @return [Array<Integer>] Complete shape array
        def self.detect_shape_recursive(current_str, remaining_separator_types, accumulated_shape = [])
          return accumulated_shape + [calculate_rank_size(current_str)] if remaining_separator_types.empty?

          current_depth = remaining_separator_types.first
          remaining_depths = remaining_separator_types.drop(1)
          separator = "/" * current_depth

          parts = split_by_separator(current_str, separator)
          new_shape = accumulated_shape + [parts.size]

          detect_shape_recursive(parts.first, remaining_depths, new_shape)
        end

        # Finds all separator types present in the string
        #
        # @param str [String] Input string to analyze
        # @return [Array<Integer>] Array of unique separator depths
        def self.find_separator_types(str)
          separators = str.scan(%r{/+})
          return [] if separators.empty?

          separators.map(&:length).uniq
        end

        # Splits a string by an exact separator
        #
        # @param str [String] String to split
        # @param separator [String] Separator to split by
        # @return [Array<String>] Split parts
        def self.split_by_separator(str, separator)
          split_recursive(str, separator)
        end

        # Recursively splits a string by separator
        #
        # @param str [String] String to process
        # @param separator [String] Separator pattern
        # @param index [Integer] Current position
        # @param current_part [String] Current accumulated part
        # @param parts [Array<String>] Accumulated parts
        # @return [Array<String>] Split parts
        def self.split_recursive(str, separator, index = 0, current_part = "", parts = [])
          return parts + [current_part] if index >= str.length && !current_part.empty?
          return parts if index >= str.length

          if str[index] == "/" && str[index, separator.length] == separator
            new_parts = current_part.empty? ? parts : parts + [current_part]
            split_recursive(str, separator, index + separator.length, "", new_parts)
          else
            split_recursive(str, separator, index + 1, current_part + str[index], parts)
          end
        end

        # Calculates the size of a rank from its string representation
        #
        # @param rank_str [String] Rank string to analyze
        # @return [Integer] Number of cells in the rank
        def self.calculate_rank_size(rank_str)
          calculate_rank_size_recursive(rank_str)
        end

        # Recursively calculates rank size
        #
        # @param str [String] Remaining string to process
        # @param index [Integer] Current position
        # @param accumulated_size [Integer] Size accumulated so far
        # @return [Integer] Total rank size
        def self.calculate_rank_size_recursive(str, index = 0, accumulated_size = 0)
          return accumulated_size if index >= str.length

          char = str[index]

          if char.match?(/[1-9]/)
            # Handle empty cells
            number_info = extract_number(str, index)
            calculate_rank_size_recursive(str, number_info[:next_index], accumulated_size + number_info[:value])
          else
            # Handle piece
            piece_end = find_piece_end(str, index)
            calculate_rank_size_recursive(str, piece_end, accumulated_size + 1)
          end
        end

        # Extracts a number from the string
        #
        # @param str [String] String to process
        # @param start_index [Integer] Starting position
        # @return [Hash] Number value and next index
        def self.extract_number(str, start_index)
          end_index = start_index
          end_index += 1 while end_index < str.length && str[end_index].match?(/[0-9]/)

          {
            value:      str[start_index...end_index].to_i,
            next_index: end_index
          }
        end

        # Finds the end position of a piece in the string
        #
        # @param str [String] String to process
        # @param start_index [Integer] Starting position
        # @return [Integer] End position of the piece
        def self.find_piece_end(str, start_index)
          index = start_index

          # Skip prefix if present
          index += 1 if index < str.length && ["+", "-"].include?(str[index])

          # Skip piece identifier
          index += 1 if index < str.length

          # Skip suffix if present
          index += 1 if index < str.length && ["=", "<", ">"].include?(str[index])

          index
        end
      end
    end
  end
end
