module Imbecile
  class Grammar

    # @return [String, nil]
    #   Module name.
    attr_reader :modulename

    # @return [String, nil]
    #   Class name.
    attr_reader :classname

    # @return [Array<Token>]
    #   Tokens.
    attr_reader :tokens

    def initialize(input)
      @tokens = []
      @rules = []
      input = input.gsub("\r\n", "\n")
      while !input.empty?
        consume(input)
      end
    end

    private

    def consume(input)
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
      elsif input.slice!(/\Arule\s+(\S+)\s+\[(.*?)\] <<\n(.*?)^>>\n/m)
        rule_name, rule, code = $1, $2, $3
        @rules << Rule.new(rule_name, rule, code)
      else
        if input.size > 25
          input = input.slice(0..20) + "..."
        end
        raise Error.new("Unexpected grammar input: #{input}")
      end
    end

  end
end
