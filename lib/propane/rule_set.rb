class Propane

  class RuleSet

    # @return [Integer]
    #   ID of the RuleSet.
    attr_reader :id

    # @return [String]
    #   Name of the RuleSet.
    attr_reader :name

    # @return [String, nil]
    #   Parser type name.
    attr_accessor :ptypename

    # @return [Array<Rule>]
    #   Rules in the RuleSet.
    attr_reader :rules

    # @return [Boolean]
    #   Whether the RuleSet could expand to an empty sequence.
    attr_writer :could_be_empty

    # Construct a RuleSet.
    #
    # @param name [String]
    #   Name of the RuleSet.
    # @param id [Integer]
    #   ID of the RuleSet.
    def initialize(name, id)
      @id = id
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
    end

    # Return whether any Rule in the RuleSet is empty.
    #
    # @return [Boolean]
    #   Whether any rule in the RuleSet is empty.
    def could_be_empty?
      @could_be_empty
    end

    # Build the start token set for the RuleSet.
    #
    # @return [Set<Token>]
    #   Start token set for the RuleSet.
    def start_token_set
      if @_start_token_set.nil?
        @_start_token_set = Set.new
        @rules.each do |rule|
          rule.components.each do |component|
            if component.is_a?(Token)
              @_start_token_set << component
              break
            else
              @_start_token_set += component.start_token_set
              unless component.could_be_empty?
                break
              end
            end
          end
        end
      end
      @_start_token_set
    end

  end

end
