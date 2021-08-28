class Imbecile

  class Parser

    def initialize(tokens, rules)
      start_rules = rules.select {|rule| rule.name == "Start"}
      start_items = start_rules.map do |rule|
        Item.new(rule, 0)
      end
      start_item_set = ItemSet.new(start_items)
      start_item_set.close!
    end

  end

end
