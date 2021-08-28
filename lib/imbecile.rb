require "erb"
require "set"
require_relative "imbecile/cli"
require_relative "imbecile/code_point_range"
require_relative "imbecile/fa"
require_relative "imbecile/fa/state"
require_relative "imbecile/fa/state/transition"
require_relative "imbecile/lexer"
require_relative "imbecile/lexer/dfa"
require_relative "imbecile/parser"
require_relative "imbecile/regex"
require_relative "imbecile/regex/nfa"
require_relative "imbecile/regex/unit"
require_relative "imbecile/rule"
require_relative "imbecile/token"
require_relative "imbecile/version"

class Imbecile

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
    @tokens = []
    @rules = []
    input = input.gsub("\r\n", "\n")
    while !input.empty?
      parse_grammar(input)
    end
  end

  def generate(output_file, log_file)
    expand_rules
    lexer = Lexer.new(@tokens)
    parser = Parser.new(@tokens, @rules)
    classname = @classname || File.basename(output_file).sub(%r{[^a-zA-Z0-9].*}, "").capitalize
    erb = ERB.new(File.read(File.join(File.dirname(File.expand_path(__FILE__)), "../assets/parser.d.erb")), nil, "<>")
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
      @tokens << Token.new(name, pattern, @tokens.size)
    elsif input.slice!(/\Adrop\s+(\S+)\n/)
      pattern = $1
      @tokens << Token.new(nil, pattern, @tokens.size)
    elsif input.slice!(/\A(\S+)\s*:\s*\[(.*?)\] <<\n(.*?)^>>\n/m)
      rule_name, rule, code = $1, $2, $3
      rule = rule.strip.split(/\s+/)
      @rules << Rule.new(rule_name, rule, code)
    else
      if input.size > 25
        input = input.slice(0..20) + "..."
      end
      raise Error.new("Unexpected grammar input: #{input}")
    end
  end

  def expand_rules
    token_names = @tokens.each_with_object({}) do |token, token_names|
      if token_names.include?(token.name)
        raise Error.new("Duplicate token name #{token.name}")
      end
      token_names[token.name] = token
    end
    rule_names = @rules.each_with_object({}) do |rule, rule_names|
      if token_names.include?(rule.name)
        raise Error.new("Rule name collides with token name #{rule.name}")
      end
      rule_names[rule.name] ||= []
      rule_names[rule.name] << rule
    end
    unless rule_names["Start"]
      raise Error.new("Start rule not found")
    end
    @rules.each do |rule|
      rule.components.map! do |component|
        if token_names[component]
          token_names[component]
        elsif rule_names[component]
          rule_names[component]
        else
          raise Error.new("Symbol #{component} not found")
        end
      end
    end
    new_rules = []
    begin
      @rules += new_rules
      new_rules = []
      @rules.delete_if do |rule|
        replaced = false
        rule.components.each_with_index do |component, index|
          if component.is_a?(Array)
            component.each do |new_component|
              new_components = rule.components[0, index] + [new_component] + rule.components[index + 1, rule.components.size]
              new_rules << Rule.new(rule.name, new_components, rule.code)
            end
            replaced = true
          end
        end
        replaced
      end
    end while new_rules.size > 0
  end

  class << self

    def run(input_file, output_file, log_file)
      begin
        imbecile = Imbecile.new(File.read(input_file))
        imbecile.generate(output_file, log_file)
      rescue Error => e
        $stderr.puts e.message
        return 2
      end
      return 0
    end

  end

end
