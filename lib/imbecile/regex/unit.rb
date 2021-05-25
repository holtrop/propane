module Imbecile
  class Regex

    class Unit
    end

    class SequenceUnit < Unit
      attr_accessor :units
      def initialize
        @units = []
      end
      def method_missing(*args)
        @units.__send__(*args)
      end
      def to_nfa
        if @units.empty?
          NFA.empty
        else
          nfa = NFA.new
          unit_nfas = @units.map do |unit|
            unit.to_nfa
          end
          nfa.start_state.add_transition(nil, unit_nfas[0].start_state)
          unit_nfas.reduce do |prev_nfa, next_nfa|
            prev_nfa.end_state.add_transition(nil, next_nfa.start_state)
            next_nfa
          end.end_state.add_transition(nil, nfa.end_state)
          nfa
        end
      end
    end

    class AlternatesUnit < Unit
      attr_accessor :alternates
      def initialize
        @alternates = []
        new_alternate!
      end
      def new_alternate!
        @alternates << SequenceUnit.new
      end
      def <<(unit)
        @alternates[-1] << unit
      end
      def last_unit
        @alternates[-1][-1]
      end
      def replace_last!(new_unit)
        @alternates[-1][-1] = new_unit
      end
      def to_nfa
        if @alternates.size == 0
          NFA.empty
        elsif @alternates.size == 1
          @alternates[0].to_nfa
        else
          nfa = NFA.new
          alternate_nfas = @alternates.map do |alternate|
            alternate.to_nfa
          end
          alternate_nfas.each do |alternate_nfa|
            nfa.start_state.add_transition(nil, alternate_nfa.start_state)
            alternate_nfa.end_state.add_transition(nil, nfa.end_state)
          end
          nfa
        end
      end
    end

    class CharacterRangeUnit < Unit
      attr_reader :code_point_range
      def initialize(c1, c2 = nil)
        @code_point_range = CodePointRange.new(c1, c2)
      end
      def first
        @code_point_range.first
      end
      def last
        @code_point_range.last
      end
      def to_nfa
        nfa = NFA.new
        nfa.start_state.add_transition(@code_point_range, nfa.end_state)
        nfa
      end
    end

    class CharacterClassUnit < Unit
      attr_accessor :units
      attr_accessor :negate
      def initialize
        @units = []
        @negate = false
      end
      def initialize
        @units = []
      end
      def method_missing(*args)
        @units.__send__(*args)
      end
      def last_unit
        @units[-1]
      end
      def replace_last!(new_unit)
        @units[-1] = new_unit
      end
      def to_nfa
        nfa = NFA.new
        if @units.empty?
          nfa.start_state.add_transition(nil, nfa.end_state)
        else
          code_point_ranges = @units.map(&:code_point_range)
          if @negate
            code_point_ranges = CodePointRange.invert_ranges(code_point_ranges)
          end
          code_point_ranges.each do |code_point_range|
            nfa.start_state.add_transition(code_point_range, nfa.end_state)
          end
        end
        nfa
      end
    end

    class MultiplicityUnit < Unit
      attr_accessor :unit
      attr_accessor :min_count
      attr_accessor :max_count
      def initialize(unit, min_count, max_count)
        @unit = unit
        @min_count = min_count
        @max_count = max_count
      end
      def to_nfa
        nfa = NFA.new
        last_state = nfa.start_state
        unit_nfa = nil
        @min_count.times do
          unit_nfa = @unit.to_nfa
          last_state.add_transition(nil, unit_nfa.start_state)
          last_state = unit_nfa.end_state
        end
        last_state.add_transition(nil, nfa.end_state)
        if @max_count.nil?
          if @min_count == 0
            unit_nfa = @unit.to_nfa
            last_state.add_transition(nil, unit_nfa.start_state)
          end
          unit_nfa.end_state.add_transition(nil, unit_nfa.start_state)
        else
          (@max_count - @min_count).times do
            unit_nfa = @unit.to_nfa
            last_state.add_transition(nil, unit_nfa.start_state)
            unit_nfa.end_state.add_transition(nil, nfa.end_state)
            last_state = unit_nfa.end_state
          end
        end
        nfa
      end
    end

  end
end
