module Imbecile
  class Regex

    class DFA

      def initialize(nfas)
        start_nfa = NFA.new
        nfas.each do |nfa|
          start_nfa.start_state.add_transition(nil, nfa.start_state)
        end
        nil_transition_states = start_nfa.start_state.nil_transition_states
      end

    end

  end
end
