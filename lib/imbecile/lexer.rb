class Imbecile
  class Lexer

    # @return [DFA]
    #   Lexer DFA.
    attr_accessor :dfa

    def initialize(tokens)
      @dfa = DFA.new(tokens)
    end

  end
end
