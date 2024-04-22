class Propane

  # A RuleSet collects all grammar rules of the same name.
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

    # Build the set of AST fields for this RuleSet.
    #
    # The keys are the field names and the values are the AST node structure
    # names.
    #
    # @return [Hash]
    #   AST fields.
    def ast_fields
      @_ast_fields ||=
        begin
          field_indexes = {}
          fields = {}
          @rules.each do |rule|
            rule.components.each_with_index do |component, i|
              if component.is_a?(Token)
                node_name = "Token"
              else
                node_name = component.name
              end
              field_name = "p#{node_name}#{i + 1}"
              unless field_indexes[field_name]
                field_indexes[field_name] = fields.size
                fields[field_name] = node_name
              end
              rule.rule_set_node_field_index_map[i] = field_indexes[field_name]
            end
          end
          fields
        end
    end

    # Finalize a RuleSet after adding all Rules to it.
    def finalize
      ast_fields
    end

  end

end
