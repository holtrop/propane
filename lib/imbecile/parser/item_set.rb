class Imbecile
  class Parser

    class ItemSet

      def initialize(items)
        @items = Set.new(items)
      end

      def close!
        eval_items = @items
        while eval_items.size > 0
          this_eval_items = eval_items
          eval_items = Set.new
          this_eval_items.each do |item|
            eval_items += item.closed_items
          end
          @items += eval_items
        end
      end

    end

  end
end
