class Propane

  class Token

    # @return [String, nil]
    #   Token name.
    attr_reader :name

    # @return [Integer, nil]
    #   Token ID.
    attr_reader :id

    # @return [Integer, nil]
    #   Line number where the token was defined in the input grammar.
    attr_reader :line_number

    # Construct a Token.
    #
    # @param options [Hash]
    #   Optional parameters.
    # @option options [String, nil] :name
    #   Token name.
    # @option options [Integer, nil] :id
    #   Token ID.
    # @option options [Integer, nil] :line_number
    #   Line number where the token was defined in the input grammar.
    def initialize(options)
      @name = options[:name]
      @id = options[:id]
      @line_number = options[:line_number]
    end

    def to_s
      @name
    end

  end

end
