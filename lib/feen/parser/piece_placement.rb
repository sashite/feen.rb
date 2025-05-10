# frozen_string_literal: true

module Feen
  module Parser
    # Handles parsing of the piece placement section of a FEEN string
    module PiecePlacement
      # Error messages
      ERRORS = {
        invalid_type:            "Piece placement must be a string, got %s",
        empty_string:            "Piece placement string cannot be empty",
        invalid_format:          "Invalid piece placement format",
        invalid_prefix:          "Expected piece identifier after prefix",
        invalid_piece:           "Invalid piece identifier at position %d: %s",
        trailing_separator:      "Unexpected separator at the end of string or dimension group",
        inconsistent_dimension:  "Inconsistent dimension structure: expected %s, got %s",
        inconsistent_rank_size:  "Inconsistent rank size: expected %d cells, got %d cells in rank '%s'",
        inconsistent_dimensions: "Inconsistent number of dimensions within structure",
        mixed_separators:        "Mixed separator depths within the same level are not allowed: %s"
      }.freeze

      # Empty string for initialization
      EMPTY_STRING = ""

      # Dimension separator character
      DIMENSION_SEPARATOR = "/"

      # Piece prefixes
      PREFIX_PROMOTION = "+"
      PREFIX_DIMINISHED = "-"
      VALID_PREFIXES = [PREFIX_PROMOTION, PREFIX_DIMINISHED].freeze

      # Valid piece suffixes
      SUFFIX_EQUALS = "="
      SUFFIX_LEFT = "<"
      SUFFIX_RIGHT = ">"
      VALID_SUFFIXES = [SUFFIX_EQUALS, SUFFIX_LEFT, SUFFIX_RIGHT].freeze

      # Build validation pattern step by step to match BNF
      # <letter> ::= <letter-lowercase> | <letter-uppercase>
      LETTER = "[a-zA-Z]"

      # <prefix> ::= "+" | "-"
      PREFIX = "[+-]"

      # <suffix> ::= "=" | "<" | ">"
      SUFFIX = "[=<>]"

      # <piece> ::= <letter> | <prefix> <letter> | <letter> <suffix> | <prefix> <letter> <suffix>
      PIECE = "(?:#{PREFIX}?#{LETTER}#{SUFFIX}?)"

      # <number> ::= <non-zero-digit> | <non-zero-digit> <digits>
      NUMBER = "[1-9][0-9]*"

      # <cell> ::= <piece> | <number>
      CELL = "(?:#{PIECE}|#{NUMBER})"

      # <rank> ::= <cell> | <cell> <rank>
      RANK = "#{CELL}+"

      # <dim-separator> ::= <slash> <separator-tail>
      # <separator-tail> ::= "" | <slash> <separator-tail>
      # This creates patterns like /, //, ///, etc.
      DIM_SEPARATOR = "/+"

      # <dim-element> ::= <dim-group> | <rank>
      # <dim-group> ::= <dim-element> | <dim-element> <dim-separator> <dim-group>
      # <piece-placement> ::= <dim-group>
      # This recursive pattern matches: rank or rank/rank or rank//rank, etc.
      VALID_PIECE_PLACEMENT_PATTERN = /\A#{RANK}(?:#{DIM_SEPARATOR}#{RANK})*\z/

      # Parses the piece placement section of a FEEN string
      #
      # @param piece_placement_str [String] FEEN piece placement string
      # @return [Array] Hierarchical array structure representing the board where:
      #   - Empty squares are represented by empty strings ("")
      #   - Pieces are represented by strings containing their identifier and optional modifiers
      # @raise [ArgumentError] If the input string is invalid
      def self.parse(piece_placement_str)
        validate_piece_placement_string(piece_placement_str)

        # Check for trailing separators that don't contribute to dimension structure
        raise ArgumentError, ERRORS[:trailing_separator] if piece_placement_str.end_with?(DIMENSION_SEPARATOR)

        # Analyze separator structure for consistency
        detect_separator_inconsistencies(piece_placement_str)

        # Find all separator types present in the string
        separator_types = find_separator_types(piece_placement_str)

        # Parse the structure based on the separator types found
        result = if separator_types.empty?
                   # Single rank, no separators
                   parse_rank(piece_placement_str)
                 else
                   # Multiple dimensions with separators
                   parse_dimension_group(piece_placement_str, separator_types)
                 end

        # Validate the structure for dimensional consistency
        validate_structure(result)

        result
      end

      # Detects inconsistencies in separator usage
      #
      # @param str [String] FEEN piece placement string
      # @raise [ArgumentError] If separator usage is inconsistent
      # @return [void]
      def self.detect_separator_inconsistencies(str)
        # Parse the content into segments based on separators
        segments = extract_hierarchical_segments(str)

        # Validate that separators at each level have consistent depth
        validate_separator_segments(segments)
      end

      # Extracts hierarchical segments based on separator depths
      #
      # @param str [String] FEEN piece placement string
      # @return [Hash] Hierarchical structure of segments and their separators
      def self.extract_hierarchical_segments(str)
        # Locate all separators in the string
        separator_positions = []
        str.scan(%r{/+}) do
          separator_positions << {
            start:   Regexp.last_match.begin(0),
            end:     Regexp.last_match.end(0) - 1,
            depth:   Regexp.last_match[0].length,
            content: Regexp.last_match[0]
          }
        end

        # Return early if no separators
        if separator_positions.empty?
          return { segments: [{ content: str, start: 0, end: str.length - 1 }], separators: [] }
        end

        # Group separators by depth
        separators_by_depth = separator_positions.group_by { |s| s[:depth] }
        max_depth = separators_by_depth.keys.max

        # Start with the top level (deepest separators)
        top_level_separators = separators_by_depth[max_depth].sort_by { |s| s[:start] }

        # Extract top level segments
        top_segments = []

        # Add first segment if it exists
        if top_level_separators.first && top_level_separators.first[:start] > 0
          top_segments << {
            content: str[0...top_level_separators.first[:start]],
            start:   0,
            end:     top_level_separators.first[:start] - 1
          }
        end

        # Add segments between separators
        top_level_separators.each_with_index do |sep, idx|
          next_sep = top_level_separators[idx + 1]
          if next_sep
            segment_start = sep[:end] + 1
            segment_end = next_sep[:start] - 1

            if segment_end >= segment_start
              top_segments << {
                content: str[segment_start..segment_end],
                start:   segment_start,
                end:     segment_end
              }
            end
          else
            # Last segment after final separator
            segment_start = sep[:end] + 1
            if segment_start < str.length
              top_segments << {
                content: str[segment_start..],
                start:   segment_start,
                end:     str.length - 1
              }
            end
          end
        end

        # Process each segment recursively
        processed_segments = top_segments.map do |segment|
          # Check if this segment contains separators of lower depths
          subsegment = extract_hierarchical_segments(segment[:content])
          segment.merge(subsegments: subsegment[:segments], subseparators: subsegment[:separators])
        end

        { segments: processed_segments, separators: top_level_separators }
      end

      # Validates that separators are used consistently
      #
      # @param segment_data [Hash] Hierarchical structure of segments and separators
      # @raise [ArgumentError] If separators are inconsistent
      # @return [void]
      def self.validate_separator_segments(segment_data)
        segments = segment_data[:segments]
        separators = segment_data[:separators]

        # Nothing to validate if no separators
        return if separators.empty?

        # Check that all separators at this level have the same depth
        separator_depths = separators.map { |s| s[:depth] }.uniq
        raise ArgumentError, format(ERRORS[:mixed_separators], separator_depths.inspect) if separator_depths.size > 1

        # Check that sibling segments have consistent separator structure
        if segments.size > 1
          # Extract separator depths from each segment
          segment_separator_depths = segments.map do |segment|
            segment[:subseparators]&.map { |s| s[:depth] }&.uniq || []
          end

          # All segments should have the same separator depth pattern
          reference_depths = segment_separator_depths.first
          segment_separator_depths.each do |depths|
            next unless depths != reference_depths

            raise ArgumentError, format(
              ERRORS[:mixed_separators],
              "Inconsistent separator depths between segments"
            )
          end
        end

        # Recursively validate each segment's subsegments
        segments.each do |segment|
          next unless segment[:subsegments] && !segment[:subsegments].empty?

          validate_separator_segments(
            segments:   segment[:subsegments],
            separators: segment[:subseparators] || []
          )
        end
      end

      # Validates the piece placement string for basic syntax
      #
      # @param str [String] FEEN piece placement string
      # @raise [ArgumentError] If the string is invalid
      # @return [void]
      def self.validate_piece_placement_string(str)
        raise ArgumentError, format(ERRORS[:invalid_type], str.class) unless str.is_a?(String)
        raise ArgumentError, ERRORS[:empty_string] if str.empty?

        # Validate against the complete BNF pattern
        raise ArgumentError, ERRORS[:invalid_format] unless str.match?(VALID_PIECE_PLACEMENT_PATTERN)
      end

      # Finds all separator types present in the string (e.g., /, //, ///)
      #
      # @param str [String] FEEN dimension group string
      # @return [Array<Integer>] Sorted array of separator depths (1 for /, 2 for //, etc.)
      def self.find_separator_types(str)
        # Find all consecutive sequences of '/'
        separators = str.scan(%r{/+})
        return [] if separators.empty?

        # Return a unique sorted array of separator lengths
        separators.map(&:length).uniq.sort
      end

      # Recursively parses a dimension group
      #
      # @param str [String] FEEN dimension group string
      # @param separator_types [Array<Integer>] Array of separator depths found in the string
      # @return [Array] Hierarchical array structure representing the dimension group
      def self.parse_dimension_group(str, separator_types = nil)
        # Check for trailing separators at each level
        raise ArgumentError, ERRORS[:trailing_separator] if str.end_with?(DIMENSION_SEPARATOR)

        # Find all separator types if not provided
        separator_types ||= find_separator_types(str)
        return parse_rank(str) if separator_types.empty?

        # Start with the deepest separator (largest number of consecutive /)
        max_depth = separator_types.max
        separator = DIMENSION_SEPARATOR * max_depth

        # Split the string by this separator depth
        parts = split_by_separator(str, separator)

        # Validate consistency of sub-parts
        validate_parts_consistency(parts, max_depth)

        # Create the hierarchical structure
        parts.map do |part|
          # Check each part for trailing separators of lower depths
          raise ArgumentError, ERRORS[:trailing_separator] if part.end_with?(DIMENSION_SEPARATOR)

          if max_depth == 1
            # If this is the lowest level separator, parse as ranks
            parse_rank(part)
          else
            # Otherwise, continue recursively with lower level separators
            remaining_types = separator_types.reject { |t| t == max_depth }
            parse_dimension_group(part, remaining_types)
          end
        end
      end

      # Validates that all parts are consistent in structure
      #
      # @param parts [Array<String>] Parts of the dimension after splitting
      # @param depth [Integer] Depth of the current separator
      # @raise [ArgumentError] If parts are inconsistent
      # @return [void]
      def self.validate_parts_consistency(parts, depth)
        return if parts.empty? || parts.size == 1

        # If we're splitting on separators of depth > 1, make sure all parts
        # have consistent internal structure
        if depth > 1
          first_part_seps = find_separator_types(parts.first)

          parts.each_with_index do |part, index|
            next if index == 0 # Skip first part (already checked)

            part_seps = find_separator_types(part)
            next unless part_seps != first_part_seps

            raise ArgumentError, format(
              ERRORS[:inconsistent_dimension],
              first_part_seps.inspect,
              part_seps.inspect
            )
          end
        end

        # For lowest level separators, verify rank sizes are consistent
        return unless depth == 1

        expected_size = calculate_rank_size(parts.first)

        parts.each_with_index do |part, index|
          next if index == 0 # Skip first part (already checked)

          size = calculate_rank_size(part)
          next unless size != expected_size

          raise ArgumentError, format(
            ERRORS[:inconsistent_rank_size],
            expected_size,
            size,
            part
          )
        end
      end

      # Splits a string by a given separator, preserving separators of different depths
      #
      # @param str [String] String to split
      # @param separator [String] Separator to split by (e.g., "/", "//")
      # @return [Array<String>] Array of split parts
      def self.split_by_separator(str, separator)
        return [str] unless str.include?(separator)

        parts = []
        current_part = ""
        i = 0

        while i < str.length
          # If we find the start of a potential separator
          if str[i] == DIMENSION_SEPARATOR[0]
            # Check if it's our exact separator
            if i <= str.length - separator.length && str[i, separator.length] == separator
              # It's our separator, add the current part to the list
              parts << current_part unless current_part.empty?
              current_part = ""
              i += separator.length
            else
              # It's not our exact separator, count consecutive '/' characters
              start = i
              j = i
              j += 1 while j < str.length && str[j] == DIMENSION_SEPARATOR[0]

              # Add these '/' to the current part
              current_part += str[start...j]
              i = j
            end
          else
            # Normal character, add it to the current part
            current_part += str[i]
            i += 1
          end
        end

        # Add the last part if it's not empty
        parts << current_part unless current_part.empty?

        parts
      end

      # Parses a rank (sequence of cells)
      #
      # @param str [String] FEEN rank string
      # @return [Array] Array of cells (empty string for empty squares, full piece string for pieces)
      def self.parse_rank(str)
        return [] if str.nil? || str.empty?

        parse_rank_recursive(str, 0, [])
      end

      # Recursively parses a rank string
      #
      # @param str [String] FEEN rank string
      # @param index [Integer] Current index in the string
      # @param cells [Array<String>] Accumulated cells
      # @return [Array<String>] Complete array of cells
      def self.parse_rank_recursive(str, index, cells)
        return cells if index >= str.length

        char = str[index]

        if char.match?(/[1-9]/)
          # Handle empty cells (digits represent consecutive empty squares)
          empty_count_info = extract_empty_count(str, index)
          new_cells = cells + Array.new(empty_count_info[:count], "")
          parse_rank_recursive(str, empty_count_info[:next_index], new_cells)
        else
          # Handle pieces
          piece_info = extract_piece(str, index)
          new_cells = cells + [piece_info[:piece]]
          parse_rank_recursive(str, piece_info[:next_index], new_cells)
        end
      end

      # Extracts an empty count from the rank string
      #
      # @param str [String] FEEN rank string
      # @param index [Integer] Starting index
      # @return [Hash] Count and next index
      def self.extract_empty_count(str, index)
        empty_count = ""
        current_index = index

        while current_index < str.length && str[current_index].match?(/[0-9]/)
          empty_count += str[current_index]
          current_index += 1
        end

        {
          count:      empty_count.to_i,
          next_index: current_index
        }
      end

      # Extracts a piece from the rank string
      #
      # @param str [String] FEEN rank string
      # @param index [Integer] Starting index
      # @return [Hash] Piece string and next index
      # @raise [ArgumentError] If the piece format is invalid
      def self.extract_piece(str, index)
        piece_string = ""
        current_index = index
        char = str[current_index]

        # Check for prefix
        if VALID_PREFIXES.include?(char)
          piece_string += char
          current_index += 1

          # Ensure there's a piece identifier after the prefix
          if current_index >= str.length || !str[current_index].match?(/[a-zA-Z]/)
            raise ArgumentError, ERRORS[:invalid_prefix]
          end

          char = str[current_index]
        end

        # Get the piece identifier
        raise ArgumentError, format(ERRORS[:invalid_piece], current_index, char) unless char.match?(/[a-zA-Z]/)

        piece_string += char
        current_index += 1

        # Check for suffix
        if current_index < str.length && VALID_SUFFIXES.include?(str[current_index])
          piece_string += str[current_index]
          current_index += 1
        end

        {
          piece:      piece_string,
          next_index: current_index
        }
      end

      # Calculates the size of a rank based on its string representation
      #
      # @param rank_str [String] String representation of a rank
      # @return [Integer] Number of cells in the rank
      def self.calculate_rank_size(rank_str)
        calculate_rank_size_recursive(rank_str, 0, 0)
      end

      # Recursively calculates the size of a rank
      #
      # @param str [String] FEEN rank string
      # @param index [Integer] Current index
      # @param size [Integer] Accumulated size
      # @return [Integer] Final rank size
      def self.calculate_rank_size_recursive(str, index, size)
        return size if index >= str.length

        char = str[index]

        if char.match?(/[1-9]/)
          # Handle empty cells
          empty_count_info = extract_empty_count(str, index)
          calculate_rank_size_recursive(
            str,
            empty_count_info[:next_index],
            size + empty_count_info[:count]
          )
        else
          # Handle pieces
          piece_end = find_piece_end(str, index)
          calculate_rank_size_recursive(str, piece_end, size + 1)
        end
      end

      # Finds the end position of a piece in the string
      #
      # @param str [String] FEEN rank string
      # @param index [Integer] Starting position
      # @return [Integer] End position of the piece
      def self.find_piece_end(str, index)
        current_index = index

        # Skip prefix if present
        current_index += 1 if current_index < str.length && VALID_PREFIXES.include?(str[current_index])

        # Skip piece identifier
        current_index += 1 if current_index < str.length

        # Skip suffix if present
        current_index += 1 if current_index < str.length && VALID_SUFFIXES.include?(str[current_index])

        current_index
      end

      # Validates that the parsed structure has consistent dimensions
      #
      # @param structure [Array] Parsed structure to validate
      # @raise [ArgumentError] If the structure is inconsistent
      # @return [void]
      def self.validate_structure(structure)
        # Single rank or empty array - no need to validate further
        return if !structure.is_a?(Array) || structure.empty?

        # Validate dimensional consistency
        validate_dimensional_consistency(structure)
      end

      # Validates that all elements at the same level have the same structure
      #
      # @param structure [Array] Structure to validate
      # @raise [ArgumentError] If the structure is inconsistent
      # @return [void]
      def self.validate_dimensional_consistency(structure)
        return unless structure.is_a?(Array)

        # If it's an array of strings or empty strings, it's a rank - no need to validate further
        return if structure.all? { |item| item.is_a?(String) }

        # If it's a multi-dimensional array, check that all elements are arrays
        raise ArgumentError, ERRORS[:inconsistent_dimensions] unless structure.all? { |item| item.is_a?(Array) }

        # Check that all elements have the same length
        first_length = structure.first.size
        structure.each do |subarray|
          unless subarray.size == first_length
            raise ArgumentError, format(
              ERRORS[:inconsistent_rank_size],
              first_length,
              subarray.size,
              format_array_for_error(subarray)
            )
          end

          # Recursively validate each sub-structure
          validate_dimensional_consistency(subarray)
        end
      end

      # Formats an array for error messages in a more readable way
      #
      # @param array [Array] Array to format
      # @return [String] Formatted string representation
      def self.format_array_for_error(array)
        # For simple ranks, just join pieces
        if array.all? { |item| item.is_a?(String) }
          format_rank_for_error(array)
        else
          # For nested structures, use inspect (limited to keep error messages manageable)
          array.inspect[0..50] + (array.inspect.length > 50 ? "..." : "")
        end
      end

      # Formats a rank for error messages
      #
      # @param rank [Array<String>] Rank to format
      # @return [String] Formatted rank
      def self.format_rank_for_error(rank)
        result = ""
        empty_count = 0

        rank.each do |cell|
          if cell.empty?
            empty_count += 1
          else
            # Output accumulated empty cells
            result += empty_count.to_s if empty_count > 0
            empty_count = 0

            # Output the piece
            result += cell
          end
        end

        # Handle trailing empty cells
        result += empty_count.to_s if empty_count > 0

        result
      end
    end
  end
end
