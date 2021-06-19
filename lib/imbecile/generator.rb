module Imbecile

  # Class to generate the parser generator source.
  class Generator

    def initialize(grammar, log_file)
      @grammar = grammar
      @log_file = log_file
    end

    def generate(output_file)
      lexer_dfa = LexerDFA.new(@grammar.tokens)
      classname = @grammar.classname || output_file.sub(%r{[^a-zA-Z0-9].*}, "").capitalize
      erb = ERB.new(File.read(File.join(File.dirname(File.expand_path(__FILE__)), "../../assets/parser.d.erb")), nil, "<>")
      result = erb.result(binding.clone)
      File.open(output_file, "wb") do |fh|
        fh.write(result)
      end
    end

  end

end
