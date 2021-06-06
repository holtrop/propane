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

      def initialize(name, pattern, id)
        @name = name
        @pattern = pattern
        @id = id
      end

    end

  end
end
