class Propane

  class Parser

    def initialize(tokens, rules)
      @token_eof = Token.new("$", nil, TOKEN_EOF)
      @item_sets = []
      @item_sets_set = {}
      start_items = rules["Start"].patterns.map do |pattern|
        pattern.components << @token_eof
        Item.new(pattern, 0)
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
        ids = item_set.in_sets.map(&:id)
        if ids.size > 0
          puts "    (in from #{ids.join(", ")})"
        end
        puts item_set
        item_set.follow_item_set.each do |follow_symbol, follow_item_set|
          puts " #{follow_symbol.name} => #{follow_item_set.id}"
        end
        puts
      end
    end

    def build_tables
      shift_table = []
      state_table = []
      @item_sets.each do |item_set|
        shift_entries = item_set.follow_symbols.select do |follow_symbol|
          follow_symbol.is_a?(Token)
        end.map do |follow_symbol|
          {
            token_id: follow_symbol.id,
            state_id: item_set.follow_item_set[follow_symbol].id,
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
      item_set.follow_symbols.each do |follow_symbol|
        unless follow_symbol == @token_eof
          follow_set = @item_sets_set[item_set.build_follow_set(follow_symbol)]
          item_set.follow_item_set[follow_symbol] = follow_set
          follow_set.in_sets << item_set
        end
      end
    end

  end

end
