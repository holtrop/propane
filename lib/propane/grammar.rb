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
      @code_id = 0
      @line_number = 1
      @input = input.gsub("\r\n", "\n")
      parse_grammar!
    end

    private

    def parse_grammar!
      while @input.size > 0
        parse_statement!
      end
    end

    def parse_statement!
      @next_line_number = @line_number
      if consume!(/\A\s+/)
        # Skip white space.
      elsif consume!(/\A#.*\n/)
        # Skip comment lines.
      elsif md = consume!(/\Amodule\s+(\S+)\s*;/)
        @modulename = md[1]
      elsif md = consume!(/\Aclass\s+(\S+)\s*;/)
        @classname = md[1]
      elsif md = consume!(/\Atoken\s+(\S+?)(?:\s+([^\n]+?))?\s*(?:;|<<\n(.*?)^>>\n)/m)
        name, pattern, code = *md[1, 3]
        if pattern.nil?
          pattern = name
        end
        unless name =~ /^[a-zA-Z_][a-zA-Z_0-9]*$/
          raise Error.new("Invalid token name #{name.inspect}")
        end
        token = Token.new(name: name, id: @tokens.size, line_number: @line_number)
        @tokens << token
        if code
          code_id = @code_id
          @code_id += 1
        else
          code_id = nil
        end
        pattern = Pattern.new(pattern: pattern, token: token, line_number: @line_number, code: code, code_id: code_id)
        @patterns << pattern
      elsif md = consume!(/\Atokenid\s+(\S+?)\s*;/m)
        name = md[1]
        unless name =~ /^[a-zA-Z_][a-zA-Z_0-9]*$/
          raise Error.new("Invalid token name #{name.inspect}")
        end
        token = Token.new(name: name, id: @tokens.size, line_number: @line_number)
        @tokens << token
      elsif md = consume!(/\Adrop\s+(\S+)\s*;/)
        pattern = md[1]
        @patterns << Pattern.new(pattern: pattern, line_number: @line_number, drop: true)
      elsif md = consume!(/\A(\S+)\s*->\s*([^\n]*?)(?:;|<<\n(.*?)^>>\n)/m)
        rule_name, components, code = *md[1, 3]
        unless rule_name =~ /^[a-zA-Z_][a-zA-Z_0-9]*$/
          raise Error.new("Invalid rule name #{name.inspect}")
        end
        components = components.strip.split(/\s+/)
        # Reserve rule ID 0 for the "real" start rule.
        @rules << Rule.new(rule_name, components, code, @line_number, @rules.size + 1)
      else
        if @input.size > 25
          @input = @input.slice(0..20) + "..."
        end
        raise Error.new("Unexpected grammar input at line #{@line_number}: #{@input.chomp}")
      end
      @line_number = @next_line_number
    end

    # Check if the input string matches the given regex.
    #
    # If so, remove the match from the input string, and update the line
    # number.
    #
    # @param regex [Regexp]
    #   Regex to attempt to match.
    #
    # @return [MatchData, nil]
    #   MatchData for the given regex if it was matched and removed from the
    #   input.
    def consume!(regex)
      if md = @input.match(regex)
        @input.slice!(0, md[0].size)
        @next_line_number += md[0].count("\n")
        md
      end
    end

  end

end
