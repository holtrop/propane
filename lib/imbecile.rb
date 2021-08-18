require "erb"
require "set"
require_relative "imbecile/cli"
require_relative "imbecile/code_point_range"
require_relative "imbecile/fa"
require_relative "imbecile/fa/state"
require_relative "imbecile/fa/state/transition"
require_relative "imbecile/generator"
require_relative "imbecile/grammar"
require_relative "imbecile/grammar/rule"
require_relative "imbecile/grammar/token"
require_relative "imbecile/lexer"
require_relative "imbecile/lexer/dfa"
require_relative "imbecile/regex"
require_relative "imbecile/regex/nfa"
require_relative "imbecile/regex/unit"
require_relative "imbecile/version"

module Imbecile

  # EOF.
  TOKEN_EOF = 0xFFFFFFFC

  # Decoding error.
  TOKEN_DECODE_ERROR = 0xFFFFFFFD

  # Token ID for a "dropped" token.
  TOKEN_DROP = 0xFFFFFFFE

  # Invalid token ID.
  TOKEN_NONE = 0xFFFFFFFF

  class Error < RuntimeError
  end

  class << self

    def run(input_file, output_file, log_file)
      begin
        grammar = Grammar.new(File.read(input_file))
        generator = Generator.new(grammar, log_file)
        generator.generate(output_file)
      rescue Error => e
        $stderr.puts e.message
        return 2
      end
      return 0
    end

  end

end
