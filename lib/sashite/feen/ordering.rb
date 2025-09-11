# frozen_string_literal: true

module Sashite
  module Feen
    # Deterministic ordering helpers (kept minimal for now).
    # If you later need domain-specific sort (e.g., EPIN-aware), centralize it here.
    module Ordering
      module_function

      # Default lexicographic sort key for serialized EPIN tokens (String)
      def hand_token_key(token_str)
        String(token_str)
      end
    end
  end
end
