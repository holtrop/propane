class Imbecile

  class Parser

    def initialize(tokens, rules)
      @token_eof = Token.new("$", nil, TOKEN_EOF)
      @item_sets = []
      @item_sets_set = {}
      start_items = rules["Start"].map do |rule|
        rule.components << @token_eof
        Item.new(rule, 0)
      end
      eval_item_sets = Set.new
      eval_item_sets << ItemSet.new(start_items)

      while eval_item_sets.size > 0
        this_eval_item_sets = eval_item_sets
        eval_item_sets = Set.new
        this_eval_item_sets.each do |item_set|
          unless @item_sets_set.include?(item_set)
            item_set.id = @item_sets.size
            @item_sets << item_set
            @item_sets_set[item_set] = item_set
            item_set.follow_symbols.each do |follow_symbol|
              unless follow_symbol == @token_eof
                follow_set = item_set.build_follow_set(follow_symbol)
                eval_item_sets << follow_set
              end
            end
          end
        end
      end

      @item_sets.each do |item_set|
        process_item_set(item_set)
        puts "Item set #{item_set.id}:"
        puts item_set
        item_set.follow_item_set.each do |follow_symbol, follow_item_set|
          if follow_symbol.is_a?(Token)
            name = follow_symbol.name
          else
            name = follow_symbol[0].name
          end
          puts " #{name} => #{follow_item_set.id}"
        end
        puts
      end
    end

    private

    def process_item_set(item_set)
      item_set.follow_symbols.each do |follow_symbol|
        unless follow_symbol == @token_eof
          follow_set = @item_sets_set[item_set.build_follow_set(follow_symbol)]
          item_set.follow_item_set[follow_symbol] = follow_set
        end
      end
    end

  end

end
