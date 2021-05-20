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
      attr_accessor :min_code_point
      attr_accessor :max_code_point
      def initialize(c1, c2 = nil)
        @min_code_point = c1.ord
        @max_code_point = c2 ? c2.ord : @min_code_point
      end
      def range
        @min_code_point..@max_code_point
      end
      def to_nfa
        nfa = NFA.new
        nfa.start_state.add_transition(range, nfa.end_state)
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
          ranges = @units.map(&:range)
          if @negate
            ranges = negate_ranges(ranges)
          end
          ranges.each do |range|
            nfa.start_state.add_transition(range, nfa.end_state)
          end
        end
        nfa
      end
      private
      def negate_ranges(ranges)
        ranges = ranges.sort_by(&:first)
        new_ranges = []
        last_cp = -1
        ranges.each do |range|
          if range.first > (last_cp + 1)
            new_ranges << ((last_cp + 1)..(range.first - 1))
            last_cp = range.last
          end
        end
        if last_cp < 0xFFFFFFFF
          new_ranges << ((last_cp + 1)..0xFFFFFFFF)
        end
        new_ranges
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
        unit_nfa = @unit.to_nfa
        nfa.start_state.add_transition(nil, unit_nfa.start_state)
        if @min_count == 0
          nfa.start_state.add_transition(nil, nfa.end_state)
        else
          (@min_count - 1).times do
            prev_nfa = unit_nfa
            unit_nfa = @unit.to_nfa
            prev_nfa.end_state.add_transition(nil, unit_nfa.start_state)
          end
        end
        unit_nfa.end_state.add_transition(nil, nfa.end_state)
        if @max_count.nil?
          unit_nfa.end_state.add_transition(nil, unit_nfa.start_state)
        else
          (@max_count - @min_count).times do
            prev_nfa = unit_nfa
            unit_nfa = @unit.to_nfa
            prev_nfa.end_state.add_transition(nil, unit_nfa.start_state)
            unit_nfa.end_state.add_transition(nil, nfa.end_state)
          end
        end
        nfa
      end
    end

  end
end
