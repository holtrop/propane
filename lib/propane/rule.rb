class Propane

  class Rule

    # @return [Array<Token, RuleSet>]
    #   Rule components.
    attr_reader :components

    # @return [String]
    #   User code associated with the rule.
    attr_reader :code

    # @return [Integer]
    #   Line number where the rule was defined in the input grammar.
    attr_reader :line_number

    # @return [String]
    #   Rule name.
    attr_reader :name

    # Construct a Rule.
    #
    # @param name [String]
    #   Rule name.
    # @param components [Array<String>]
    #   Rule components.
    # @param code [String]
    #   User code associated with the rule.
    # @param line_number [Integer]
    #   Line number where the rule was defined in the input grammar.
    def initialize(name, components, code, line_number)
      @name = name
      @components = components
      @code = code
      @line_number = line_number
    end

  end

end
