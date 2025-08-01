class Propane
  class Regex

    attr_reader :unit
    attr_reader :nfa

    def initialize(pattern, line_number)
      @pattern = pattern.dup
      @line_number = line_number
      @unit = parse_alternates
      @nfa = @unit.to_nfa
      if @pattern != ""
        raise Error.new(%[Line #{@line_number}: unexpected "#{@pattern}" in pattern])
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
            raise Error.new("Line #{@line_number}: #{c} follows nothing")
          end
        when "|"
          au.new_alternate!
        when "\\"
          au << parse_backslash
        when "."
          au << period_character_class
        else
          au << CharacterRangeUnit.new(c)
        end
      end
      au
    end

    def parse_group
      au = parse_alternates
      if @pattern[0] != ")"
        raise Error.new("Line #{@line_number}: unterminated group in pattern")
      end
      @pattern.slice!(0)
      au
    end

    def parse_character_class
      ccu = CharacterClassUnit.new
      index = 0
      loop do
        if @pattern == ""
          raise Error.new("Line #{@line_number}: unterminated character class")
        end
        c = @pattern.slice!(0)
        if c == "]"
          break
        elsif c == "^" && index == 0
          ccu.negate = true
        elsif c == "-" && (ccu.size == 0 || @pattern[0] == "]")
          ccu << CharacterRangeUnit.new(c)
        elsif c == "\\"
          ccu << parse_backslash
        elsif c == "-" && @pattern[0] != "]"
          begin_cu = ccu.last_unit
          unless begin_cu.is_a?(CharacterRangeUnit) && begin_cu.code_point_range.size == 1
            raise Error.new("Line #{@line_number}: character range must be between single characters")
          end
          if @pattern[0] == "\\"
            @pattern.slice!(0)
            end_cu = parse_backslash
            unless end_cu.is_a?(CharacterRangeUnit) && end_cu.code_point_range.size == 1
              raise Error.new("Line #{@line_number}: character range must be between single characters")
            end
            max_code_point = end_cu.code_point
          else
            max_code_point = @pattern[0].ord
            @pattern.slice!(0)
          end
          cru = CharacterRangeUnit.new(begin_cu.first, max_code_point)
          ccu.replace_last!(cru)
        else
          ccu << CharacterRangeUnit.new(c)
        end
        index += 1
      end
      ccu
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
            raise Error.new("Line #{@line_number}: maximum repetition count cannot be less than minimum repetition count")
          end
        else
          max_count = nil
        end
        @pattern = pattern
        [min_count, max_count]
      else
        raise Error.new("Line #{@line_number}: unexpected match count following {")
      end
    end

    def parse_backslash
      if @pattern == ""
        raise Error.new("Line #{@line_number}: error: unfollowed \\")
      else
        c = @pattern.slice!(0)
        case c
        when "a"
          CharacterRangeUnit.new("\a")
        when "b"
          CharacterRangeUnit.new("\b")
        when "d"
          CharacterRangeUnit.new("0", "9")
        when "D"
          ccu = CharacterClassUnit.new
          ccu << CharacterRangeUnit.new("0", "9")
          ccu.negate = true
          ccu
        when "f"
          CharacterRangeUnit.new("\f")
        when "n"
          CharacterRangeUnit.new("\n")
        when "r"
          CharacterRangeUnit.new("\r")
        when "s"
          ccu = CharacterClassUnit.new
          ccu << CharacterRangeUnit.new(" ")
          ccu << CharacterRangeUnit.new("\t")
          ccu << CharacterRangeUnit.new("\r")
          ccu << CharacterRangeUnit.new("\n")
          ccu << CharacterRangeUnit.new("\f")
          ccu << CharacterRangeUnit.new("\v")
          ccu
        when "S"
          ccu = CharacterClassUnit.new
          ccu << CharacterRangeUnit.new(" ")
          ccu << CharacterRangeUnit.new("\t")
          ccu << CharacterRangeUnit.new("\r")
          ccu << CharacterRangeUnit.new("\n")
          ccu << CharacterRangeUnit.new("\f")
          ccu << CharacterRangeUnit.new("\v")
          ccu.negate = true
          ccu
        when "t"
          CharacterRangeUnit.new("\t")
        when "v"
          CharacterRangeUnit.new("\v")
        when "w"
          ccu = CharacterClassUnit.new
          ccu << CharacterRangeUnit.new("_")
          ccu << CharacterRangeUnit.new("0", "9")
          ccu << CharacterRangeUnit.new("a", "z")
          ccu << CharacterRangeUnit.new("A", "Z")
          ccu
        when "W"
          ccu = CharacterClassUnit.new
          ccu << CharacterRangeUnit.new("_")
          ccu << CharacterRangeUnit.new("0", "9")
          ccu << CharacterRangeUnit.new("a", "z")
          ccu << CharacterRangeUnit.new("A", "Z")
          ccu.negate = true
          ccu
        else
          CharacterRangeUnit.new(c)
        end
      end
    end

    def period_character_class
      ccu = CharacterClassUnit.new
      ccu << CharacterRangeUnit.new(0, "\n".ord - 1)
      ccu << CharacterRangeUnit.new("\n".ord + 1, 0xFFFFFFFF)
      ccu
    end

  end
end
