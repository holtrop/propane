module Imbecile
  class Grammar

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
        end
      end
    end

  end
end
