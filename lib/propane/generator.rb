class Propane

  class Generator

    def initialize(grammar, output_file, log_file)
      @grammar = grammar
      @output_file = output_file
      @log_file = log_file
      @classname = @grammar.classname || File.basename(output_file).sub(%r{[^a-zA-Z0-9].*}, "").capitalize
      process_grammar!
    end

    def generate
      erb = ERB.new(File.read(File.join(File.dirname(File.expand_path(__FILE__)), "../../assets/parser.d.erb")), trim_mode: "<>")
      result = erb.result(binding.clone)
      File.open(@output_file, "wb") do |fh|
        fh.write(result)
      end
    end

    private

    def process_grammar!
      tokens_by_name = {}
      @grammar.tokens.each do |token|
        if tokens_by_name.include?(token.name)
          raise Error.new("Duplicate token name #{token.name.inspect}")
        end
        tokens_by_name[token.name] = token
      end
      rule_sets = {}
      @grammar.rules.each do |rule|
        if tokens_by_name.include?(rule.name)
          raise Error.new("Rule name collides with token name #{rule.name.inspect}")
        end
        rule_sets[rule.name] ||= RuleSet.new(rule.name)
        rule_sets[rule.name] << rule
      end
      unless rule_sets["Start"]
        raise Error.new("Start rule not found")
      end
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
      @lexer = Lexer.new(@grammar.tokens, @grammar.drop_tokens)
      @parser = Parser.new(rule_sets["Start"])
    end

  end

end
