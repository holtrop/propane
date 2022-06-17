class Propane

  class Rule

    # @return [Array<Token, RuleSet>]
    #   Rule components.
    attr_reader :components

    # @return [String]
    #   User code associated with the rule.
    attr_reader :code

    # @return [Integer]
    #   Rule ID.
    attr_reader :id

    # @return [Integer]
    #   Line number where the rule was defined in the input grammar.
    attr_reader :line_number

    # @return [String]
    #   Rule name.
    attr_reader :name

    # @return [RuleSet]
    #   The RuleSet that this Rule is a part of.
    attr_accessor :rule_set

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
    # @param id [Integer]
    #   Rule ID.
    def initialize(name, components, code, line_number, id)
      @name = name
      @components = components
      @code = code
      @id = id
      @line_number = line_number
    end

    # Return whether the Rule is empty.
    #
    # A Rule is empty if it has no components.
    #
    # @return [Boolean]
    #   Whether the Rule is empty.
    def empty?
      @components.empty?
    end

  end

end
