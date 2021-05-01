require_relative "imbecile/cli"
require_relative "imbecile/grammar_parser"
require_relative "imbecile/version"

module Imbecile

  class << self

    def run(input_file)
      gp = GrammarParser.new(input_file)
    end

  end

end
