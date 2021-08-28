class Imbecile

  class Parser

    def initialize(tokens, rules)
      start_items = rules["Start"].patterns.map do |pattern|
        Item.new(pattern, 0)
      end
      start_item_set = ItemSet.new(start_items)
      start_item_set.close!
    end

  end

end
