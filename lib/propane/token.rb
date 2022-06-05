class Propane

  class Token

    # @return [String]
    #   Token name.
    attr_reader :name

    # @return [String]
    #   Token pattern.
    attr_reader :pattern

    # @return [Integer]
    #   Token ID.
    attr_reader :id

    # @return [Integer, nil]
    #   Line number where the token was defined in the input grammar.
    attr_reader :line_number

    # @return [Regex::NFA]
    #   Regex NFA for matching the token.
    attr_reader :nfa

    # Construct a Token.
    #
    # @param name [String]
    #   Token name.
    # @param pattern [String]
    #   Token pattern.
    # @param id [Integer]
    #   Token ID.
    # @param line_number [Integer, nil]
    #   Line number where the token was defined in the input grammar.
    def initialize(name, pattern, id, line_number)
      @name = name
      @pattern = pattern
      @id = id
      @line_number = line_number
      unless pattern.nil?
        regex = Regex.new(pattern)
        regex.nfa.end_state.accepts = self
        @nfa = regex.nfa
      end
    end

    def c_name
      @name.upcase
    end

    # Whether the token is a drop token.
    #
    # @return [Boolean]
    #   Whether the token is a drop token.
    def drop?
      @name.nil?
    end

    def to_s
      @name
    end

  end

end
