class Propane

  class Generator

    def initialize(grammar, output_file, log_file, options)
      @grammar = grammar
      @output_file = output_file
      if log_file
        @log = File.open(log_file, "wb")
      else
        @log = StringIO.new
      end
      @language =
        if output_file.end_with?(".d")
          "d"
        elsif output_file.end_with?(".c")
          "c"
        elsif output_file =~ %r{\.(cc|cpp|cxx)$}
          @cpp = true
          "c"
        elsif output_file.end_with?(".rs")
          "rust"
        else
          raise Error.new("Could not determine target language from output file name (#{output_file})")
        end
      @options = options
      process_grammar!
    end

    def generate
      extensions = [nil]
      if @language == "c"
        extensions += %w[h]
      end
      extensions.each do |extension|
        template_language = @language == "rust" ? "rs" : @language
        template = Assets.get("parser.#{extension || template_language}.erb")
        if extension
          output_file = @output_file.sub(%r{\.[a-z]+$}, ".#{extension}")
        else
          output_file = @output_file
        end
        erb = ERB.new(template, trim_mode: "<>")
        result = erb.result(binding.clone).lines.each_with_index.map do |line, i|
          if @language == "rust"
            # Rust has no #line directive support, so strip the directives that
            # the grammar embeds in user code blocks.
            line = line.sub(/^#line \d+ "[^"]*"/, "")
            line == "#linereset\n" ? "" : line
          elsif line == "#linereset\n"
            %[#line #{i + 2} "#{output_file}"\n]
          else
            line
          end
        end.join
        File.open(output_file, "wb") do |fh|
          fh.write(result)
        end
      end
      @log.close
    end

    private

    def process_grammar!
      # Assign default pattern mode to patterns without a mode assigned.
      found_default = false
      @grammar.patterns.each do |pattern|
        if pattern.modes.empty?
          pattern.modes << "default"
          found_default = true
        end
        pattern.ptypename ||= "default"
      end
      unless found_default
        raise Error.new("No patterns found for default mode")
      end
      check_ptypes!
      # Add EOF token.
      @grammar.tokens << Token.new("$EOF", nil, nil)
      tokens_by_name = {}
      @grammar.tokens.each_with_index do |token, token_id|
        # Assign token ID.
        token.id = token_id
        # Set default ptypename if none given.
        token.ptypename ||= "default"
        # Check for token name conflicts.
        if tokens_by_name.include?(token.name)
          raise Error.new("Duplicate token name #{token.name.inspect}")
        end
        tokens_by_name[token.name] = token
      end
      # Create real start rule(s).
      real_start_rules = @grammar.start_rules.map do |start_rule|
        unless @grammar.rules.find {|rule| rule.name == start_rule}
          raise Error.new("Start rule `#{start_rule}` not found")
        end
        Rule.new("$#{start_rule}", [start_rule, "$EOF"], nil, nil, nil)
      end
      # Add real start rules before user-given rules.
      @grammar.rules = real_start_rules + @grammar.rules
      # Generate and add rules for optional components.
      generate_optional_component_rules!(tokens_by_name)
      # Build rule sets.
      rule_sets = {}
      rule_set_id = @grammar.tokens.size
      @grammar.rules.each_with_index do |rule, rule_id|
        # Assign rule ID.
        rule.id = rule_id
        # Check for token/rule name conflict.
        if tokens_by_name.include?(rule.name)
          raise Error.new("Rule name collides with token name #{rule.name.inspect}")
        end
        # Build rule sets of all rules with the same name.
        unless rule_sets[rule.name]
          rule_sets[rule.name] = RuleSet.new(rule.name, rule_set_id)
          rule_set_id += 1
        end
        rule_set = rule_sets[rule.name]
        if rule_set.ptypename && rule.ptypename && rule_set.ptypename != rule.ptypename
          raise Error.new("Conflicting ptypes for rule #{rule.name}")
        end
        rule_set.ptypename ||= rule.ptypename
        rule.rule_set = rule_set
        rule_set << rule
      end
      rule_sets.each do |name, rule_set|
        rule_set.ptypename ||= "default"
        # Assign rule set ptypenames back to rules.
        rule_set.rules.each do |rule|
          rule.ptypename = rule_set.ptypename
        end
      end
      # Generate lexer user code IDs for lexer patterns with user code blocks.
      @grammar.patterns.select do |pattern|
        pattern.code
      end.each_with_index do |pattern, code_id|
        pattern.code_id = code_id
      end
      # Map rule components from names to Token/RuleSet objects.
      @grammar.rules.each do |rule|
        rule.components.map! do |component|
          if tokens_by_name[component]
            tokens_by_name[component]
          elsif rule_sets[component]
            rule_sets[component]
          else
            raise Error.new("Symbol #{component} not found")
          end
        end
      end
      determine_possibly_empty_rulesets!(rule_sets)
      rule_sets.each do |name, rule_set|
        rule_set.finalize(@grammar)
      end
      # Generate the lexer.
      @lexer = Lexer.new(@grammar)
      # Generate the parser.
      @parser = Parser.new(@grammar, rule_sets, @log, @options)
    end

    # Check that any referenced ptypes have been defined.
    def check_ptypes!
      (@grammar.patterns + @grammar.tokens + @grammar.rules).each do |potor|
        if potor.ptypename
          unless @grammar.ptypes.include?(potor.ptypename)
            raise Error.new("Error: Line #{potor.line_number}: ptype #{potor.ptypename} not declared. Declare with `ptype` statement.")
          end
        end
      end
    end

    # Generate and add rules for any optional components.
    def generate_optional_component_rules!(tokens_by_name)
      optional_rules_added = Set.new
      @grammar.rules.each do |rule|
        rule.components.each do |component|
          if component =~ /^(.*)\?$/
            c = $1
            unless optional_rules_added.include?(component)
              # Create two rules for the optional component: one empty and
              # one just matching the component.
              # We need to find the ptypename for the optional component in
              # order to copy it to the generated rules.
              if tokens_by_name[c]
                # The optional component is a token.
                ptypename = tokens_by_name[c].ptypename
              else
                # The optional component must be a rule, so find any instance
                # of that rule that specifies a ptypename.
                ptypename = @grammar.rules.reduce(nil) do |result, rule|
                  rule.name == c && rule.ptypename ? rule.ptypename : result
                end
              end
              @grammar.rules << Rule.new(component, [], nil, ptypename, rule.line_number)
              optcode = @grammar.tree ? nil : "$$ = $1;\n"
              @grammar.rules << Rule.new(component, [c], optcode, ptypename, rule.line_number)
              optional_rules_added << component
            end
          end
        end
      end
    end

    # Determine which grammar rules could expand to empty sequences.
    #
    # @param rule_sets [Hash]
    #   RuleSets.
    #
    # @return [void]
    def determine_possibly_empty_rulesets!(rule_sets)
      begin
        newly_discovered_empty_rulesets = false
        rule_sets.each do |name, rule_set|
          unless rule_set.could_be_empty?
            if could_rule_set_be_empty?(rule_set)
              newly_discovered_empty_rulesets = true
              rule_set.could_be_empty = true
            end
          end
        end
      end while newly_discovered_empty_rulesets
    end

    # Determine whether a RuleSet could be empty.
    #
    # @param rule_set [RuleSet]
    #   RuleSet to test.
    #
    # @return [Boolean]
    #   Whether the RuleSet could be empty.
    def could_rule_set_be_empty?(rule_set)
      rule_set.rules.any? do |rule|
        could_rule_be_empty?(rule)
      end
    end

    # Determine whether a Rule could be empty.
    #
    # @param rule [Rule]
    #   Rule to test.
    #
    # @return [Boolean]
    #   Whether the Rule could be empty.
    def could_rule_be_empty?(rule)
      i = 0
      loop do
        if i == rule.components.size
          return true
        end
        if rule.components[i].is_a?(Token)
          return false
        end
        if !rule.components[i].could_be_empty?
          return false
        end
        i += 1
      end
    end

    # Expand expansions in user code block.
    #
    # @param code [String]
    #   User code block.
    # @param parser [Boolean]
    #   Whether the user code is for the parser or lexer.
    # @param rule [Rule, nil]
    #   The Rule associated with the user code if user code is for the parser.
    # @param pattern [Pattern, nil]
    #   The Pattern associated with the user code if user code is for the lexer.
    #
    # @return [String]
    #   Expanded user code block.
    def expand_code(code, parser, rule, pattern)
      code = code.gsub(/\$token\(([$\w]+)\)/) do |match|
        "TOKEN_#{Token.code_name($1)}"
      end
      code = code.gsub(/\$terminate\((.*)\);/) do |match|
        user_terminate_code = $1
        retval = rule ? "P_USER_TERMINATED" : "TERMINATE_TOKEN_ID"
        case @language
        when "c"
          "context->user_terminate_code = (#{user_terminate_code}); return #{retval};"
        when "d"
          "context.user_terminate_code = (#{user_terminate_code}); return #{retval};"
        when "rust"
          "context.user_terminate_code = (#{user_terminate_code}); return #{retval};"
        end
      end
      code = code.gsub(/\$\{context\.(\w+)\}/) do |match|
        fieldname = $1
        case @language
        when "c"
          "context->#{fieldname}"
        when "d"
          "context.#{fieldname}"
        when "rust"
          "context.#{fieldname}"
        end
      end
      code = code.gsub(/\$\{token\.(\w+)\}/) do |match|
        fieldname = $1
        case @language
        when "c"
          "token_tree_node->#{fieldname}"
        when "d"
          "token_tree_node.#{fieldname}"
        when "rust"
          "token_tree_node.#{fieldname}"
        end
      end
      if parser
        code = code.gsub(/\$\$/) do |match|
          if @grammar.tree
            typename = "#{@grammar.tree_prefix}#{rule.name}#{@grammar.tree_suffix}"
            case @language
            when "c"
              tree_handle(typename, "_node_id")
            when "d"
              tree_handle(typename, "_node_id")
            when "rust"
              tree_handle(typename, "_node_id")
            end
          else
            case @language
            when "c"
              "_pvalue->v_#{rule.ptypename}"
            when "d"
              "_pvalue.v_#{rule.ptypename}"
            when "rust"
              "(*_pvalue.v_#{rule.ptypename}_mut())"
            end
          end
        end
        code = code.gsub(/\$(\d+)/) do |match|
          parser_component_reference(rule, $1.to_i)
        end
        code = code.gsub(/\$\{(\$|\d+)\.position\}/) do |match|
          index = $1.to_i
          "get_rule_position(statevalues, #{index}, n_states, false)"
        end
        code = code.gsub(/\$\{(\$|\d+)\.end_position\}/) do |match|
          index = $1.to_i
          "get_rule_position(statevalues, #{index}, n_states, true)"
        end
        code = code.gsub(/\$\{(\w+)\}/) do |match|
          aliasname = $1
          if index = rule.aliases[aliasname]
            # Field aliases are just a named reference to a positional rule
            # component, so reuse the same expansion as `$1', `$2', etc. Note
            # that rule.aliases stores a 0-based component index, so add 1 to
            # convert it to the 1-based index used for positional references.
            parser_component_reference(rule, index + 1)
          else
            raise Error.new("Field alias '#{aliasname}' not found")
          end
        end
      else
        code = code.gsub(/\$\$/) do |match|
          if @grammar.tree
            case @language
            when "c"
              "out_token_info->pvalue"
            when "d"
              "out_token_info.pvalue"
            when "rust"
              "out_token_info.pvalue"
            end
          else
            case @language
            when "c"
              "out_token_info->pvalue.v_#{pattern.ptypename}"
            when "d"
              "out_token_info.pvalue.v_#{pattern.ptypename}"
            when "rust"
              "(*out_token_info.pvalue.v_#{pattern.ptypename}_mut())"
            end
          end
        end
        code = code.gsub(/\$\{position\}/) do |match|
          case @language
          when "c"
            "out_token_info->position"
          when "d"
            "out_token_info.position"
          when "rust"
            "out_token_info.position"
          end
        end
        code = code.gsub(/\$\{end_position\}/) do |match|
          case @language
          when "c"
            "out_token_info->end_position"
          when "d"
            "out_token_info.end_position"
          when "rust"
            "out_token_info.end_position"
          end
        end
        code = code.gsub(/\$mode\(([a-zA-Z_][a-zA-Z_0-9]*)\)/) do |match|
          mode_name = $1
          mode_id = @lexer.mode_id(mode_name)
          unless mode_id
            raise Error.new("Lexer mode '#{mode_name}' not found")
          end
          case @language
          when "c"
            "context->mode = #{mode_id}u"
          when "d"
            "context.mode = #{mode_id}u"
          when "rust"
            "context.mode = #{mode_id}"
          end
        end
      end
      code
    end

    # Expand a positional reference to a parser rule component.
    #
    # This is used to expand `$1', `$2', etc. as well as field aliases (which
    # are just named references to a positional rule component).
    #
    # @param rule [Rule]
    #   The Rule containing the user code.
    # @param index [Integer]
    #   1-based index of the rule component to reference.
    #
    # @return [String]
    #   Expanded rule component reference.
    def parser_component_reference(rule, index)
      component = rule.components[index - 1]
      if @grammar.tree
        # In tree mode a component reference yields a handle to that
        # component's tree node. An optional component propagates its target
        # node (or null), so use the optional target's node type.
        if component.is_a?(RuleSet) && component.optional?
          component = component.option_target
        end
        node_name = component.is_a?(Token) ? "Token" : component.name
        typename = "#{@grammar.tree_prefix}#{node_name}#{@grammar.tree_suffix}"
        case @language
        when "c"
          tree_handle(typename, "state_values_stack_index(statevalues, -1 - (int)n_states + #{index})->node_id")
        when "d"
          tree_handle(typename, "statevalues[$-1-n_states+#{index}].node_id")
        when "rust"
          tree_handle(typename, "statevalues[statevalues.len() - 1 - n_states + #{index}].node_id")
        end
      else
        case @language
        when "c"
          "state_values_stack_index(statevalues, -1 - (int)n_states + #{index})->pvalue.v_#{component.ptypename}"
        when "d"
          "statevalues[$-1-n_states+#{index}].pvalue.v_#{component.ptypename}"
        when "rust"
          "statevalues[statevalues.len() - 1 - n_states + #{index}].pvalue.get_v_#{component.ptypename}()"
        end
      end
    end

    # Construct a tree node handle expression for the target language.
    #
    # A handle is a small value pairing the parser context with a node ID
    # (an index into the context's node arena). All handle types share this
    # layout; the distinct types exist for documentation and, in C, to drive
    # the tree walk macro's type threading.
    #
    # @param typename [String]
    #   Handle type name.
    # @param id_expr [String]
    #   Expression yielding the node ID.
    # @param parenthesize [Boolean]
    #   Whether to parenthesize the expression. Parentheses are required where
    #   the expression is substituted into a user code block, since the
    #   expression could be followed there by a field access or appear in a
    #   position where a bare Rust struct literal is not accepted. They are
    #   unnecessary where the expression stands alone, and Rust warns about
    #   them there, so this can be disabled for those uses.
    #
    # @return [String]
    #   Handle constructor expression.
    def tree_handle(typename, id_expr, parenthesize = true)
      if @cpp
        "(#{typename}{context, #{id_expr}})"
      elsif @language == "c"
        "((#{typename}){context, #{id_expr}})"
      elsif @language == "rust"
        expr = "#{typename} { context, id: #{id_expr} }"
        parenthesize ? "(#{expr})" : expr
      else
        "#{typename}(context, #{id_expr})"
      end
    end

    # Get the list of non-optional, non-internal rule sets that get a tree node
    # handle type generated for them.
    #
    # @return [Array<Propane::RuleSet>]
    #   Rule sets with generated tree node handle types.
    def tree_node_rule_sets
      @parser.rule_sets.reject do |name, rule_set|
        name.start_with?("$") || rule_set.optional?
      end.map {|name, rule_set| rule_set}
    end

    # Maximum number of chained fields supported by a single C tree walk macro
    # invocation. Deeper navigation can be expressed by nesting walk calls.
    C_TREE_WALK_MAX = 16

    # Get the tree node handle type name for a node name.
    #
    # @param name [String]
    #   Rule set name, or "Token".
    #
    # @return [String]
    #   Handle type name.
    def h_type(name)
      "#{@grammar.tree_prefix}#{name}#{@grammar.tree_suffix}"
    end

    # Get the list of all tree node handle type names (Token plus rule sets).
    #
    # @return [Array<String>]
    #   Handle type names.
    def tree_handle_types
      [h_type("Token")] + tree_node_rule_sets.map {|rs| h_type(rs.name)}
    end

    # Enumerate the navigation fields of a rule set's tree node.
    #
    # @yield [rtype, field_name, child_type, slot]
    #   Handle type name, field accessor name, child handle type, and child
    #   slot index.
    def each_tree_field(rule_set)
      rtype = h_type(rule_set.name)
      rule_set.tree_fields.each_with_index do |fields, slot|
        fields.each do |field_name, child_type|
          yield rtype, field_name, child_type, slot
        end
      end
    end

    # Generate the C/C++ tree node handle type section for the header.
    #
    # @return [String]
    #   Header handle section.
    def c_tree_types_header
      @cpp ? cpp_tree_types_header : c_only_tree_types_header
    end

    # Generate the C (non-C++) tree node handle type section for the header.
    def c_only_tree_types_header
      p = @grammar.prefix
      out = []
      out << "/** Tree node handle types. @{ */"
      tree_handle_types.each do |t|
        out << "typedef struct { #{p}context_t * __context; #{p}node_id_t __id; } #{t};"
      end
      out << ""
      out << c_common_accessors_header
      out << "/** @} */"
      out.join("\n")
    end

    # Generate the C-style (function + macro) tree node accessors shared by the
    # C and C++ headers. In C++ these are provided in addition to the handle
    # methods so that C-style code (and the tree walk macros) also works.
    def c_common_accessors_header
      p = @grammar.prefix
      out = []
      out << "/** Generic tree node accessors (usable on any handle type). */"
      out << "#define #{p}node_valid(h) ((h).__id != 0u)"
      out << "#define #{p}node_id(h) ((h).__id)"
      out << "#define #{p}node_data(h) (&(h).__context->#{p}tree_nodes[(h).__id])"
      out << "#define #{p}node_position(h) ((h).__context->#{p}tree_nodes[(h).__id].position)"
      out << "#define #{p}node_end_position(h) ((h).__context->#{p}tree_nodes[(h).__id].end_position)"
      out << "#define #{p}node_n_fields(h) ((h).__id ? (h).__context->#{p}tree_nodes[(h).__id].n_fields : (uint16_t)0u)"
      out << ""
      out << "/** Tree node field accessor functions. */"
      out << "#{p}token_t #{p}#{h_type("Token")}_token(#{h_type("Token")} node);"
      out << "#{p}value_t #{p}#{h_type("Token")}_pvalue(#{h_type("Token")} node);"
      tree_node_rule_sets.each do |rule_set|
        each_tree_field(rule_set) do |rtype, field_name, child_type, slot|
          out << "#{child_type} #{p}#{rtype}_#{field_name}(#{rtype} node);"
        end
      end
      out << ""
      out << c_tree_walk_macros
      out.join("\n")
    end

    # Generate the C tree walk macro machinery.
    def c_tree_walk_macros
      p = @grammar.prefix
      max = C_TREE_WALK_MAX
      out = []
      out << "/* Tree walk macros: p_tree_walk_<Type>(handle, field, ...). */"
      out << "#define #{p}CAT_(a, b) a##b"
      out << "#define #{p}CAT(a, b) #{p}CAT_(a, b)"
      out << "#define #{p}TA(t, f) #{p}CAT(#{p}CAT(#{p}CAT(#{p}TYPEAFTER_, t), _), f)"
      out << "#define #{p}ACC(t, f) #{p}CAT(#{p}CAT(#{p}CAT(#{p}, t), _), f)"
      argn = (1..max).map {|i| "_#{i}"}.join(", ")
      rseq = (0..max).to_a.reverse.join(", ")
      out << "#define #{p}ARG_N(#{argn}, N, ...) N"
      out << "#define #{p}NARG(...) #{p}ARG_N(__VA_ARGS__, #{rseq})"
      (1..max).each do |n|
        fparams = (1..n).map {|k| "f#{k}"}.join(", ")
        call = "h"
        (1..n).each do |k|
          texpr = "R"
          (1...k).each {|j| texpr = "#{p}TA(#{texpr}, f#{j})"}
          call = "#{p}ACC(#{texpr}, f#{k})(#{call})"
        end
        out << "#define #{p}tree_walk_#{n}(R, h, #{fparams}) #{call}"
      end
      out << "#define #{p}tree_walk_dispatch(R, h, ...) #{p}CAT(#{p}tree_walk_, #{p}NARG(__VA_ARGS__))(R, h, __VA_ARGS__)"
      # Type transition map (navigation fields only).
      tree_node_rule_sets.each do |rule_set|
        each_tree_field(rule_set) do |rtype, field_name, child_type, slot|
          out << "#define #{p}TYPEAFTER_#{rtype}_#{field_name} #{child_type}"
        end
      end
      # Per-handle-type walk entry points.
      tree_handle_types.each do |t|
        out << "#define #{p}tree_walk_#{t}(...) #{p}tree_walk_dispatch(#{t}, __VA_ARGS__)"
      end
      out.join("\n")
    end

    # Generate the C tree node accessor function definitions for the source.
    #
    # @return [String]
    #   Accessor function definitions.
    def c_tree_accessor_defs
      p = @grammar.prefix
      tt = h_type("Token")
      out = []
      out << "#{p}token_t #{p}#{tt}_token(#{tt} node)"
      out << "{"
      out << "    return node.__context->#{p}tree_nodes[node.__id].token;"
      out << "}"
      out << ""
      out << "#{p}value_t #{p}#{tt}_pvalue(#{tt} node)"
      out << "{"
      out << "    return node.__context->#{p}tree_nodes[node.__id].pvalue;"
      out << "}"
      tree_node_rule_sets.each do |rule_set|
        each_tree_field(rule_set) do |rtype, field_name, child_type, slot|
          out << ""
          out << "#{child_type} #{p}#{rtype}_#{field_name}(#{rtype} node)"
          out << "{"
          out << "    #{child_type} result;"
          out << "    result.__context = node.__context;"
          out << "    if (node.__id == 0u)"
          out << "    {"
          out << "        result.__id = 0u;"
          out << "        return result;"
          out << "    }"
          out << "    result.__id = node.__context->#{p}tree_children[node.__context->#{p}tree_nodes[node.__id].child_offset + #{slot}u];"
          out << "    return result;"
          out << "}"
        end
      end
      out.join("\n")
    end

    # Generate the C++ tree node handle type section for the header.
    def cpp_tree_types_header
      p = @grammar.prefix
      out = []
      out << "/** Tree node handle types. @{ */"
      tree_handle_types.each {|t| out << "struct #{t};"}
      out << ""
      # Token handle (all methods inline; no handle-typed returns).
      tt = h_type("Token")
      out << "struct #{tt}"
      out << "{"
      out << "    #{p}context_t * __context;"
      out << "    #{p}node_id_t __id;"
      out << "    bool valid() const { return __id != 0u; }"
      out << "    #{p}node_data_t * data() const { return &__context->#{p}tree_nodes[__id]; }"
      out << "    #{p}position_t position() const { return __context->#{p}tree_nodes[__id].position; }"
      out << "    #{p}position_t end_position() const { return __context->#{p}tree_nodes[__id].end_position; }"
      out << "    uint16_t n_fields() const { return __id ? __context->#{p}tree_nodes[__id].n_fields : (uint16_t)0u; }"
      out << "    #{p}token_t token() const { return __context->#{p}tree_nodes[__id].token; }"
      out << "    #{p}value_t pvalue() const { return __context->#{p}tree_nodes[__id].pvalue; }"
      out << "};"
      out << ""
      # Rule set handles: navigation methods declared, defined out-of-line below.
      tree_node_rule_sets.each do |rule_set|
        rtype = h_type(rule_set.name)
        out << "struct #{rtype}"
        out << "{"
        out << "    #{p}context_t * __context;"
        out << "    #{p}node_id_t __id;"
        out << "    bool valid() const { return __id != 0u; }"
        out << "    #{p}node_data_t * data() const { return &__context->#{p}tree_nodes[__id]; }"
        out << "    #{p}position_t position() const { return __context->#{p}tree_nodes[__id].position; }"
        out << "    #{p}position_t end_position() const { return __context->#{p}tree_nodes[__id].end_position; }"
        out << "    uint16_t n_fields() const { return __id ? __context->#{p}tree_nodes[__id].n_fields : (uint16_t)0u; }"
        each_tree_field(rule_set) do |rt, field_name, child_type, slot|
          out << "    #{child_type} #{field_name}() const;"
        end
        out << "};"
        out << ""
      end
      # Out-of-line navigation method bodies (all handle types now complete).
      tree_node_rule_sets.each do |rule_set|
        rtype = h_type(rule_set.name)
        each_tree_field(rule_set) do |rt, field_name, child_type, slot|
          out << "inline #{child_type} #{rtype}::#{field_name}() const"
          out << "{"
          out << "    if (__id == 0u)"
          out << "    {"
          out << "        return #{child_type}{__context, 0u};"
          out << "    }"
          out << "    return #{child_type}{__context, __context->#{p}tree_children[__context->#{p}tree_nodes[__id].child_offset + #{slot}u]};"
          out << "}"
        end
      end
      out << ""
      out << "/*"
      out << " * C-style function and macro accessors, provided in addition to the handle"
      out << " * methods above so that C-style code and the tree walk macros also work."
      out << " */"
      out << c_common_accessors_header
      out << "/** @} */"
      out.join("\n")
    end

    # Rust keywords that must be escaped as raw identifiers when used as a
    # generated identifier (e.g. a field alias named `type`).
    RUST_KEYWORDS = %w[
      as break const continue dyn else enum extern false fn for if impl in let
      loop match mod move mut pub ref return static struct trait true type
      unsafe use where while async await abstract become box do final macro
      override priv typeof unsized virtual yield try gen
    ]

    # Escape a name as a Rust raw identifier if it is a reserved keyword.
    #
    # @param name [String]
    #   Identifier name.
    #
    # @return [String]
    #   Name, escaped as a raw identifier if necessary.
    def rust_ident(name)
      RUST_KEYWORDS.include?(name) ? "r##{name}" : name
    end

    # Map a ptype type string to a valid Rust type.
    #
    # The default ptype is a C "void *"; for Rust with no declared ptype we use
    # the unit type instead.
    #
    # @param typestring [String]
    #   ptype type string.
    #
    # @return [String]
    #   Rust type string.
    def rust_ptype(typestring)
      typestring == "void *" ? "()" : typestring
    end

    # Get the lex function to use.
    #
    # @return [String]
    #   Lex function to use.
    def lex_fn
      @grammar.lex_fn || "#{@grammar.prefix}lex"
    end

    # Get the parser value type for the start rule.
    #
    # @return [Array<String>]
    #   Start rule parser value type name and type string.
    def start_rule_type(start_rule_index = 0)
      start_rule = @grammar.rules.find do |rule|
        rule.name == @grammar.start_rules[start_rule_index]
      end
      [start_rule.ptypename, @grammar.ptypes[start_rule.ptypename]]
    end

    # Get an unsigned integer type that can hold the given maximum value.
    #
    # @param max [Integer]
    #   Maximum value to store.
    #
    # @return [String]
    #   Type.
    def get_type_for(max)
      if max <= 0xFF
        case @language
        when "c"
          "uint8_t"
        when "d"
          "ubyte"
        when "rust"
          "u8"
        end
      elsif max <= 0xFFFF
        case @language
        when "c"
          "uint16_t"
        when "d"
          "ushort"
        when "rust"
          "u16"
        end
      else
        case @language
        when "c"
          "uint32_t"
        when "rust"
          "u32"
        else
          "uint"
        end
      end
    end

  end

end
