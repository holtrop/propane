class Propane

  class Grammar

    attr_reader :classname
    attr_reader :modulename
    attr_reader :patterns
    attr_reader :rules
    attr_reader :tokens

    def initialize(input)
      @patterns = []
      @tokens = []
      @rules = []
      input = input.gsub("\r\n", "\n")
      parse_grammar(input)
    end

    private

    def parse_grammar(input)
      line_number = 1
      while !input.empty?
        if sliced = input.slice!(/\A\s+/)
          # Skip white space.
        elsif sliced = input.slice!(/\A#.*\n/)
          # Skip comment lines.
        elsif sliced = input.slice!(/\Amodule\s+(\S+)\s*;/)
          @modulename = $1
        elsif sliced = input.slice!(/\Aclass\s+(\S+)\s*;/)
          @classname = $1
        elsif sliced = input.slice!(/\Atoken\s+(\S+?)(?:\s+(.+?))?\s*(?:;|<<\n(.*?)^>>\n)/m)
          name, pattern, code = $1, $2, $3
          if pattern.nil?
            pattern = name
          end
          unless name =~ /^[a-zA-Z_][a-zA-Z_0-9]*$/
            raise Error.new("Invalid token name #{name.inspect}")
          end
          token = Token.new(name: name, id: @tokens.size, line_number: line_number)
          @tokens << token
          pattern = Pattern.new(pattern: pattern, token: token, line_number: line_number)
          @patterns << pattern
        elsif sliced = input.slice!(/\Atokenid\s+(\S+?)\s*;/m)
          name = $1
          unless name =~ /^[a-zA-Z_][a-zA-Z_0-9]*$/
            raise Error.new("Invalid token name #{name.inspect}")
          end
          token = Token.new(name: name, id: @tokens.size, line_number: line_number)
          @tokens << token
        elsif sliced = input.slice!(/\Adrop\s+(\S+)\s*;/)
          pattern = $1
          @patterns << Pattern.new(pattern: pattern, line_number: line_number, drop: true)
        elsif sliced = input.slice!(/\A(\S+)\s*->\s*(.*?)(?:;|<<\n(.*?)^>>\n)/m)
          rule_name, components, code = $1, $2, $3
          unless rule_name =~ /^[a-zA-Z_][a-zA-Z_0-9]*$/
            raise Error.new("Invalid rule name #{name.inspect}")
          end
          components = components.strip.split(/\s+/)
          # Reserve rule ID 0 for the "real" start rule.
          @rules << Rule.new(rule_name, components, code, line_number, @rules.size + 1)
        else
          if input.size > 25
            input = input.slice(0..20) + "..."
          end
          raise Error.new("Unexpected grammar input at line #{line_number}: #{input.chomp}")
        end
        line_number += sliced.count("\n")
      end
    end

  end

end
