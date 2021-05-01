require_relative "imbecile/cli"
require_relative "imbecile/grammar"
require_relative "imbecile/version"
require "erb"

module Imbecile

  class Error < RuntimeError
  end

  class << self

    def run(input_file, output_file)
      begin
        grammar = Grammar.new(input_file)
      rescue Error => e
        $stderr.puts e.message
        return 2
      end
      classname = grammar.classname || output_file.sub(%r{[^a-zA-Z0-9].*}, "").capitalize
      erb = ERB.new(File.read(File.join(File.dirname(File.expand_path(__FILE__)), "../assets/parser.d.erb")), nil, "<>")
      result = erb.result(binding.clone)
      File.open(output_file, "wb") do |fh|
        fh.write(result)
      end
      return 0
    end

  end

end
