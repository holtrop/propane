module Imbecile
  class GrammarParser

    def initialize(input_file)
      File.read(input_file).each_line.each_with_index do |line, line_index|
        line = line.chomp
        line_number = line_index + 1
        if line =~ /^\s*token\s+(\S+)\s+(.*)$/
          name, expr = $1, $2
          unless name =~ /^[a-zA-Z_][a-zA-Z_0-9]*$/
            raise "Invalid token name #{name} on line #{line_number}"
          end
        end
      end
    end

  end
end
