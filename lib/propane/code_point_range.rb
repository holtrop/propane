class Propane
  class CodePointRange

    MAX_CODE_POINT = 0x7FFFFFFF

    attr_reader :first
    attr_reader :last

    include Comparable

    # Build a CodePointRange
    def initialize(first, last = nil)
      @first = first.ord
      if last
        @last = last.ord
        if @last < @first
          raise "Invalid CodePointRange: last code point must be > first code point"
        end
      else
        @last = @first
      end
    end

    def <=>(other)
      if self.first != other.first
        @first <=> other.first
      else
        @last <=> other.last
      end
    end

    def include?(v)
      if v.is_a?(CodePointRange)
        @first <= v.first && v.last <= @last
      else
        @first <= v && v <= @last
      end
    end

    def size
      @last - @first + 1
    end

    class << self

      def invert_ranges(code_point_ranges)
        new_ranges = []
        last_cp = -1
        code_point_ranges.sort.each do |code_point_range|
          if code_point_range.first > (last_cp + 1)
            new_ranges << CodePointRange.new(last_cp + 1, code_point_range.first - 1)
            last_cp = code_point_range.last
          else
            last_cp = [last_cp, code_point_range.last].max
          end
        end
        if last_cp < MAX_CODE_POINT
          new_ranges << CodePointRange.new(last_cp + 1, MAX_CODE_POINT)
        end
        new_ranges
      end

      def first_subrange(code_point_ranges)
        code_point_ranges.sort.reduce do |result, code_point_range|
          if code_point_range.include?(result.first)
            if code_point_range.last < result.last
              code_point_range
            else
              result
            end
          else
            if code_point_range.first <= result.last
              CodePointRange.new(result.first, code_point_range.first - 1)
            else
              result
            end
          end
        end
      end

    end

  end
end
