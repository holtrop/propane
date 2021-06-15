require "erb"
require "set"
require_relative "imbecile/cli"
require_relative "imbecile/code_point_range"
require_relative "imbecile/generator"
require_relative "imbecile/grammar"
require_relative "imbecile/grammar/rule"
require_relative "imbecile/grammar/token"
require_relative "imbecile/regex"
require_relative "imbecile/regex/fa"
require_relative "imbecile/regex/fa/state"
require_relative "imbecile/regex/fa/state/transition"
require_relative "imbecile/regex/nfa"
require_relative "imbecile/regex/unit"
require_relative "imbecile/lexer_dfa"
require_relative "imbecile/version"

module Imbecile

  class Error < RuntimeError
  end

  class << self

    def run(input_file, output_file)
      begin
        grammar = Grammar.new(File.read(input_file))
        generator = Generator.new(grammar)
        generator.generate(output_file)
      rescue Error => e
        $stderr.puts e.message
        return 2
      end
      return 0
    end

  end

end
