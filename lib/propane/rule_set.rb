class Propane

  # A RuleSet collects all grammar rules of the same name.
  class RuleSet

    # @return [Array<Hash>]
    #   AST fields.
    attr_reader :ast_fields

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

    # Return whether this is an optional RuleSet.
    #
    # @return [Boolean]
    #   Whether this is an optional RuleSet.
    def optional?
      @name.end_with?("?")
    end

    # For optional rule sets, return the underlying component that is optional.
    def option_target
      @rules.each do |rule|
        if rule.components.size > 0
          return rule.components[0]
        end
      end
      raise "Optional rule target not found"
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

    # Finalize a RuleSet after adding all Rules to it.
    def finalize(grammar)
      if grammar.ast
        build_ast_fields(grammar)
      end
    end

    private

    # Build the set of AST fields for this RuleSet.
    #
    # This is an Array of Hashes. Each entry in the Array corresponds to a
    # field location in the AST node. The entry is a Hash. It could have one or
    # two keys. It will always have the field name with a positional suffix as
    # a key. It may also have the field name without the positional suffix if
    # that field only exists in one position across all Rules in the RuleSet.
    #
    # @return [void]
    def build_ast_fields(grammar)
      field_ast_node_indexes = {}
      field_indexes_across_all_rules = {}
      @ast_fields = []
      @rules.each do |rule|
        rule.components.each_with_index do |component, i|
          if component.is_a?(RuleSet) && component.optional?
            component = component.option_target
          end
          if component.is_a?(Token)
            node_name = "Token"
          else
            node_name = component.name
          end
          struct_name = "#{grammar.ast_prefix}#{node_name}#{grammar.ast_suffix}"
          field_name = "p#{node_name}#{i + 1}"
          unless field_ast_node_indexes[field_name]
            field_ast_node_indexes[field_name] = @ast_fields.size
            @ast_fields << {field_name => struct_name}
          end
          field_indexes_across_all_rules[node_name] ||= Set.new
          field_indexes_across_all_rules[node_name] << field_ast_node_indexes[field_name]
          rule.rule_set_node_field_index_map[i] = field_ast_node_indexes[field_name]
        end
      end
      field_indexes_across_all_rules.each do |node_name, indexes_across_all_rules|
        if indexes_across_all_rules.size == 1
          # If this field was only seen in one position across all rules,
          # then add an alias to the positional field name that does not
          # include the position.
          @ast_fields[indexes_across_all_rules.first]["p#{node_name}"] =
            "#{grammar.ast_prefix}#{node_name}#{grammar.ast_suffix}"
        end
      end
      # Now merge in the field aliases as given by the user in the
      # grammar.
      field_aliases = {}
      @rules.each do |rule|
        rule.aliases.each do |alias_name, index|
          if field_aliases[alias_name] && field_aliases[alias_name] != index
            raise Error.new("Error: conflicting AST node field positions for alias `#{alias_name}`")
          end
          field_aliases[alias_name] = index
          @ast_fields[index][alias_name] = @ast_fields[index].first[1]
        end
      end
    end

  end

end
