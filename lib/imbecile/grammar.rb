module Imbecile
  class Grammar

    # @return [String, nil] Module name.
    attr_reader :modulename

    # @return [String, nil] Class name.
    attr_reader :classname

    def initialize
      @tokens = {}
      @rules = {}
    end

    # @return [Boolean]
    #   Whether loading was successful.
    def load(input_file)
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
          unless name =~ /^[a-zA-Z_][a-zA-Z_0-9]*$/
            $stderr.puts "Invalid token name #{name} on line #{line_number}"
            return false
          end
          if @tokens[name]
            $stderr.puts "Duplicate token name #{name} on line #{line_number}"
            return false
          end
          @tokens[name] = expr
        else
          $stderr.puts "Unexpected input on line #{line_number}: #{line}"
          return false
        end
      end
      true
    end

  end
end
