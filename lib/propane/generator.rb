class Propane

  class Generator

    def initialize(grammar, output_file, log_file, options)
      @grammar = grammar
      @output_file = output_file
      if log_file
        @log = File.open(log_file, "wb")
      else
        @log = StringIO.new
      end
      @language =
        if output_file =~ /\.([a-z]+)$/
          $1
        else
          "d"
        end
      @options = options
      process_grammar!
    end

    def generate
      extensions = [@language]
      if @language == "c"
        extensions += %w[h]
      end
      extensions.each do |extension|
        template = Assets.get("parser.#{extension}.erb")
        erb = ERB.new(template, trim_mode: "<>")
        output_file = @output_file.sub(%r{\.[a-z]+$}, ".#{extension}")
        result = erb.result(binding.clone)
        File.open(output_file, "wb") do |fh|
          fh.write(result)
        end
      end
      @log.close
    end

    private

    def process_grammar!
      # Assign default pattern mode to patterns without a mode assigned.
      found_default = false
      @grammar.patterns.each do |pattern|
        if pattern.modes.empty?
          pattern.modes << "default"
          found_default = true
        end
        pattern.ptypename ||= "default"
      end
      unless found_default
        raise Error.new("No patterns found for default mode")
      end
      check_ptypes!
      # Add EOF token.
      @grammar.tokens << Token.new("$EOF", nil, nil)
      tokens_by_name = {}
      @grammar.tokens.each_with_index do |token, token_id|
        # Assign token ID.
        token.id = token_id
        # Set default ptypename if none given.
        token.ptypename ||= "default"
        # Check for token name conflicts.
        if tokens_by_name.include?(token.name)
          raise Error.new("Duplicate token name #{token.name.inspect}")
        end
        tokens_by_name[token.name] = token
      end
      # Check for user start rule.
      unless @grammar.rules.find {|rule| rule.name == @grammar.start_rule}
        raise Error.new("Start rule `#{@grammar.start_rule}` not found")
      end
      # Add "real" start rule.
      @grammar.rules.unshift(Rule.new("$Start", [@grammar.start_rule, "$EOF"], nil, nil, nil))
      # Generate and add rules for optional components.
      generate_optional_component_rules!(tokens_by_name)
      # Build rule sets.
      rule_sets = {}
      rule_set_id = @grammar.tokens.size
      @grammar.rules.each_with_index do |rule, rule_id|
        # Assign rule ID.
        rule.id = rule_id
        # Check for token/rule name conflict.
        if tokens_by_name.include?(rule.name)
          raise Error.new("Rule name collides with token name #{rule.name.inspect}")
        end
        # Build rule sets of all rules with the same name.
        unless rule_sets[rule.name]
          rule_sets[rule.name] = RuleSet.new(rule.name, rule_set_id)
          rule_set_id += 1
        end
        rule_set = rule_sets[rule.name]
        if rule_set.ptypename && rule.ptypename && rule_set.ptypename != rule.ptypename
          raise Error.new("Conflicting ptypes for rule #{rule.name}")
        end
        rule_set.ptypename ||= rule.ptypename
        rule.rule_set = rule_set
        rule_set << rule
      end
      rule_sets.each do |name, rule_set|
        rule_set.ptypename ||= "default"
        # Assign rule set ptypenames back to rules.
        rule_set.rules.each do |rule|
          rule.ptypename = rule_set.ptypename
        end
      end
      # Generate lexer user code IDs for lexer patterns with user code blocks.
      @grammar.patterns.select do |pattern|
        pattern.code
      end.each_with_index do |pattern, code_id|
        pattern.code_id = code_id
      end
      # Map rule components from names to Token/RuleSet objects.
      @grammar.rules.each do |rule|
        rule.components.map! do |component|
          if tokens_by_name[component]
            tokens_by_name[component]
          elsif rule_sets[component]
            rule_sets[component]
          else
            raise Error.new("Symbol #{component} not found")
          end
        end
      end
      determine_possibly_empty_rulesets!(rule_sets)
      rule_sets.each do |name, rule_set|
        rule_set.finalize(@grammar)
      end
      # Generate the lexer.
      @lexer = Lexer.new(@grammar)
      # Generate the parser.
      @parser = Parser.new(@grammar, rule_sets, @log, @options)
    end

    # Check that any referenced ptypes have been defined.
    def check_ptypes!
      (@grammar.patterns + @grammar.tokens + @grammar.rules).each do |potor|
        if potor.ptypename
          unless @grammar.ptypes.include?(potor.ptypename)
            raise Error.new("Error: Line #{potor.line_number}: ptype #{potor.ptypename} not declared. Declare with `ptype` statement.")
          end
        end
      end
    end

    # Generate and add rules for any optional components.
    def generate_optional_component_rules!(tokens_by_name)
      optional_rules_added = Set.new
      @grammar.rules.each do |rule|
        rule.components.each do |component|
          if component =~ /^(.*)\?$/
            c = $1
            unless optional_rules_added.include?(component)
              # Create two rules for the optional component: one empty and
              # one just matching the component.
              # We need to find the ptypename for the optional component in
              # order to copy it to the generated rules.
              if tokens_by_name[c]
                # The optional component is a token.
                ptypename = tokens_by_name[c].ptypename
              else
                # The optional component must be a rule, so find any instance
                # of that rule that specifies a ptypename.
                ptypename = @grammar.rules.reduce(nil) do |result, rule|
                  rule.name == c && rule.ptypename ? rule.ptypename : result
                end
              end
              @grammar.rules << Rule.new(component, [], nil, ptypename, rule.line_number)
              @grammar.rules << Rule.new(component, [c], "$$ = $1;\n", ptypename, rule.line_number)
              optional_rules_added << component
            end
          end
        end
      end
    end

    # Determine which grammar rules could expand to empty sequences.
    #
    # @param rule_sets [Hash]
    #   RuleSets.
    #
    # @return [void]
    def determine_possibly_empty_rulesets!(rule_sets)
      begin
        newly_discovered_empty_rulesets = false
        rule_sets.each do |name, rule_set|
          unless rule_set.could_be_empty?
            if could_rule_set_be_empty?(rule_set)
              newly_discovered_empty_rulesets = true
              rule_set.could_be_empty = true
            end
          end
        end
      end while newly_discovered_empty_rulesets
    end

    # Determine whether a RuleSet could be empty.
    #
    # @param rule_set [RuleSet]
    #   RuleSet to test.
    #
    # @return [Boolean]
    #   Whether the RuleSet could be empty.
    def could_rule_set_be_empty?(rule_set)
      rule_set.rules.any? do |rule|
        could_rule_be_empty?(rule)
      end
    end

    # Determine whether a Rule could be empty.
    #
    # @param rule [Rule]
    #   Rule to test.
    #
    # @return [Boolean]
    #   Whether the Rule could be empty.
    def could_rule_be_empty?(rule)
      i = 0
      loop do
        if i == rule.components.size
          return true
        end
        if rule.components[i].is_a?(Token)
          return false
        end
        if !rule.components[i].could_be_empty?
          return false
        end
        i += 1
      end
    end

    # Expand expansions in user code block.
    #
    # @param code [String]
    #   User code block.
    # @param parser [Boolean]
    #   Whether the user code is for the parser or lexer.
    # @param rule [Rule, nil]
    #   The Rule associated with the user code if user code is for the parser.
    # @param pattern [Pattern, nil]
    #   The Pattern associated with the user code if user code is for the lexer.
    #
    # @return [String]
    #   Expanded user code block.
    def expand_code(code, parser, rule, pattern)
      code = code.gsub(/\$token\(([$\w]+)\)/) do |match|
        "TOKEN_#{Token.code_name($1)}"
      end
      code = code.gsub(/\$terminate\((.*)\);/) do |match|
        user_terminate_code = $1
        retval = rule ? "P_USER_TERMINATED" : "TERMINATE_TOKEN_ID"
        case @language
        when "c"
          "context->user_terminate_code = (#{user_terminate_code}); return #{retval};"
        when "d"
          "context.user_terminate_code = (#{user_terminate_code}); return #{retval};"
        end
      end
      if parser
        code = code.gsub(/\$\$/) do |match|
          case @language
          when "c"
            "_pvalue->v_#{rule.ptypename}"
          when "d"
            "_pvalue.v_#{rule.ptypename}"
          end
        end
        code = code.gsub(/\$(\d+)/) do |match|
          index = $1.to_i
          case @language
          when "c"
            "state_values_stack_index(statevalues, -1 - (int)n_states + #{index})->pvalue.v_#{rule.components[index - 1].ptypename}"
          when "d"
            "statevalues[$-1-n_states+#{index}].pvalue.v_#{rule.components[index - 1].ptypename}"
          end
        end
        code = code.gsub(/\$\{(\w+)\}/) do |match|
          aliasname = $1
          if index = rule.aliases[aliasname]
            case @language
            when "c"
              "state_values_stack_index(statevalues, -(int)n_states + #{index})->pvalue.v_#{rule.components[index].ptypename}"
            when "d"
              "statevalues[$-n_states+#{index}].pvalue.v_#{rule.components[index].ptypename}"
            end
          else
            raise Error.new("Field alias '#{aliasname}' not found")
          end
        end
      else
        code = code.gsub(/\$\$/) do |match|
          if @grammar.ast
            case @language
            when "c"
              "out_token_info->pvalue"
            when "d"
              "out_token_info.pvalue"
            end
          else
            case @language
            when "c"
              "out_token_info->pvalue.v_#{pattern.ptypename}"
            when "d"
              "out_token_info.pvalue.v_#{pattern.ptypename}"
            end
          end
        end
        code = code.gsub(/\$mode\(([a-zA-Z_][a-zA-Z_0-9]*)\)/) do |match|
          mode_name = $1
          mode_id = @lexer.mode_id(mode_name)
          unless mode_id
            raise Error.new("Lexer mode '#{mode_name}' not found")
          end
          case @language
          when "c"
            "context->mode = #{mode_id}u"
          when "d"
            "context.mode = #{mode_id}u"
          end
        end
      end
      code
    end

    # Get the parser value type for the start rule.
    #
    # @return [Array<String>]
    #   Start rule parser value type name and type string.
    def start_rule_type
      start_rule = @grammar.rules.find do |rule|
        rule.name == @grammar.start_rule
      end
      [start_rule.ptypename, @grammar.ptypes[start_rule.ptypename]]
    end

    # Get an unsigned integer type that can hold the given maximum value.
    #
    # @param max [Integer]
    #   Maximum value to store.
    #
    # @return [String]
    #   Type.
    def get_type_for(max)
      if max <= 0xFF
        case @language
        when "c"
          "uint8_t"
        when "d"
          "ubyte"
        end
      elsif max <= 0xFFFF
        case @language
        when "c"
          "uint16_t"
        when "d"
          "ushort"
        end
      else
        case @language
        when "c"
          "uint32_t"
        else
          "uint"
        end
      end
    end

  end

end
