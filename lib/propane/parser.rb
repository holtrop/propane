class Propane

  class Parser

    attr_reader :state_table
    attr_reader :shift_table
    attr_reader :reduce_table
    attr_reader :rule_sets

    def initialize(grammar, rule_sets, log, options)
      @grammar = grammar
      @rule_sets = rule_sets
      @log = log
      @item_sets = []
      @item_sets_set = {}
      @warnings = Set.new
      @errors = Set.new
      @options = options
      start_item = Item.new(grammar.rules.first, 0)
      eval_item_sets = Set[ItemSet.new([start_item])]

      while eval_item_sets.size > 0
        item_set = eval_item_sets.first
        eval_item_sets.delete(item_set)
        unless @item_sets_set.include?(item_set)
          item_set.id = @item_sets.size
          @item_sets << item_set
          @item_sets_set[item_set] = item_set
          item_set.next_symbols.each do |next_symbol|
            unless next_symbol.name == "$EOF"
              next_item_set = item_set.build_next_item_set(next_symbol)
              eval_item_sets << next_item_set
            end
          end
        end
      end

      @item_sets.each do |item_set|
        process_item_set(item_set)
      end

      build_reduce_actions!
      build_tables!
      write_log!
      errormessage = ""
      if @errors.size > 0
        errormessage += @errors.join("\n")
      end
      if @warnings.size > 0 && @options[:warnings_as_errors]
        if errormessage != ""
          errormessage += "\n"
        end
        errormessage += "Fatal errors (-w):\n" + @warnings.join("\n")
      end
      if errormessage != ""
        raise Error.new(errormessage)
      end
    end

    private

    def build_tables!
      @state_table = []
      @shift_table = []
      @reduce_table = []
      @item_sets.each do |item_set|
        unless item_set.reduce_rules.empty?
          item_set.shift_entries.each do |shift_entry|
            token = shift_entry[:symbol]
            if item_set.reduce_actions
              if rule = item_set.reduce_actions[token]
                @warnings << "Shift/Reduce conflict (state #{item_set.id}) between token #{token.name} and rule #{rule.name} (defined on line #{rule.line_number})"
              end
            end
          end
        end
        reduce_entries =
          if rule = item_set.reduce_rule
            [{token_id: @grammar.invalid_token_id, rule_id: rule.id, rule: rule,
              rule_set_id: rule.rule_set.id, n_states: rule.components.size,
              propagate_optional_target: rule.optional? && rule.components.size == 1}]
          elsif reduce_actions = item_set.reduce_actions
            reduce_actions.map do |token, rule|
              {token: token, token_id: token.id, rule_id: rule.id, rule: rule,
               rule_set_id: rule.rule_set.id, n_states: rule.components.size,
               propagate_optional_target: rule.optional? && rule.components.size == 1}
            end
          else
            []
          end
        @state_table << {
          shift_index: @shift_table.size,
          n_shifts: item_set.shift_entries.size,
          reduce_index: @reduce_table.size,
          n_reduces: reduce_entries.size,
        }
        @shift_table += item_set.shift_entries
        @reduce_table += reduce_entries
      end
    end

    def process_item_set(item_set)
      item_set.next_symbols.each do |next_symbol|
        unless next_symbol.name == "$EOF"
          next_item_set = @item_sets_set[item_set.build_next_item_set(next_symbol)]
          item_set.next_item_set[next_symbol] = next_item_set
          next_item_set.in_sets << item_set
        end
      end
    end

    # Build the reduce actions for each ItemSet.
    #
    # @return [void]
    def build_reduce_actions!
      @item_sets.each do |item_set|
        build_shift_entries(item_set)
        build_reduce_actions_for_item_set(item_set)
      end
      item_sets_to_process = @item_sets.select do |item_set|
        # We need lookahead reduce actions if:
        # 1) There is more than one possible rule to reduce. In this case the
        #    lookahead token can help choose which rule to reduce.
        # 2) There is at least one shift action and one reduce action for
        #    this item set. In this case the lookahead reduce actions are
        #    needed to test for a Shift/Reduce conflict.
        item_set.reduce_rules.size > 1 ||
          (item_set.reduce_rules.size > 0 && item_set.shift_entries.size > 0)
      end
      if RbConfig::CONFIG["host_os"] =~ /linux/
        item_sets_by_id = {}
        item_sets_to_process.each do |item_set|
          item_sets_by_id[item_set.object_id] = item_set
        end
        tokens_by_id = {}
        @grammar.tokens.each do |token|
          tokens_by_id[token.object_id] = token
        end
        rules_by_id = {}
        @grammar.rules.each do |rule|
          rules_by_id[rule.object_id] = rule
        end
        n_threads = Util.determine_n_threads
        semaphore = Mutex.new
        queue = Queue.new
        threads = {}
        n_threads.times do
          piper, pipew = IO.pipe
          thread = Thread.new do
            loop do
              item_set = nil
              semaphore.synchronize do
                item_set = item_sets_to_process.slice!(0)
              end
              break if item_set.nil?
              fork do
                piper.close
                build_lookahead_reduce_actions_for_item_set(item_set, pipew)
              end
            end
            queue.push(Thread.current)
          end
          threads[thread] = [piper, pipew]
        end
        until threads.empty?
          thread = queue.pop
          piper, pipew = threads[thread]
          pipew.close
          thread_txt = piper.read
          thread_txt.each_line do |line|
            if line.start_with?("RA,")
              parts = line.split(",")
              item_set_id, token_id, rule_id = parts[1..3].map(&:to_i)
              item_set = item_sets_by_id[item_set_id]
              unless item_set
                raise "Internal error: could not find item set from thread"
              end
              token = tokens_by_id[token_id]
              unless item_set
                raise "Internal error: could not find token from thread"
              end
              rule = rules_by_id[rule_id]
              unless item_set
                raise "Internal error: could not find rule from thread"
              end
              item_set.reduce_actions ||= {}
              item_set.reduce_actions[token] = rule
            elsif line.start_with?("Error: ")
              @errors << line.chomp
            else
              raise "Internal error: unhandled thread line #{line}"
            end
          end
          thread.join
          threads.delete(thread)
        end
      else
        # Fall back to single threaded algorithm.
        item_sets_to_process.each do |item_set|
          item_set.reduce_actions = build_lookahead_reduce_actions_for_item_set(item_set)
        end
      end
    end

    # Build the shift entries for a single item set.
    #
    # @return [void]
    def build_shift_entries(item_set)
      item_set.shift_entries = item_set.next_symbols.map do |next_symbol|
        state_id =
          if next_symbol.name == "$EOF"
            0
          else
            item_set.next_item_set[next_symbol].id
          end
        {
          symbol: next_symbol,
          state_id: state_id,
        }
      end
    end

    # Build the reduce actions for a single item set (parser state).
    #
    # @param item_set [ItemSet]
    #   ItemSet (parser state)
    #
    # @return [void]
    def build_reduce_actions_for_item_set(item_set)
      # To build the reduce actions, we start by looking at any
      # "complete" items, i.e., items where the parse position is at the
      # end of a rule. These are the only rules that are candidates for
      # reduction in the current ItemSet.
      item_set.reduce_rules = Set.new(item_set.items.select(&:complete?).map(&:rule))

      if item_set.reduce_rules.size == 1
        item_set.reduce_rule = item_set.reduce_rules.first
      end
    end

    # Build the reduce actions for a single item set (parser state).
    #
    # @param item_set [ItemSet]
    #   ItemSet (parser state)
    # @param fh [File]
    #   Output file handle for multiprocessing mode.
    #
    # @return [Hash]
    #   Mapping of lookahead Tokens to the Rules to reduce.
    def build_lookahead_reduce_actions_for_item_set(item_set, fh = nil)
      # We will be looking for all possible tokens that can follow instances of
      # these rules. Rather than looking through the entire grammar for the
      # possible following tokens, we will only look in the item sets leading
      # up to this one. This restriction gives us a more precise lookahead set,
      # and allows us to parse LALR grammars.
      item_sets = Set[item_set] + item_set.leading_item_sets
      item_set.reduce_rules.reduce({}) do |reduce_actions, reduce_rule|
        lookahead_tokens_for_rule = build_lookahead_tokens_to_reduce(reduce_rule, item_sets)
        lookahead_tokens_for_rule.each do |lookahead_token|
          if existing_reduce_rule = reduce_actions[lookahead_token]
            error = "Error: reduce/reduce conflict (state #{item_set.id}) between rule #{existing_reduce_rule.name}##{existing_reduce_rule.id} (defined on line #{existing_reduce_rule.line_number}) and rule #{reduce_rule.name}##{reduce_rule.id} (defined on line #{reduce_rule.line_number}) for lookahead token #{lookahead_token}"
            @errors << error
            fh.puts(error) if fh
          end
          reduce_actions[lookahead_token] = reduce_rule
          fh.puts "RA,#{item_set.object_id},#{lookahead_token.object_id},#{reduce_rule.object_id}" if fh
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
            if item.next_symbol == rule_set
              (1..).each do |offset|
                case symbol = item.next_symbol(offset)
                when nil
                  rule_set = item.rule.rule_set
                  unless checked_rule_sets.include?(rule_set)
                    rule_sets_to_check_after << rule_set
                    checked_rule_sets << rule_set
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
        item_set.next_item_set.each do |next_symbol, next_item_set|
          @log.puts "    #{next_symbol.name} => #{next_item_set.id}"
        end
        @log.puts
        @log.puts "  Reduce actions:"
        if item_set.reduce_rule
          @log.puts "    * => rule #{item_set.reduce_rule.id}, rule set #{@rule_sets[item_set.reduce_rule.name].id} (#{item_set.reduce_rule.name})"
        elsif item_set.reduce_actions
          item_set.reduce_actions.each do |token, rule|
            @log.puts "    lookahead #{token.name} => #{rule.name} (#{rule.id}), rule set ##{rule.rule_set.id}"
          end
        end
      end
      if @warnings.size > 0
        @log.puts
        @log.puts "Warnings:"
        @warnings.each do |warning|
          @log.puts "  #{warning}"
        end
      end
    end

  end

end
