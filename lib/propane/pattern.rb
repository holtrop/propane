class Propane

  class Pattern

    # @return [String, nil]
    #   Code block to execute when the pattern is matched.
    attr_reader :code

    # @option options [Integer, nil] :code_id
    #   Code block ID.
    attr_accessor :code_id

    # @return [String, nil]
    #   Pattern.
    attr_reader :pattern

    # @return [Token, nil]
    #   Token to be returned by this pattern.
    attr_reader :token

    # @return [Integer, nil]
    #   Line number where the pattern was defined in the input grammar.
    attr_reader :line_number

    # @return [Regex::NFA, nil]
    #   Regex NFA for matching the pattern.
    attr_reader :nfa

    # Construct a Pattern.
    #
    # @param options [Hash]
    #   Optional parameters.
    # @option options [String, nil] :code
    #   Code block to execute when the pattern is matched.
    # @option options [Boolean] :drop
    #   Whether this is a drop pattern.
    # @option options [String, nil] :pattern
    #   Pattern.
    # @option options [Token, nil] :token
    #   Token to be returned by this pattern.
    # @option options [Integer, nil] :line_number
    #   Line number where the token was defined in the input grammar.
    def initialize(options)
      @code = options[:code]
      @drop = options[:drop]
      @pattern = options[:pattern]
      @token = options[:token]
      @line_number = options[:line_number]
      regex = Regex.new(@pattern)
      regex.nfa.end_state.accepts = self
      @nfa = regex.nfa
    end

    # Whether the pattern is a drop pattern.
    #
    # @return [Boolean]
    #   Whether the pattern is a drop pattern.
    def drop?
      @drop
    end

  end

end