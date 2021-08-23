class Imbecile
  class FA

    class State

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

  end
end
