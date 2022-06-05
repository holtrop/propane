class Propane

  class Generator

    def initialize(grammar, output_file, log_file)
      @grammar = grammar
      @output_file = output_file
      @log_file = log_file
      @classname = @grammar.classname || File.basename(output_file).sub(%r{[^a-zA-Z0-9].*}, "").capitalize
      process_grammar!
      @lexer = Lexer.new(@grammar.tokens, @grammar.drop_tokens)
      @parser = Parser.new(@grammar.rule_sets)
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
      @grammar.rule_sets.each do |rule_name, rule_set|
        if tokens_by_name.include?(rule_name)
          raise Error.new("Rule name collides with token name #{rule_name.inspect}")
        end
      end
      unless @grammar.rule_sets["Start"]
        raise Error.new("Start rule not found")
      end
      @grammar.rule_sets.each do |rule_name, rule_set|
        rule_set.rules.each do |rule|
          rule.components.map! do |component|
            if tokens_by_name[component]
              tokens_by_name[component]
            elsif @grammar.rule_sets[component]
              @grammar.rule_sets[component]
            else
              raise Error.new("Symbol #{component} not found")
            end
          end
        end
      end
    end

  end

end
