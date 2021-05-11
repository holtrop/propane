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
          new_alternate! if @alternates.empty?
          @alternates[-1][-1]
        end
        def replace_last!(new_unit)
          @alternates[-1][-1] = new_unit
        end
      end

      class CharacterUnit < Unit
        attr_accessor :code_point
        def initialize(c)
          @code_point = c.ord
        end
      end

      class CharacterRangeUnit < Unit
        attr_accessor :start_code_point
        attr_accessor :end_code_point
        def initialize(c1, c2)
          @start_code_point = c1.ord
          @end_code_point = c2.ord
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
          elsif c == "-" && (index == 0 || @pattern[0] == "]")
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
              end_code_point = end_cu.code_point
            else
              end_code_point = @pattern[0].ord
              @pattern.slice!(0)
            end
            cru = CharacterRangeUnit.new(begin_cu.code_point, end_code_point)
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
          else
            max_count = nil
          end
          if max_count.to_s != ""
            max_count = max_count.to_i
            if max_count < min_count
              raise Error.new("Maximum repetition count cannot be less than minimum repetition count")
            end
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
