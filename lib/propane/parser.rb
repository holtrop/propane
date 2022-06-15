class Propane

  class Parser

    def initialize(start_rule_set)
      @eof_token = Token.new(name: "$", id: TOKEN_EOF)
      start_rule = Rule.new("$$", [start_rule_set, @eof_token], nil, nil, 0)
      @item_sets = []
      @item_sets_set = {}
      start_item = Item.new(start_rule, 0)
      eval_item_sets = Set[ItemSet.new([start_item])]

      while eval_item_sets.size > 0
        item_set = eval_item_sets.first
        eval_item_sets.delete(item_set)
        unless @item_sets_set.include?(item_set)
          item_set.id = @item_sets.size
          @item_sets << item_set
          @item_sets_set[item_set] = item_set
          item_set.following_symbols.each do |following_symbol|
            unless following_symbol == @eof_token
              following_set = item_set.build_following_item_set(following_symbol)
              eval_item_sets << following_set
            end
          end
        end
      end

      @item_sets.each do |item_set|
        process_item_set(item_set)
        puts "Item set #{item_set.id}:"
        ids = item_set.in_sets.map(&:id)
        if ids.size > 0
          puts "    (in from #{ids.join(", ")})"
        end
        puts item_set
        item_set.following_item_set.each do |following_symbol, following_item_set|
          puts " #{following_symbol.name} => #{following_item_set.id}"
        end
        puts
      end
    end

    def build_tables
      shift_table = []
      state_table = []
      @item_sets.each do |item_set|
        shift_entries = item_set.following_symbols.select do |following_symbol|
          following_symbol.is_a?(Token)
        end.map do |following_symbol|
          {
            token_id: following_symbol.id,
            state_id: item_set.following_item_set[following_symbol].id,
          }
        end
        state_table << {
          shift_index: shift_table.size,
          n_shifts: shift_entries.size,
        }
        shift_table += shift_entries
      end
      [state_table, shift_table]
    end

    private

    def process_item_set(item_set)
      item_set.following_symbols.each do |following_symbol|
        unless following_symbol == @eof_token
          following_set = @item_sets_set[item_set.build_following_item_set(following_symbol)]
          item_set.following_item_set[following_symbol] = following_set
          following_set.in_sets << item_set
        end
      end
    end

  end

end
