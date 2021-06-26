module Imbecile
  class Regex

    class FA

      attr_reader :start_state

      def initialize
        @start_state = State.new
      end

      def to_s
        chr = lambda do |value|
          if value < 32 || value > 127
            "{#{value}}"
          else
            value.chr
          end
        end
        rv = ""
        states = enumerate
        states.each do |state, id|
          accepts_s = state.accepts ? " #{state.accepts}" : ""
          rv += "#{id}#{accepts_s}:\n"
          state.transitions.each do |transition|
            if transition.nil?
              range_s = "nil"
            else
              range_s = chr[transition.code_point_range.first]
              if transition.code_point_range.size > 1
                range_s += "-" + chr[transition.code_point_range.last]
              end
            end
            accepts_s = transition.destination.accepts ? " #{transition.destination.accepts}" : ""
            rv += "  #{range_s} => #{states[transition.destination]}#{accepts_s}\n"
          end
        end
        rv
      end

      def enumerate
        @_enumerated ||=
          begin
            id = 0
            states = {}
            visit = lambda do |state|
              unless states.include?(state)
                id += 1
                states[state] = id
                state.transitions.each do |transition|
                  visit[transition.destination]
                end
              end
            end
            visit[@start_state]
            states
          end
      end

      def build_tables
        transition_table = []
        state_table = []
        states = enumerate
        states.each do |state, id|
          accepts =
            if state.accepts
              if state.accepts.name
                state.accepts.id
              else
                0xFFFFFFFE # drop token
              end
            else
              0xFFFFFFFF # not an accepting state
            end
          state_table << {
            transition_table_index: transition_table.size,
            n_transitions: state.transitions.size,
            accepts: state.accepts ? state.accepts.id : 0xFFFFFFFF,
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
end
