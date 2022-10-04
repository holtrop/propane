class Propane
  class Lexer

    # @return [DFA]
    #   Lexer DFA.
    attr_accessor :dfa

    def initialize(grammar)
      @grammar = grammar
      @dfa = DFA.new(grammar.patterns)
    end

    def build_tables
      transition_table = []
      state_table = []
      states = @dfa.enumerate
      states.each do |state, id|
        token =
          if state.accepts.nil?
            @grammar.tokens.size
          elsif state.accepts.drop?
            TOKEN_DROP
          elsif state.accepts.token
            state.accepts.token.id
          else
            @grammar.tokens.size
          end
        code_id =
          if state.accepts && state.accepts.code_id
            state.accepts.code_id
          else
            0xFFFF_FFFF
          end
        state_table << {
          transition_table_index: transition_table.size,
          n_transitions: state.transitions.size,
          token: token,
          code_id: code_id,
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
