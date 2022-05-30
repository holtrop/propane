require "erb"
require "set"
require_relative "propane/cli"
require_relative "propane/code_point_range"
require_relative "propane/fa"
require_relative "propane/fa/state"
require_relative "propane/fa/state/transition"
require_relative "propane/lexer"
require_relative "propane/lexer/dfa"
require_relative "propane/parser"
require_relative "propane/parser/item"
require_relative "propane/parser/item_set"
require_relative "propane/regex"
require_relative "propane/regex/nfa"
require_relative "propane/regex/unit"
require_relative "propane/rule_set"
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
    @tokens = {}
    @rule_sets = {}
    input = input.gsub("\r\n", "\n")
    while !input.empty?
      parse_grammar(input)
    end
  end

  def generate(output_file, log_file)
    expand_rules
    lexer = Lexer.new(@tokens)
    parser = Parser.new(@tokens, @rule_sets)
    classname = @classname || File.basename(output_file).sub(%r{[^a-zA-Z0-9].*}, "").capitalize
    erb = ERB.new(File.read(File.join(File.dirname(File.expand_path(__FILE__)), "../assets/parser.d.erb")), trim_mode: "<>")
    result = erb.result(binding.clone)
    File.open(output_file, "wb") do |fh|
      fh.write(result)
    end
  end

  private

  def parse_grammar(input)
    if input.slice!(/\A\s+/)
      # Skip white space.
    elsif input.slice!(/\A#.*\n/)
      # Skip comment lines.
    elsif input.slice!(/\Amodule\s+(\S+)\n/)
      @modulename = $1
    elsif input.slice!(/\Aclass\s+(\S+)\n/)
      @classname = $1
    elsif input.slice!(/\Atoken\s+(\S+)(?:\s+(\S+))?\n/)
      name, pattern = $1, $2
      if pattern.nil?
        pattern = name
      end
      unless name =~ /^[a-zA-Z_][a-zA-Z_0-9]*$/
        raise Error.new("Invalid token name #{name}")
      end
      if @tokens[name]
        raise Error.new("Duplicate token name #{name}")
      else
        @tokens[name] = Token.new(name, pattern, @tokens.size)
      end
    elsif input.slice!(/\Adrop\s+(\S+)\n/)
      pattern = $1
      @tokens[name] = Token.new(nil, pattern, @tokens.size)
    elsif input.slice!(/\A(\S+)\s*:\s*\[(.*?)\] <<\n(.*?)^>>\n/m)
      rule_name, components, code = $1, $2, $3
      components = components.strip.split(/\s+/)
      @rule_sets[rule_name] ||= RuleSet.new(rule_name, @rule_sets.size)
      @rule_sets[rule_name].add_pattern(components, code)
    else
      if input.size > 25
        input = input.slice(0..20) + "..."
      end
      raise Error.new("Unexpected grammar input: #{input}")
    end
  end

  def expand_rules
    @rule_sets.each do |rule_name, rule_set|
      if @tokens.include?(rule_name)
        raise Error.new("Rule name collides with token name #{rule_name}")
      end
    end
    unless @rule_sets["Start"]
      raise Error.new("Start rule not found")
    end
    @rule_sets.each do |rule_name, rule_set|
      rule_set.patterns.each do |rule|
        rule.components.map! do |component|
          if @tokens[component]
            @tokens[component]
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
