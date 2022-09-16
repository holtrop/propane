require "erb"
require "set"
require "stringio"
require_relative "propane/cli"
require_relative "propane/code_point_range"
require_relative "propane/fa"
require_relative "propane/fa/state"
require_relative "propane/fa/state/transition"
require_relative "propane/generator"
require_relative "propane/grammar"
require_relative "propane/lexer"
require_relative "propane/lexer/dfa"
require_relative "propane/parser"
require_relative "propane/parser/item"
require_relative "propane/parser/item_set"
require_relative "propane/pattern"
require_relative "propane/regex"
require_relative "propane/regex/nfa"
require_relative "propane/regex/unit"
require_relative "propane/rule_set"
require_relative "propane/rule"
require_relative "propane/token"
require_relative "propane/util"
require_relative "propane/version"

class Propane

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
        generator = Generator.new(grammar, output_file, log_file)
        generator.generate
      rescue Error => e
        $stderr.puts e.message
        return 2
      end
      return 0
    end

  end

end
