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
        states = {start_state => 0}
        to_visit = [start_state]
        state_id = lambda do |state|
          unless states.include?(state)
            states[state] = states.values.max + 1
            to_visit << state
          end
          states[state]
        end
        visit = lambda do |state|
          accepts_s = state.accepts ? " #{state.accepts}" : ""
          rv += "#{state_id[state]}#{accepts_s}:\n"
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
            rv += "  #{range_s} => #{state_id[transition.destination]}#{accepts_s}\n"
          end
        end
        while to_visit.size > 0
          visit[to_visit[0]]
          to_visit.slice!(0)
        end
        rv
      end

    end

  end
end
