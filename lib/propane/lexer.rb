class Propane
  class Lexer

    def initialize(grammar)
      @grammar = grammar
    end

    def build_tables
      @modes = @grammar.patterns.group_by do |pattern|
        pattern.mode
      end.transform_values do |patterns|
        {dfa: DFA.new(patterns)}
      end
      @modes.each_with_index do |(mode_name, mode_info), index|
        mode_info[:id] = index
      end
      transition_table = []
      state_table = []
      mode_table = []
      @modes.each do |mode_name, mode_info|
        state_table_offset = state_table.size
        mode_table << {
          state_table_offset: state_table_offset,
        }
        states = mode_info[:dfa].enumerate
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
              destination: states[transition.destination] + state_table_offset,
            }
          end
        end
      end
      [transition_table, state_table, mode_table]
    end

    # Get ID for a mode.
    #
    # @param mode_name [String]
    #   Mode name.
    #
    # @return [Integer, nil]
    #   Mode ID.
    def mode_id(mode_name)
      if mode_info = @modes[mode_name]
        mode_info[:id]
      end
    end

  end
end
