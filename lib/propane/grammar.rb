class Propane

  class Grammar

    attr_reader :classname
    attr_reader :modulename
    attr_reader :rule_sets
    attr_reader :tokens

    def initialize(input)
      @tokens = {}
      @rule_sets = {}
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
        elsif sliced = input.slice!(/\Amodule\s+(\S+)\n/)
          @modulename = $1
        elsif sliced = input.slice!(/\Aclass\s+(\S+)\n/)
          @classname = $1
        elsif sliced = input.slice!(/\Atoken\s+(\S+)(?:\s+(\S+))?\n/)
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
            @tokens[name] = Token.new(name, pattern, @tokens.size, line_number)
          end
        elsif sliced = input.slice!(/\Adrop\s+(\S+)\n/)
          pattern = $1
          @tokens[@tokens.size] = Token.new(nil, pattern, @tokens.size, line_number)
        elsif sliced = input.slice!(/\A(\S+)\s*:\s*\[(.*?)\] <<\n(.*?)^>>\n/m)
          rule_name, components, code = $1, $2, $3
          components = components.strip.split(/\s+/)
          @rule_sets[rule_name] ||= RuleSet.new(rule_name, @rule_sets.size)
          rule = Rule.new(rule_name, components, code, line_number)
          @rule_sets[rule_name].add_rule(rule)
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
