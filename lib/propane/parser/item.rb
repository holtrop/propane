class Propane
  class Parser

    # Represent a parser "item", which is a position in a Rule that the parser
    # could potentially be at.
    class Item

      # @return [Rule]
      #   The Rule corresponding to this Item.
      attr_reader :rule

      # @return [Integer]
      #   The parse position in this item.
      attr_reader :position

      # Construct an Item.
      #
      # @param rule [Rule]
      #   The Rule corresponding to this Item.
      # @param position [Integer]
      #   The parse position in this Item.
      def initialize(rule, position)
        @rule = rule
        @position = position
      end

      # Hash function.
      #
      # @return [Integer]
      #   Hash code.
      def hash
        [@rule, @position].hash
      end

      # Compare Item objects.
      #
      # @param other [Item]
      #   Item to compare to.
      #
      # @return [Boolean]
      #   Whether the Items are equal.
      def ==(other)
        @rule == other.rule && @position == other.position
      end

      # Compare Item objects.
      #
      # @param other [Item]
      #   Item to compare to.
      #
      # @return [Boolean]
      #   Whether the Items are equal.
      def eql?(other)
        self == other
      end

      # Return the set of Items obtained by "closing" the current item.
      #
      # If the following symbol for the current item is another Rule name, then
      # this method will return all Items for that Rule with a position of 0.
      # Otherwise, an empty Array is returned.
      #
      # @return [Array<Item>]
      #   Items obtained by "closing" the current item.
      def closed_items
        if @rule.components[@position].is_a?(RuleSet)
          @rule.components[@position].rules.map do |rule|
            Item.new(rule, 0)
          end
        else
          []
        end
      end

      # Return whether the item is "complete", meaning that the parse position
      # marker is at the end of the rule.
      #
      # @return [Boolean]
      #   Whether the item is "complete".
      def complete?
        @position == @rule.components.size
      end

      # Get the following symbol for the Item.
      #
      # That is, the symbol which follows the parse position marker in the
      # current Item.
      #
      # @param offset [Integer]
      #   Offset from current parse position to examine.
      #
      # @return [Token, RuleSet, nil]
      #   Following symbol for the Item.
      def following_symbol(offset = 0)
        @rule.components[@position + offset]
      end

      # Get the previous symbol for the Item.
      #
      # That is, the symbol which precedes the parse position marker in the
      # current Item.
      #
      # @return [Token, RuleSet, nil]
      #   Previous symbol for this Item.
      def previous_symbol
        if @position > 0
          @rule.components[@position - 1]
        end
      end

      # Get whether this Item is followed by the provided symbol.
      #
      # @param symbol [Token, RuleSet]
      #   Symbol to query.
      #
      # @return [Boolean]
      #   Whether this Item is followed by the provided symbol.
      def followed_by?(symbol)
        following_symbol == symbol
      end

      # Get the following item for this Item.
      #
      # That is, the Item formed by moving the parse position marker one place
      # forward from its position in this Item.
      #
      # @return [Item]
      #   The following item for this Item.
      def following_item
        Item.new(@rule, @position + 1)
      end

      # Represent the Item as a String.
      #
      # @return [String]
      #   The Item represented as a String.
      def to_s
        parts = @rule.components.map(&:name)
        parts[@position, 0] = "."
        "#{@rule.name} -> #{parts.join(" ")}"
      end

    end

  end
end
