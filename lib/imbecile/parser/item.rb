class Imbecile
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
        if @rule.components[@position].is_a?(Array)
          @rule.components[@position].map do |rule|
            Item.new(rule, 0)
          end
        else
          []
        end
      end

    end

  end
end
