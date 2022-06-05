class Propane
  class Lexer

    # @return [DFA]
    #   Lexer DFA.
    attr_accessor :dfa

    def initialize(tokens, drop_tokens)
      @dfa = DFA.new(tokens, drop_tokens)
    end

    def build_tables
      transition_table = []
      state_table = []
      states = @dfa.enumerate
      states.each do |state, id|
        accepts =
          if state.accepts.nil?
            TOKEN_NONE
          elsif state.accepts.drop?
            TOKEN_DROP
          else
            state.accepts.id
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

  end
end
