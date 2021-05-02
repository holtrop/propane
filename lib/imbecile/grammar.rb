module Imbecile
  class Grammar

    # @return [String, nil] Module name.
    attr_reader :modulename

    # @return [String, nil] Class name.
    attr_reader :classname

    def initialize(input_file)
      @tokens = {}
      @rules = {}
      File.read(input_file).each_line.each_with_index do |line, line_index|
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
        elsif line =~ /^\s*token\s+(\S+)\s+(.*)$/
          name, expr = $1, $2
          if expr == ""
            expr = name
          end
          unless name =~ /^[a-zA-Z_][a-zA-Z_0-9]*$/
            raise Error.new("Invalid token name #{name} on line #{line_number}")
          end
          if @tokens[name]
            raise Error.new("Duplicate token name #{name} on line #{line_number}")
          end
          @tokens[name] = expr
        else
          raise Error.new("Unexpected input on line #{line_number}: #{line}")
        end
      end

      # Build NFA from each token expression.
      @tokens.transform_values! do |expr|
        LexerNFA.new(expr)
      end
    end

  end
end
