module Imbecile
  class Regex

    class Parser

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
            @units.map do |unit|
              unit.to_nfa
            end.reduce do |result, nfa|
              result.end_state.add_transition(nil, nfa.start_state)
              result
            end
          end
        end
      end

      class AlternatesUnit < Unit
        attr_accessor :alternates
        attr_accessor :negate
        def initialize
          @alternates = []
          @negate = false
        end
        def new_alternate!
          @alternates << SequenceUnit.new
        end
        def append_alternate(unit)
          @alternates << unit
        end
        def <<(unit)
          new_alternate! if @alternates.empty?
          @alternates[-1] << unit
        end
        def last_unit
          if @alternates.last.is_a?(SequenceUnit)
            @alternates[-1][-1]
          else
            @alternates[-1]
          end
        end
        def replace_last!(new_unit)
          if @alternates.last.is_a?(SequenceUnit)
            @alternates[-1][-1] = new_unit
          else
            @alternates[-1] = new_unit
          end
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

      class CharacterUnit < Unit
        attr_accessor :code_point
        def initialize(c)
          @code_point = c.ord
        end
        def to_nfa
          nfa = NFA.new
          nfa.start_state.add_transition(@code_point, nfa.end_state)
          nfa
        end
      end

      class CharacterRangeUnit < Unit
        attr_accessor :min_code_point
        attr_accessor :max_code_point
        def initialize(c1, c2)
          @min_code_point = c1.ord
          @max_code_point = c2.ord
        end
        def to_nfa
          nfa = NFA.new
          nfa.start_state.add_transition((@min_code_point..@max_code_point), nfa.end_state)
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
            unit_nfa.end_state.add_transition(nil, nfa.start_state)
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

      attr_reader :unit

      def initialize(pattern)
        @pattern = pattern.dup
        @unit = parse_alternates
        if @pattern != ""
          raise Error.new(%[Unexpected "#{@pattern}" in pattern])
        end
      end

      private

      def parse_alternates
        au = AlternatesUnit.new
        while @pattern != ""
          c = @pattern[0]
          return au if c == ")"
          @pattern.slice!(0)
          case c
          when "["
            au << parse_character_class
          when "("
            au << parse_group
          when "*", "+", "?", "{"
            if last_unit = au.last_unit
              case c
              when "*"
                min_count, max_count = 0, nil
              when "+"
                min_count, max_count = 1, nil
              when "?"
                min_count, max_count = 0, 1
              when "{"
                min_count, max_count = parse_curly_count
              end
              mu = MultiplicityUnit.new(last_unit, min_count, max_count)
              au.replace_last!(mu)
            else
              raise Error.new("#{c} follows nothing")
            end
          when "|"
            au.new_alternate!
          when "\\"
            au << parse_backslash
          else
            au << CharacterUnit.new(c)
          end
        end
        au
      end

      def parse_group
        au = parse_alternates
        if @pattern[0] != ")"
          raise Error.new("Unterminated group in pattern")
        end
        @pattern.slice!(0)
        au
      end

      def parse_character_class
        au = AlternatesUnit.new
        index = 0
        loop do
          if @pattern == ""
            raise Error.new("Unterminated character class")
          end
          c = @pattern.slice!(0)
          if c == "]"
            break
          elsif c == "^" && index == 0
            au.negate = true
          elsif c == "-" && (au.alternates.size == 0 || @pattern[0] == "]")
            au.append_alternate(CharacterUnit.new(c))
          elsif c == "\\"
            au.append_alternate(parse_backslash)
          elsif c == "-" && @pattern[0] != "]"
            begin_cu = au.last_unit
            unless begin_cu.is_a?(CharacterUnit)
              raise Error.new("Character range must be between single characters")
            end
            if @pattern[0] == "\\"
              @pattern.slice!(0)
              end_cu = parse_backslash
              unless end_cu.is_a?(CharacterUnit)
                raise Error.new("Character range must be between single characters")
              end
              max_code_point = end_cu.code_point
            else
              max_code_point = @pattern[0].ord
              @pattern.slice!(0)
            end
            cru = CharacterRangeUnit.new(begin_cu.code_point, max_code_point)
            au.replace_last!(cru)
          else
            au.append_alternate(CharacterUnit.new(c))
          end
          index += 1
        end
        au
      end

      def parse_curly_count
        if @pattern =~ /^(\d+)(?:(,)(\d*))?\}(.*)$/
          min_count, comma, max_count, pattern = $1, $2, $3, $4
          min_count = min_count.to_i
          if comma.to_s == ""
            max_count = min_count
          elsif max_count.to_s != ""
            max_count = max_count.to_i
            if max_count < min_count
              raise Error.new("Maximum repetition count cannot be less than minimum repetition count")
            end
          else
            max_count = nil
          end
          @pattern = pattern
          [min_count, max_count]
        else
          raise Error.new("Unexpected match count at #{@pattern}")
        end
      end

      def parse_backslash
        if @pattern == ""
          raise Error.new("Error: unfollowed \\")
        else
          c = @pattern.slice!(0)
          case c
          when "d"
            CharacterRangeUnit.new("0", "9")
          else
            CharacterUnit.new(c)
          end
        end
      end

    end

  end
end
