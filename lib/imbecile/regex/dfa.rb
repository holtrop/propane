module Imbecile
  class Regex

    class DFA

      class State

        class Transition

          attr_reader :code_point_range
          attr_reader :destination

          def initialize(code_point_range, destination)
            @code_point_range = code_point_range
          end

        end

        attr_accessor :accepts
        attr_reader :transitions

        def initialize
          @transitions = []
        end

        def add_transition(code_point_range, destination)
          @transitions << Transition.new(code_point_range, destination)
        end

      end

      def initialize(nfas)
        start_nfa = NFA.new
        nfas.each do |nfa|
          start_nfa.start_state.add_transition(nil, nfa.start_state)
        end
        @nfa_state_sets = {}
        @states = []
        @to_process = Set.new
        nil_transition_states = start_nfa.start_state.nil_transition_states
        register_nfa_state_set(nil_transition_states)
        while @to_process.size > 0
          state_set = @to_process.first
          @to_process.delete(state_set)
          process_nfa_state_set(state_set)
        end
      end

      private

      def register_nfa_state_set(nfa_state_set)
        unless @nfa_state_sets.include?(nfa_state_set)
          state_id = @states.size
          @nfa_state_sets[nfa_state_set] = state_id
          @states << State.new
          @to_process << nfa_state_set
        end
      end

      def process_nfa_state_set(nfa_state_set)
        state = @states[@nfa_state_sets[nfa_state_set]]
        transitions = transitions_for(nfa_state_set)
        while transitions.size > 0
          subrange = CodePointRange.first_subrange(transitions.map(&:code_point_range))
          dest_nfa_states = transitions.reduce(Set.new) do |result, transition|
            if transition.code_point_range.include?(subrange)
              result << transition.destination
            end
            result
          end
          register_nfa_state_set(dest_nfa_states)
          dest_state = @states[@nfa_state_sets[dest_nfa_states]]
          state.add_transition(subrange, dest_state)
          transitions.delete_if do |transition|
            transition.code_point_range.last <= subrange.last
          end
          transitions.map! do |transition|
            if transition.code_point_range.first <= subrange.last
              NFA::State::Transition.new(CodePointRange.new(subrange.last + 1, transition.code_point_range.last), transition.destination)
            else
              transition
            end
          end
        end
      end

      def transitions_for(nfa_state_set)
        nfa_state_set.reduce([]) do |result, state|
          result + state.cp_transitions
        end
      end

    end

  end
end
