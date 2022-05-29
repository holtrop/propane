class Propane
  class Parser

    class Item

      attr_reader :pattern
      attr_reader :position

      def initialize(pattern, position)
        @pattern = pattern
        @position = position
      end

      def next_component
        @pattern.components[@position]
      end

      def hash
        [@pattern, @position].hash
      end

      def ==(other)
        @pattern == other.pattern && @position == other.position
      end

      def eql?(other)
        self == other
      end

      def closed_items
        if @pattern.components[@position].is_a?(Rule)
          @pattern.components[@position].patterns.map do |pattern|
            Item.new(pattern, 0)
          end
        else
          []
        end
      end

      def follow_symbol
        @pattern.components[@position]
      end

      def followed_by?(symbol)
        follow_symbol == symbol
      end

      def next_position
        Item.new(@pattern, @position + 1)
      end

      def to_s
        parts = []
        @pattern.components.each_with_index do |symbol, index|
          if @position == index
            parts << "."
          end
          parts << symbol.name
        end
        if @position == @pattern.components.size
          parts << "."
        end
        "#{@pattern.rule.name} -> #{parts.join(" ")}"
      end

    end

  end
end
