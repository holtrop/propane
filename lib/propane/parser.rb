class Propane

  class Parser

    attr_reader :state_table
    attr_reader :shift_table
    attr_reader :reduce_table
    attr_reader :rule_sets

    def initialize(grammar, rule_sets, log)
      @grammar = grammar
      @rule_sets = rule_sets
      @log = log
      @item_sets = []
      @item_sets_set = {}
      start_item = Item.new(grammar.rules.first, 0)
      eval_item_sets = Set[ItemSet.new([start_item])]

      while eval_item_sets.size > 0
        item_set = eval_item_sets.first
        eval_item_sets.delete(item_set)
        unless @item_sets_set.include?(item_set)
          item_set.id = @item_sets.size
          @item_sets << item_set
          @item_sets_set[item_set] = item_set
          item_set.following_symbols.each do |following_symbol|
            unless following_symbol.name == "$EOF"
              following_set = item_set.build_following_item_set(following_symbol)
              eval_item_sets << following_set
            end
          end
        end
      end

      @item_sets.each do |item_set|
        process_item_set(item_set)
      end

      build_reduce_actions!
      write_log!
      build_tables!
    end

    private

    def build_tables!
      @state_table = []
      @shift_table = []
      @reduce_table = []
      @item_sets.each do |item_set|
        shift_entries = item_set.following_symbols.map do |following_symbol|
          state_id =
            if following_symbol.name == "$EOF"
              0
            else
              item_set.following_item_set[following_symbol].id
            end
          {
            symbol_id: following_symbol.id,
            state_id: state_id,
          }
        end
        reduce_entries =
          case ra = item_set.reduce_actions
          when Rule
            [{token_id: @grammar.invalid_token_id, rule_id: ra.id,
              rule_set_id: ra.rule_set.id, n_states: ra.components.size}]
          when Hash
            ra.map do |token, rule|
              {token_id: token.id, rule_id: rule.id,
               rule_set_id: rule.rule_set.id, n_states: rule.components.size}
            end
          else
            []
          end
        @state_table << {
          shift_index: @shift_table.size,
          n_shifts: shift_entries.size,
          reduce_index: @reduce_table.size,
          n_reduces: reduce_entries.size,
        }
        @shift_table += shift_entries
        @reduce_table += reduce_entries
      end
    end

    def process_item_set(item_set)
      item_set.following_symbols.each do |following_symbol|
        unless following_symbol.name == "$EOF"
          following_set = @item_sets_set[item_set.build_following_item_set(following_symbol)]
          item_set.following_item_set[following_symbol] = following_set
          following_set.in_sets << item_set
        end
      end
    end

    # Build the reduce actions for each ItemSet.
    #
    # @return [void]
    def build_reduce_actions!
      @item_sets.each do |item_set|
        item_set.reduce_actions = build_reduce_actions_for_item_set(item_set)
      end
    end

    # Build the reduce actions for a single item set (parser state).
    #
    # @param item_set [ItemSet]
    #   ItemSet (parser state)
    #
    # @return [nil, Rule, Hash]
    #   If no reduce actions are possible for the given item set, nil.
    #   If only one reduce action is possible for the given item set, the Rule
    #   to reduce.
    #   Otherwise, a mapping of lookahead Tokens to the Rules to reduce.
    def build_reduce_actions_for_item_set(item_set)
      # To build the reduce actions, we start by looking at any
      # "complete" items, i.e., items where the parse position is at the
      # end of a rule. These are the only rules that are candidates for
      # reduction in the current ItemSet.
      reduce_rules = Set.new(item_set.items.select(&:complete?).map(&:rule))

      # If there are no rules to reduce for this ItemSet, we're done here.
      return nil if reduce_rules.size == 0

      # If there is exactly one rule to reduce for this ItemSet, then do not
      # figure out the lookaheads; just reduce it.
      return reduce_rules.first if reduce_rules.size == 1

      # Otherwise, we have more than one possible rule to reduce.

      # We will be looking for all possible tokens that can follow instances of
      # these rules. Rather than looking through the entire grammar for the
      # possible following tokens, we will only look in the item sets leading
      # up to this one. This restriction gives us a more precise lookahead set,
      # and allows us to parse LALR grammars.
      item_sets = item_set.leading_item_sets
      reduce_rules.reduce({}) do |reduce_actions, reduce_rule|
        lookahead_tokens_for_rule = build_lookahead_tokens_to_reduce(reduce_rule, item_sets)
        lookahead_tokens_for_rule.each do |lookahead_token|
          if existing_reduce_rule = reduce_actions[lookahead_token]
            raise Error.new("Error: reduce/reduce conflict between rule #{existing_reduce_rule.id} (#{existing_reduce_rule.name}) and rule #{reduce_rule.id} (#{reduce_rule.name})")
          end
          reduce_actions[lookahead_token] = reduce_rule
        end
        reduce_actions
      end
    end

    # Build the set of lookahead Tokens that should cause the given Rule to be
    # reduced in the given context of ItemSets.
    #
    # @param rule [Rule]
    #   Rule to reduce.
    # @param item_sets [Set<ItemSet>]
    #   ItemSets to consider for the context in which to reduce this Rule.
    #
    # @return [Set<Token>]
    #   Possible lookahead Tokens for the given Rule within the context of the
    #   given ItemSets.
    def build_lookahead_tokens_to_reduce(rule, item_sets)
      # We need to look for possible following tokens for this reduce rule. We
      # do this by looking for tokens that follow the reduce rule, or the
      # start token set for any other rule that follows the reduce rule.
      # While doing this, the following situations could arise:
      # 1. We may come across a following rule that could be empty. In this
      #    case, in addition to the start token set for that rule, we must also
      #    continue to the next following symbol after the potentially empty
      #    rule and continue the search for potential following tokens.
      # 2. We may reach the end of a rule that was not one of the original
      #    reduce rules. In this case, we must also search for all potential
      #    following tokens for this rule as well.
      lookahead_tokens = Set.new
      rule_sets_to_check_after = [rule.rule_set]
      checked_rule_sets = Set.new
      while !rule_sets_to_check_after.empty?
        rule_set = rule_sets_to_check_after.slice!(0)
        checked_rule_sets << rule_set
        # For each RuleSet we're checking, we're going to look through all
        # items in the item sets of interest and gather all possible following
        # tokens to form the lookahead token set.
        item_sets.each do |item_set|
          item_set.items.each do |item|
            if item.following_symbol == rule_set
              (1..).each do |offset|
                case symbol = item.following_symbol(offset)
                when nil
                  rule_set = item.rule.rule_set
                  unless checked_rule_sets.include?(rule_set)
                    rule_sets_to_check_after << rule_set
                  end
                  break
                when Token
                  lookahead_tokens << symbol
                  break
                when RuleSet
                  lookahead_tokens += symbol.start_token_set
                  unless symbol.could_be_empty?
                    break
                  end
                end
              end
            end
          end
        end
      end
      lookahead_tokens
    end

    def write_log!
      @log.puts Util.banner("Parser Rules")
      @grammar.rules.each do |rule|
        @log.puts
        @log.puts "Rule #{rule.id}:"
        @log.puts "  #{rule}"
      end

      @log.puts
      @log.puts Util.banner("Parser Tokens")
      @log.puts
      @grammar.tokens.each do |token|
        @log.puts "Token #{token.id}: #{token.name}"
      end

      @log.puts
      @log.puts Util.banner("Parser Rule Sets")
      @rule_sets.each do |rule_set_name, rule_set|
        @log.puts
        @log.puts "Rule Set #{rule_set.id}: #{rule_set_name}"
        @log.puts "  Start token set: #{rule_set.start_token_set.map(&:name).join(", ")}"
      end

      @log.puts
      @log.puts Util.banner("Parser States")
      @item_sets.each do |item_set|
        @log.puts
        @log.puts "State #{item_set.id}:"
        @log.puts item_set.to_s.gsub(/^/, "  ")
        incoming_ids = item_set.in_sets.map(&:id)
        @log.puts
        @log.puts "  Incoming states: #{incoming_ids.join(", ")}"
        @log.puts "  Outgoing states:"
        item_set.following_item_set.each do |following_symbol, following_item_set|
          @log.puts "    #{following_symbol.name} => #{following_item_set.id}"
        end
        @log.puts
        @log.puts "  Reduce actions:"
        case item_set.reduce_actions
        when Rule
          @log.puts "    * => rule #{item_set.reduce_actions.id}, rule set #{@rule_sets[item_set.reduce_actions.name].id} (#{item_set.reduce_actions.name})"
        when Hash
          item_set.reduce_actions.each do |token, rule|
            @log.puts "    lookahead #{token.name} => #{rule.name} (#{rule.id}), rule set ##{rule.rule_set.id}"
          end
        end
      end
    end

  end

end
