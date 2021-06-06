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
      token_names = Set.new
      input.each_line.each_with_index do |line, line_index|
        line = line.chomp
        line_number = line_index + 1
        if line =~ /^\s*#/
          # Skip comment lines.
        elsif line =~ /^\s*$/
          # Skip blank lines.
        elsif line =~ /^\s*module\s+(\S+)$/
          @modulename = $1
        elsif line =~ /^\s*class\s+(\S+)$/
          @classname = $1
        elsif line =~ /^\s*token\s+(\S+)(?:\s+(\S+))?$/
          name, pattern = $1, $2
          if pattern.to_s == ""
            pattern = name
          end
          unless name =~ /^[a-zA-Z_][a-zA-Z_0-9]*$/
            raise Error.new("Invalid token name #{name} on line #{line_number}")
          end
          if token_names.include?(name)
            raise Error.new("Duplicate token name #{name} on line #{line_number}")
          end
          @tokens << Token.new(name, pattern, @tokens.size)
          token_names << name
        else
          raise Error.new("Unexpected input on line #{line_number}: #{line}")
        end
      end

      # Build NFA from each token expression.
      i = 0
      nfas = @tokens.map do |token|
        regex = Regex.new(token.pattern)
        regex.nfa.end_state.accepts = "#{i}:#{token.name}"
        puts regex.nfa
        i += 1
        regex.nfa
      end
      dfa = Regex::DFA.new(nfas)
      puts dfa
    end

  end
end
