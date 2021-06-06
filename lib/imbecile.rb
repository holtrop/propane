require "erb"
require "set"
require_relative "imbecile/cli"
require_relative "imbecile/code_point_range"
require_relative "imbecile/grammar"
require_relative "imbecile/grammar/token"
require_relative "imbecile/regex"
require_relative "imbecile/regex/fa"
require_relative "imbecile/regex/fa/state"
require_relative "imbecile/regex/fa/state/transition"
require_relative "imbecile/regex/nfa"
require_relative "imbecile/regex/unit"
require_relative "imbecile/token_dfa"
require_relative "imbecile/version"

module Imbecile

  class Error < RuntimeError
  end

  class << self

    def run(input_file, output_file)
      begin
        grammar = Grammar.new(File.read(input_file))
        # Build NFA from each token expression.
        grammar.tokens.each do |token|
          puts token.nfa
        end
        token_dfa = TokenDFA.new(grammar.tokens)
        puts token_dfa
      rescue Error => e
        $stderr.puts e.message
        return 2
      end
      classname = grammar.classname || output_file.sub(%r{[^a-zA-Z0-9].*}, "").capitalize
      erb = ERB.new(File.read(File.join(File.dirname(File.expand_path(__FILE__)), "../assets/parser.d.erb")), nil, "<>")
      result = erb.result(binding.clone)
      File.open(output_file, "wb") do |fh|
        fh.write(result)
      end
      return 0
    end

  end

end
