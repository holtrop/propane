class Propane

  class Token

    class << self

      # Name of the token to use in code (special characters replaced).
      #
      # @return [String]
      #   Name of the token to use in code (special characters replaced).
      def code_name(name)
        name.sub(/^\$/, "0")
      end

    end

    # @return [String, nil]
    #   Token name.
    attr_reader :name

    # @return [Integer, nil]
    #   Token ID.
    attr_accessor :id

    # @return [Integer, nil]
    #   Line number where the token was defined in the input grammar.
    attr_reader :line_number

    # Construct a Token.
    #
    # @param options [Hash]
    #   Optional parameters.
    # @option options [String, nil] :name
    #   Token name.
    # @option options [Integer, nil] :line_number
    #   Line number where the token was defined in the input grammar.
    def initialize(name, line_number)
      @name = name
      @line_number = line_number
    end

    # Name of the token to use in code (special characters replaced).
    #
    # @return [String]
    #   Name of the token to use in code (special characters replaced).
    def code_name
      self.class.code_name(@name)
    end

    def to_s
      @name
    end

  end

end
