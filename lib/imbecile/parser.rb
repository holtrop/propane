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
      start_item_set = ItemSet.new(start_items)

      puts "Start item set:"
      puts start_item_set
      start_item_set.follow_symbols.each do |follow_symbol|
        follow_set = start_item_set.follow_set(follow_symbol)
        puts
        puts "follow set:"
        puts follow_set
      end
    end

  end

end
