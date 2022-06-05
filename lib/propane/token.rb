class Propane

  class Token

    # @return [String, nil]
    #   Token name.
    attr_reader :name

    # @return [String, nil]
    #   Token pattern.
    attr_reader :pattern

    # @return [Integer, nil]
    #   Token ID.
    attr_reader :id

    # @return [Integer, nil]
    #   Line number where the token was defined in the input grammar.
    attr_reader :line_number

    # @return [Regex::NFA, nil]
    #   Regex NFA for matching the token.
    attr_reader :nfa

    # Construct a Token.
    #
    # @param options [Hash]
    #   Optional parameters.
    # @option options [String, nil] :name
    #   Token name.
    # @option options [String, nil] :pattern
    #   Token pattern.
    # @option options [Integer, nil] :id
    #   Token ID.
    # @option options [Integer, nil] :line_number
    #   Line number where the token was defined in the input grammar.
    def initialize(options)
      @name = options[:name]
      @pattern = options[:pattern]
      @id = options[:id]
      @line_number = options[:line_number]
      unless @pattern.nil?
        regex = Regex.new(@pattern)
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
