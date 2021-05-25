module Imbecile
  class Regex

    class NFA

      class State

        class Transition

          attr_reader :code_point_range
          attr_reader :destination

          def initialize(code_point_range, destination)
            @code_point_range = code_point_range
            @destination = destination
          end

          def nil?
            @code_point_range.nil?
          end

        end

        attr_accessor :accepts
        attr_reader :transitions

        def initialize
          @transitions = []
        end

        def add_transition(code_point_range, destination)
          @transitions << Transition.new(code_point_range, destination)
        end

        # Determine the set of states that can be reached by nil transitions.
        # from this state.
        #
        # @return [Set<NFA::State>]
        #   Set of states.
        def nil_transition_states
          states = Set[self]
          analyze_state = lambda do |state|
            state.nil_transitions.each do |transition|
              unless states.include?(transition.destination)
                states << transition.destination
                analyze_state[transition.destination]
              end
            end
          end
          analyze_state[self]
          states
        end

        def nil_transitions
          @transitions.select do |transition|
            transition.nil?
          end
        end

        def cp_transitions
          @transitions.reject do |transition|
            transition.nil?
          end
        end

      end

      attr_accessor :start_state

      attr_accessor :end_state

      def initialize
        @start_state = State.new
        @end_state = State.new
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
          accepts_s = state.accepts ? " *" : ""
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
