class Propane
  class Lexer

    attr_reader :state_table
    attr_reader :transition_table
    attr_reader :mode_table

    def initialize(grammar)
      @grammar = grammar
      build_tables!
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

    private

    def build_tables!
      @modes = @grammar.patterns.group_by do |pattern|
        pattern.mode
      end.transform_values do |patterns|
        {dfa: DFA.new(patterns)}
      end
      @modes.each_with_index do |(mode_name, mode_info), index|
        mode_info[:id] = index
      end
      @state_table = []
      @transition_table = []
      @mode_table = []
      @modes.each do |mode_name, mode_info|
        state_table_offset = @state_table.size
        @mode_table << {
          state_table_offset: state_table_offset,
        }
        states = mode_info[:dfa].enumerate
        states.each do |state, id|
          token = state.accepts && state.accepts.token && state.accepts.token.id
          code_id = state.accepts && state.accepts.code_id && state.accepts.code_id
          @state_table << {
            transition_table_index: @transition_table.size,
            n_transitions: state.transitions.size,
            accepts: !!state.accepts,
            token: token,
            code_id: code_id,
          }
          state.transitions.each do |transition|
            @transition_table << {
              first: transition.code_point_range.first,
              last: transition.code_point_range.last,
              destination: states[transition.destination] + state_table_offset,
            }
          end
        end
      end
    end

  end
end
