module Imbecile
  class Regex

    class NFA

      class State

        attr_accessor :accepts
        attr_reader :transitions

        def initialize
          @transitions = []
        end

        def add_transition(code_point, destination_state)
          @transitions << [code_point, destination_state]
        end

      end

      attr_accessor :start_state

      attr_accessor :end_state

      def initialize
        @start_state = State.new
        @end_state = State.new
      end

      def to_s
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
          accepts_s = state.accepts ? " *" : ""
          rv += "#{state_id[state]}#{accepts_s}:\n"
          state.transitions.each do |range, dest_state|
            if range.nil?
              range_s = "nil"
            else
              range_s = range.first.chr
              if range.size > 1
                range_s += "-" + range.last.chr
              end
            end
            accepts_s = dest_state.accepts ? " *" : ""
            rv += "  #{range_s} => #{state_id[dest_state]}#{accepts_s}\n"
          end
        end
        while to_visit.size > 0
          visit[to_visit[0]]
          to_visit.slice!(0)
        end
        rv
      end

      class << self

        def empty
          nfa = NFA.new
          nfa.start_state.add_transition(nil, nfa.end_state)
          nfa
        end

      end

    end

  end
end
