module Imbecile
  class Regex

    class DFA

      class State
      end

      def initialize(nfas)
        start_nfa = NFA.new
        nfas.each do |nfa|
          start_nfa.start_state.add_transition(nil, nfa.start_state)
        end
        @states = {}
        @to_process = Set.new
        nil_transition_states = start_nfa.start_state.nil_transition_states
        @states[nil_transition_states] = 0
        process_nfa_state_set(nil_transition_states)
      end

      private

      def process_nfa_state_set(nfa_state_set)
        transitions = transitions_for(nfa_state_set)
        while transitions.size > 0
          subrange = CodePointRange.first_subrange(transitions.map(&:code_point_range))
          dest_nfa_states = transitions.reduce(Set.new) do |result, transition|
            if transition.code_point_range.include?(subrange)
              result << transition.last
            end
            result
          end
          unless @states.include?(dest_nfa_states)
            @to_process << dest_nfa_states
          end
          transitions.delete_if do |transition|
            transition.code_point_range.last <= subrange.last
          end
          transitions.map! do |transition|
            if transition.code_point_range.first <= subrange.last
              Transition.new(CodePointRange.new(subrange.last + 1, transition.code_point_range.last), transition.destination)
            else
              transition
            end
          end
        end
      end

      def transitions_for(states)
        states.reduce([]) do |result, state|
          result + state.cp_transitions
        end
      end

    end

  end
end
