class Propane
  class Lexer

    class DFA < FA

      def initialize(tokens)
        super()
        start_nfa = Regex::NFA.new
        tokens.each do |name, token|
          start_nfa.start_state.add_transition(nil, token.nfa.start_state)
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
        @start_state = @states[0]
      end

      def build_tables
        transition_table = []
        state_table = []
        states = enumerate
        states.each do |state, id|
          accepts =
            if state.accepts.nil?
              TOKEN_NONE
            elsif state.accepts.name
              state.accepts.id
            else
              TOKEN_DROP
            end
          state_table << {
            transition_table_index: transition_table.size,
            n_transitions: state.transitions.size,
            accepts: accepts,
          }
          state.transitions.each do |transition|
            transition_table << {
              first: transition.code_point_range.first,
              last: transition.code_point_range.last,
              destination: states[transition.destination],
            }
          end
        end
        [transition_table, state_table]
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
        state_id = @nfa_state_sets[nfa_state_set]
        state = @states[state_id]
        if state_id > 0
          nfa_state_set.each do |nfa_state|
            if nfa_state.accepts
              if state.accepts
                if nfa_state.accepts.id < state.accepts.id
                  state.accepts = nfa_state.accepts
                end
              else
                state.accepts = nfa_state.accepts
              end
            end
          end
        end
        transitions = transitions_for(nfa_state_set)
        while transitions.size > 0
          subrange = CodePointRange.first_subrange(transitions.map(&:code_point_range))
          dest_nfa_states = transitions.reduce(Set.new) do |result, transition|
            if transition.code_point_range.include?(subrange)
              result << transition.destination
            end
            result
          end
          dest_nfa_states = dest_nfa_states.reduce(Set.new) do |result, dest_nfa_state|
            result + dest_nfa_state.nil_transition_states
          end
          register_nfa_state_set(dest_nfa_states)
          dest_state = @states[@nfa_state_sets[dest_nfa_states]]
          state.add_transition(subrange, dest_state)
          transitions.delete_if do |transition|
            transition.code_point_range.last <= subrange.last
          end
          transitions.map! do |transition|
            if transition.code_point_range.first <= subrange.last
              Regex::NFA::State::Transition.new(CodePointRange.new(subrange.last + 1, transition.code_point_range.last), transition.destination)
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
