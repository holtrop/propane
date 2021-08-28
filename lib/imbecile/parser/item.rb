class Imbecile
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

    end

  end
end
