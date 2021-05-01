require_relative "imbecile/cli"
require_relative "imbecile/grammar"
require_relative "imbecile/version"

module Imbecile

  class << self

    def run(input_file)
      grammar = Grammar.new
      unless grammar.load(input_file)
        return 2
      end
      return 0
    end

  end

end
