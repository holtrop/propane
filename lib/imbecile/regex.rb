module Imbecile
  class Regex

    class State
      attr_accessor :accepting

      def initialize
        @transitions = []
      end

      def add_transition(character_range, state)
        @transitions << [character_range, state]
      end
    end

    def initialize(pattern)
      @unit = Unit.new(pattern)
    end

  end
end
