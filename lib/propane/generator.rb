class Propane

  class Generator

    def initialize(grammar, output_file, log_file)
      @grammar = grammar
      @output_file = output_file
      if log_file
        @log = File.open(log_file, "wb")
      else
        @log = StringIO.new
      end
      @classname = @grammar.classname || File.basename(output_file).sub(%r{[^a-zA-Z0-9].*}, "").capitalize
      process_grammar!
    end

    def generate
      erb = ERB.new(File.read(File.join(File.dirname(File.expand_path(__FILE__)), "../../assets/parser.d.erb")), trim_mode: "<>")
      result = erb.result(binding.clone)
      File.open(@output_file, "wb") do |fh|
        fh.write(result)
      end
      @log.close
    end

    private

    def process_grammar!
      tokens_by_name = {}
      @grammar.tokens.each do |token|
        # Check for token name conflicts.
        if tokens_by_name.include?(token.name)
          raise Error.new("Duplicate token name #{token.name.inspect}")
        end
        tokens_by_name[token.name] = token
      end
      rule_sets = {}
      @grammar.rules.each do |rule|
        # Check for token/rule name conflict.
        if tokens_by_name.include?(rule.name)
          raise Error.new("Rule name collides with token name #{rule.name.inspect}")
        end
        # Build rule sets of all rules with the same name.
        @_rule_set_id ||= @grammar.tokens.size
        unless rule_sets[rule.name]
          rule_sets[rule.name] = RuleSet.new(rule.name, @_rule_set_id)
          @_rule_set_id += 1
        end
        rule.rule_set = rule_sets[rule.name]
        rule_sets[rule.name] << rule
      end
      # Check for start rule.
      unless rule_sets["Start"]
        raise Error.new("Start rule not found")
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
      # Generate the lexer.
      @lexer = Lexer.new(@grammar.patterns)
      # Generate the parser.
      @parser = Parser.new(@grammar, rule_sets, rule_sets["Start"], @log)
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

  end

end
