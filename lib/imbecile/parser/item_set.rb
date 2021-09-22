class Imbecile
  class Parser

    class ItemSet

      attr_reader :items

      attr_accessor :id

      # @return [Hash]
      #   Maps a follow symbol to its item set.
      attr_reader :follow_item_set

      # @return [Set]
      #   Item sets leading to this item set.
      attr_reader :in_sets

      def initialize(items)
        @items = Set.new(items)
        @follow_item_set = {}
        @in_sets = Set.new
        close!
      end

      def follow_symbols
        Set.new(@items.map(&:follow_symbol).compact)
      end

      def build_follow_set(symbol)
        ItemSet.new(items_followed_by(symbol).map(&:next_position))
      end

      def hash
        @items.hash
      end

      def ==(other)
        @items.eql?(other.items)
      end

      def eql?(other)
        self == other
      end

      def to_s
        @items.map(&:to_s).join("\n")
      end

      private

      def close!
        eval_items = @items
        while eval_items.size > 0
          this_eval_items = eval_items
          eval_items = Set.new
          this_eval_items.each do |item|
            item.closed_items.each do |new_item|
              unless @items.include?(new_item)
                eval_items << new_item
              end
            end
          end
          @items += eval_items
        end
      end

      def items_followed_by(symbol)
        @items.select do |item|
          item.followed_by?(symbol)
        end
      end

    end

  end
end
