class Propane
  class Parser

    # Represent a parser "item set", which is a set of possible items that the
    # parser could currently be parsing. This is equivalent to a parser state.
    class ItemSet

      # @return [Set<Item>]
      #   Items in this ItemSet.
      attr_reader :items

      # @return [Integer]
      #   ID of this ItemSet.
      attr_accessor :id

      # @return [Hash]
      #   Maps a next symbol to its ItemSet.
      attr_reader :next_item_set

      # @return [Set<ItemSet>]
      #   ItemSets leading to this item set.
      attr_reader :in_sets

      # @return [nil, Rule]
      #   Rule to reduce if there is only one possibility.
      attr_accessor :reduce_rule

      # @return [Set<Rule>]
      #   Set of rules that could be reduced in this parser state.
      attr_accessor :reduce_rules

      # @return [nil, Hash]
      #   Reduce actions, mapping lookahead tokens to rules, if there is
      #   more than one rule that could be reduced.
      attr_accessor :reduce_actions

      # Build an ItemSet.
      #
      # @param items [Array<Item>]
      #   Items in this ItemSet.
      def initialize(items)
        @items = Set.new(items)
        @next_item_set = {}
        @in_sets = Set.new
        close!
      end

      # Get the set of next symbols for all Items in this ItemSet.
      #
      # @return [Set<Token, RuleSet>]
      #   Set of next symbols for all Items in this ItemSet.
      def next_symbols
        @_next_symbols ||= Set.new(@items.map(&:next_symbol).compact)
      end

      # Build a next ItemSet for the given next symbol.
      #
      # @param symbol [Token, RuleSet]
      #   Next symbol to build the next ItemSet for.
      #
      # @return [ItemSet]
      #   Next ItemSet for the given next symbol.
      def build_next_item_set(symbol)
        ItemSet.new(items_with_next(symbol).map(&:next_item))
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
      # @return [Set<ItemSet>]
      #   Set of all ItemSets that lead up to this ItemSet.
      def leading_item_sets
        @_leading_item_sets ||=
          begin
            result = Set.new
            eval_sets = Set[self]
            evaled = Set.new
            while eval_sets.size > 0
              eval_set = eval_sets.first
              eval_sets.delete(eval_set)
              evaled << eval_set
              eval_set.in_sets.each do |in_set|
                result << in_set
                unless evaled.include?(in_set)
                  eval_sets << in_set
                end
              end
            end
            result
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

      # Get the Items with the given next symbol.
      #
      # @param symbol [Token, RuleSet]
      #   Next symbol.
      #
      # @return [Array<Item>]
      #   Items with the given next symbol.
      def items_with_next(symbol)
        @items.select do |item|
          item.next_symbol?(symbol)
        end
      end

    end

  end
end
