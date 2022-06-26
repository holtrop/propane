class Propane
  class Parser

    # Represent a parser "item set", which is a set of possible items that the
    # parser could currently be parsing.
    class ItemSet

      # @return [Set<Item>]
      #   Items in this ItemSet.
      attr_reader :items

      # @return [Integer]
      #   ID of this ItemSet.
      attr_accessor :id

      # @return [Hash]
      #   Maps a following symbol to its ItemSet.
      attr_reader :following_item_set

      # @return [Set<ItemSet>]
      #   ItemSets leading to this item set.
      attr_reader :in_sets

      # @return [nil, Rule, Hash]
      #   Reduce actions, mapping lookahead tokens to rules.
      attr_accessor :reduce_actions

      # Build an ItemSet.
      #
      # @param items [Array<Item>]
      #   Items in this ItemSet.
      def initialize(items)
        @items = Set.new(items)
        @following_item_set = {}
        @in_sets = Set.new
        close!
      end

      # Get the set of following symbols for all Items in this ItemSet.
      #
      # @return [Set<Token, RuleSet>]
      #   Set of following symbols for all Items in this ItemSet.
      def following_symbols
        Set.new(@items.map(&:following_symbol).compact)
      end

      # Build a following ItemSet for the given following symbol.
      #
      # @param symbol [Token, RuleSet]
      #   Following symbol to build the following ItemSet for.
      #
      # @return [ItemSet]
      #   Following ItemSet for the given following symbol.
      def build_following_item_set(symbol)
        ItemSet.new(items_followed_by(symbol).map(&:following_item))
      end

      # Hash function.
      #
      # @return [Integer]
      #   Hash code.
      def hash
        @items.hash
      end

      # Compare ItemSet objects.
      #
      # @param other [ItemSet]
      #   ItemSet to compare to.
      #
      # @return [Boolean]
      #   Whether the ItemSets are equal.
      def ==(other)
        @items.eql?(other.items)
      end

      # Compare ItemSet objects.
      #
      # @param other [ItemSet]
      #   ItemSet to compare to.
      #
      # @return [Boolean]
      #   Whether the ItemSets are equal.
      def eql?(other)
        self == other
      end

      # Set of ItemSets that lead to this ItemSet.
      #
      # This set includes this ItemSet.
      #
      # @return [Set<ItemSet>]
      #   Set of all ItemSets that lead up to this ItemSet.
      def leading_item_sets
        @in_sets.reduce(Set[self]) do |result, item_set|
          result + item_set.leading_item_sets
        end
      end

      # Represent the ItemSet as a String.
      #
      # @return [String]
      #   The ItemSet represented as a String.
      def to_s
        @items.map(&:to_s).join("\n")
      end

      private

      # Close the ItemSet.
      #
      # This is done by recursively adding the closed Items for each Item in
      # the ItemSet.
      #
      # @return [void]
      def close!
        eval_items = @items.dup
        while eval_items.size > 0
          item = eval_items.first
          eval_items.delete(item)
          item.closed_items.each do |new_item|
            unless @items.include?(new_item)
              eval_items << new_item
            end
          end
          @items += eval_items
        end
      end

      # Get the Items followed by the given following symbol.
      #
      # @param symbol [Token, RuleSet]
      #   Following symbol.
      #
      # @return [Array<Item>]
      #   Items followed by the given following symbol.
      def items_followed_by(symbol)
        @items.select do |item|
          item.followed_by?(symbol)
        end
      end

    end

  end
end
