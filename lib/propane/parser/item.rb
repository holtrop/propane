class Propane
  class Parser

    class Item

      attr_reader :rule
      attr_reader :position

      def initialize(rule, position)
        @rule = rule
        @position = position
      end

      def next_component
        @rule.components[@position]
      end

      def hash
        [@rule, @position].hash
      end

      def ==(other)
        @rule == other.rule && @position == other.position
      end

      def eql?(other)
        self == other
      end

      def closed_items
        if @rule.components[@position].is_a?(RuleSet)
          @rule.components[@position].rules.map do |rule|
            Item.new(rule, 0)
          end
        else
          []
        end
      end

      def follow_symbol
        @rule.components[@position]
      end

      def followed_by?(symbol)
        follow_symbol == symbol
      end

      def next_position
        Item.new(@rule, @position + 1)
      end

      def to_s
        parts = []
        @rule.components.each_with_index do |symbol, index|
          if @position == index
            parts << "."
          end
          parts << symbol.name
        end
        if @position == @rule.components.size
          parts << "."
        end
        "#{@rule.name} -> #{parts.join(" ")}"
      end

    end

  end
end
