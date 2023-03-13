class Propane

  class Token

    class << self

      # Name of the token to use in code (special characters replaced).
      #
      # @return [String]
      #   Name of the token to use in code (special characters replaced).
      def code_name(name)
        name.sub(/^\$/, "__")
      end

    end

    # @return [String, nil]
    #   Token name.
    attr_reader :name

    # @return [String, nil]
    #   Parser value type name.
    attr_accessor :ptypename

    # @return [Integer, nil]
    #   Token ID.
    attr_accessor :id

    # @return [Integer, nil]
    #   Line number where the token was defined in the input grammar.
    attr_reader :line_number

    # Construct a Token.
    #
    # @param name [String, nil]
    #   Token name.
    # @param ptypename [String, nil]
    #   Parser value type for this token.
    # @param line_number [Integer, nil]
    #   Line number where the token was defined in the input grammar.
    def initialize(name, ptypename, line_number)
      @name = name
      @ptypename = ptypename
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
