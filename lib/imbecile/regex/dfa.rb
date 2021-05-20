module Imbecile
  class Regex

    class DFA

      def initialize(nfas)
        start_nfa = NFA.new
        nfas.each do |nfa|
          start_nfa.start_state.add_transition(nil, nfa.start_state)
        end
        nil_transition_states = nil_transition_states(start_nfa.start_state)
      end

      private

      # Determine the set of states that can be reached by nil transitions
      # from the given state.
      #
      # @return [Set<NFA::State>]
      #   Set of states.
      def nil_transition_states(state)
        states = Set[state]
        analyze_state = lambda do |state|
          state.transitions.each do |range, dest_state|
            if range.nil?
              unless states.include?(dest_state)
                states << dest_state
                analyze_state[dest_state]
              end
            end
          end
        end
        analyze_state[state]
        states
      end

    end

  end
end
