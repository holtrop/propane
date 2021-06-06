module Imbecile
  class Regex

    class NFA < FA

      attr_reader :end_state

      def initialize
        super()
        @end_state = State.new
      end

      class << self

        def empty
          nfa = NFA.new
          nfa.start_state.add_transition(nil, nfa.end_state)
          nfa
        end

      end

    end

  end
end
