module Imbecile
  class Regex

    class NFA

      class State

        attr_accessor :accepts
        attr_reader :transitions

        def initialize
          @transitions = []
        end

        def add_transition(code_point, destination_state)
          @transitions << [code_point, destination_state]
        end

      end

      attr_accessor :start_state

      attr_accessor :end_state

      def initialize
        @start_state = State.new
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
