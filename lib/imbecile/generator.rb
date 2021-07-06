module Imbecile

  # Class to generate the parser generator source.
  class Generator

    def initialize(grammar, log_file)
      @grammar = grammar
      @log_file = log_file
    end

    def generate(output_file)
      token_names = @grammar.tokens.each_with_object({}) do |token, token_names|
        if token_names.include?(token.name)
          raise Error.new("Duplicate token name #{token.name}")
        end
        token_names[token.name] = token
      end
      rule_names = @grammar.rules.each_with_object({}) do |rule, rule_names|
        if token_names.include?(rule.name)
          raise Error.new("Rule name collides with token name #{rule.name}")
        end
        rule_names[rule.name] ||= []
        rule_names[rule.name] << rule
      end
      unless rule_names["Start"]
        raise Error.new("Start rule not found")
      end
      lexer_dfa = LexerDFA.new(@grammar.tokens)
      classname = @grammar.classname || File.basename(output_file).sub(%r{[^a-zA-Z0-9].*}, "").capitalize
      erb = ERB.new(File.read(File.join(File.dirname(File.expand_path(__FILE__)), "../../assets/parser.d.erb")), nil, "<>")
      result = erb.result(binding.clone)
      File.open(output_file, "wb") do |fh|
        fh.write(result)
      end
    end

  end

end
