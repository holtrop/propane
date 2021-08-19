module Imbecile
  class Lexer

    # @return [DFA]
    #   Lexer DFA.
    attr_accessor :dfa

    def initialize(grammar)
      @dfa = DFA.new(grammar.tokens)
    end

  end
end
