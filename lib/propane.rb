require "erb"
require "set"
require_relative "propane/cli"
require_relative "propane/code_point_range"
require_relative "propane/fa"
require_relative "propane/fa/state"
require_relative "propane/fa/state/transition"
require_relative "propane/grammar"
require_relative "propane/lexer"
require_relative "propane/lexer/dfa"
require_relative "propane/parser"
require_relative "propane/parser/item"
require_relative "propane/parser/item_set"
require_relative "propane/regex"
require_relative "propane/regex/nfa"
require_relative "propane/regex/unit"
require_relative "propane/rule_set"
require_relative "propane/rule"
require_relative "propane/token"
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

  def initialize(input)
    @grammar = Grammar.new(input)
    @classname = @grammar.classname
    @modulename = @grammar.modulename
    @rule_sets = @grammar.rule_sets
  end

  def generate(output_file, log_file)
    expand_rules
    lexer = Lexer.new(@grammar.tokens, @grammar.drop_tokens)
    parser = Parser.new(@rule_sets)
    classname = @classname || File.basename(output_file).sub(%r{[^a-zA-Z0-9].*}, "").capitalize
    erb = ERB.new(File.read(File.join(File.dirname(File.expand_path(__FILE__)), "../assets/parser.d.erb")), trim_mode: "<>")
    result = erb.result(binding.clone)
    File.open(output_file, "wb") do |fh|
      fh.write(result)
    end
  end

  private

  def expand_rules
    tokens_by_name = {}
    @grammar.tokens.each do |token|
      if tokens_by_name.include?(token.name)
        raise Error.new("Duplicate token name #{token.name.inspect}")
      end
      tokens_by_name[token.name] = token
    end
    @rule_sets.each do |rule_name, rule_set|
      if tokens_by_name.include?(rule_name)
        raise Error.new("Rule name collides with token name #{rule_name.inspect}")
      end
    end
    unless @rule_sets["Start"]
      raise Error.new("Start rule not found")
    end
    @rule_sets.each do |rule_name, rule_set|
      rule_set.rules.each do |rule|
        rule.components.map! do |component|
          if tokens_by_name[component]
            tokens_by_name[component]
          elsif @rule_sets[component]
            @rule_sets[component]
          else
            raise Error.new("Symbol #{component} not found")
          end
        end
      end
    end
  end

  class << self

    def run(input_file, output_file, log_file)
      begin
        propane = Propane.new(File.read(input_file))
        propane.generate(output_file, log_file)
      rescue Error => e
        $stderr.puts e.message
        return 2
      end
      return 0
    end

  end

end
