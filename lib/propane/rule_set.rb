class Propane

  class RuleSet

    # @return [String]
    #   Name of the RuleSet.
    attr_reader :name

    # @return [Array<Rule>]
    #   Rules in the RuleSet.
    attr_reader :rules

    # Construct a RuleSet.
    #
    # @param name [String]
    #   Name of the RuleSet.
    def initialize(name)
      @name = name
      @rules = []
      @could_be_empty = false
    end

    # Add a Rule to the RuleSet.
    #
    # @param rule [Rule]
    #   Rule to add.
    def <<(rule)
      @rules << rule
      if rule.empty?
        @could_be_empty = true
      end
    end

    # Return whether any Rule in the RuleSet is empty.
    #
    # @return [Boolean]
    #   Whether any rule in the RuleSet is empty.
    def could_be_empty?
      @could_be_empty
    end

  end

end
