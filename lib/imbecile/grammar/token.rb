module Imbecile
  class Grammar

    class Token

      # @return [String]
      #   Token name.
      attr_reader :name

      # @return [String]
      #   Token pattern.
      attr_reader :pattern

      # @return [Integer]
      #   Token ID.
      attr_reader :id

      # @return [Regex::NFA]
      #   Regex NFA for matching the token.
      attr_reader :nfa

      def initialize(name, pattern, id)
        @name = name
        @pattern = pattern
        @id = id
        regex = Regex.new(pattern)
        regex.nfa.end_state.accepts = self
        @nfa = regex.nfa
      end

      def c_name
        @name.upcase
      end

      def to_s
        @name
      end

    end

  end
end
