class Imbecile

  class Parser

    def initialize(tokens, rules)
      token_eof = Token.new("$", nil, TOKEN_EOF)
      @item_sets = []
      item_sets_set = Set.new
      start_items = rules["Start"].patterns.map do |pattern|
        pattern.components << token_eof
        Item.new(pattern, 0)
      end
      eval_item_sets = Set.new
      eval_item_sets << ItemSet.new(start_items)

      while eval_item_sets.size > 0
        this_eval_item_sets = eval_item_sets
        eval_item_sets = Set.new
        this_eval_item_sets.each do |item_set|
          unless item_sets_set.include?(item_set)
            item_set.id = @item_sets.size
            @item_sets << item_set
            item_sets_set << item_set
            puts "Item set #{item_set.id}:"
            puts item_set
            puts
            item_set.follow_symbols.each do |follow_symbol|
              unless follow_symbol == token_eof
                follow_set = item_set.follow_set(follow_symbol)
                eval_item_sets << follow_set
              end
            end
          end
        end
      end
    end

  end

end
