require_relative "imbecile/cli"
require_relative "imbecile/grammar"
require_relative "imbecile/version"
require "erb"

module Imbecile

  class << self

    def run(input_file, output_file)
      grammar = Grammar.new
      unless grammar.load(input_file)
        return 2
      end
      classname = grammar.classname || grammar.capitalize
      erb = ERB.new(File.read(File.join(File.dirname(File.expand_path(__FILE__)), "../assets/parser.d.erb")), nil, "<>")
      result = erb.result(binding.clone)
      File.open(output_file, "wb") do |fh|
        fh.write(result)
      end
      return 0
    end

  end

end
