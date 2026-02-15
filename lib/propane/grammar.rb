class Propane

  class Grammar

    # Reserve identifiers beginning with a double-underscore for internal use.
    IDENTIFIER_REGEX = /(?:[a-zA-Z]|_[a-zA-Z0-9])[a-zA-Z_0-9]*/

    attr_reader :context_user_fields
    attr_reader :tree
    attr_reader :tree_prefix
    attr_reader :tree_suffix
    attr_reader :free_token_node
    attr_reader :modulename
    attr_reader :patterns
    attr_accessor :rules
    attr_reader :start_rules
    attr_reader :tokens
    attr_reader :code_blocks
    attr_reader :ptypes
    attr_reader :prefix
    attr_reader :token_node
    attr_reader :token_user_fields

    def initialize(input)
      @patterns = []
      @start_rules = []
      @tokens = []
      @rules = []
      @code_blocks = {}
      @line_number = 1
      @next_line_number = @line_number
      @modeline = nil
      @input = input.gsub("\r\n", "\n")
      @ptypes = {"default" => "void *"}
      @prefix = "p_"
      @tree = false
      @tree_prefix = ""
      @tree_suffix = ""
      @free_token_node = nil
      @context_user_fields = nil
      @token_node = nil
      @token_user_fields = nil
      parse_grammar!
      @start_rules << "Start" if @start_rules.empty?
    end

    def ptype
      @ptypes["default"]
    end

    def invalid_token_id
      @tokens.size
    end

    def terminate_token_id
      @tokens.size + 1
    end

    private

    def parse_grammar!
      while @input.size > 0
        parse_statement!
      end
    end

    def parse_statement!
      if parse_white_space!
      elsif parse_comment_line!
      elsif @modeline.nil? && parse_mode_label!
      elsif parse_context_user_fields_statement!
      elsif parse_tree_statement!
      elsif parse_tree_prefix_statement!
      elsif parse_tree_suffix_statement!
      elsif parse_free_token_node_statement!
      elsif parse_module_statement!
      elsif parse_token_node_statement!
      elsif parse_token_user_fields_statement!
      elsif parse_ptype_statement!
      elsif parse_pattern_statement!
      elsif parse_start_statement!
      elsif parse_token_statement!
      elsif parse_tokenid_statement!
      elsif parse_drop_statement!
      elsif parse_rule_statement!
      elsif parse_code_block_statement!
      elsif parse_prefix_statement!
      else
        if @input.size > 25
          @input = @input.slice(0..20) + "..."
        end
        raise Error.new("Unexpected grammar input at line #{@line_number}: #{@input.chomp}")
      end
    end

    def parse_mode_label!
      if md = consume!(/(#{IDENTIFIER_REGEX}(?:\s*,\s*#{IDENTIFIER_REGEX})*)\s*:/)
        @modeline = md[1]
      end
    end

    def parse_white_space!
      consume!(/\s+/)
    end

    def parse_comment_line!
      consume!(/#.*\n/)
    end

    def parse_context_user_fields_statement!
      if md = consume!(/context_user_fields\b\s*/)
        unless code = parse_code_block!
          raise Error.new("Line #{@line_number}: expected code block")
        end
        @context_user_fields ||= ""
        @context_user_fields += code
      end
    end

    def parse_tree_statement!
      if consume!(/tree\s*;/)
        @tree = true
      end
    end

    def parse_tree_prefix_statement!
      if md = consume!(/tree_prefix\s+(\w+)\s*;/)
        @tree_prefix = md[1]
      end
    end

    def parse_tree_suffix_statement!
      if md = consume!(/tree_suffix\s+(\w+)\s*;/)
        @tree_suffix = md[1]
      end
    end

    def parse_free_token_node_statement!
      if md = consume!(/free_token_node\s+(\w+)\s*;/)
        @free_token_node = md[1]
      end
    end

    def parse_module_statement!
      if consume!(/module\s+/)
        md = consume!(/([\w.]+)\s*/, "expected module name")
        @modulename = md[1]
        consume!(/;/, "expected `;'")
        @modeline = nil
        true
      end
    end

    def parse_token_node_statement!
      if md = consume!(/token_node\b\s*/)
        unless code = parse_code_block!
          raise Error.new("Line #{@line_number}: expected code block")
        end
        @token_node ||= ""
        @token_node += code
      end
    end

    def parse_token_user_fields_statement!
      if md = consume!(/token_user_fields\b\s*/)
        unless code = parse_code_block!
          raise Error.new("Line #{@line_number}: expected code block")
        end
        @token_user_fields ||= ""
        @token_user_fields += code
      end
    end

    def parse_ptype_statement!
      if consume!(/ptype\s+/)
        name = "default"
        if md = consume!(/(#{IDENTIFIER_REGEX})\s*=\s*/)
          if @tree
            raise Error.new("Multiple ptypes are unsupported in tree mode")
          end
          name = md[1]
        end
        md = consume!(/([^;]+);/, "expected parser result type expression")
        @ptypes[name] = md[1].strip
      end
    end

    def parse_token_statement!
      if consume!(/token\s+/)
        md = consume!(/(#{IDENTIFIER_REGEX})\s*/, "expected token name")
        name = md[1]
        if md = consume!(/\((#{IDENTIFIER_REGEX})\)\s*/)
          if @tree
            raise Error.new("Multiple ptypes are unsupported in tree mode")
          end
          ptypename = md[1]
        end
        pattern = parse_pattern! || name
        consume!(/\s+/)
        unless code = parse_code_block!
          consume!(/;/, "expected `;' or code block")
        end
        token = Token.new(name, ptypename, @line_number)
        @tokens << token
        pattern = Pattern.new(pattern: pattern, token: token, line_number: @line_number, code: code, modes: get_modes_from_modeline, ptypename: ptypename)
        @patterns << pattern
        @modeline = nil
        true
      end
    end

    def parse_tokenid_statement!
      if md = consume!(/tokenid\s+/)
        md = consume!(/(#{IDENTIFIER_REGEX})\s*/, "expected token name")
        name = md[1]
        if md = consume!(/\((#{IDENTIFIER_REGEX})\)\s*/)
          if @tree
            raise Error.new("Multiple ptypes are unsupported in tree mode")
          end
          ptypename = md[1]
        end
        consume!(/;/, "expected `;'");
        token = Token.new(name, ptypename, @line_number)
        @tokens << token
        @modeline = nil
        true
      end
    end

    def parse_drop_statement!
      if md = consume!(/drop\s+/)
        pattern = parse_pattern!
        unless pattern
          raise Error.new("Line #{@line_number}: expected pattern to follow `drop'")
        end
        consume!(/\s+/)
        unless code = parse_code_block!
          consume!(/;/, "expected `;' or code block")
        end
        @patterns << Pattern.new(pattern: pattern, line_number: @line_number, code: code, modes: get_modes_from_modeline)
        @modeline = nil
        true
      end
    end

    def parse_rule_statement!
      if md = consume!(/(#{IDENTIFIER_REGEX})\s*(?:\((#{IDENTIFIER_REGEX})\))?\s*->\s*/)
        rule_name, ptypename = *md[1, 2]
        if @tree && ptypename
          raise Error.new("Multiple ptypes are unsupported in tree mode")
        end
        md = consume!(/((?:#{IDENTIFIER_REGEX}\??(?::#{IDENTIFIER_REGEX})?\s*)*)\s*/, "expected rule component list")
        components = md[1].strip.split(/\s+/)
        if @tree
          consume!(/;/, "expected `;'")
        else
          unless code = parse_code_block!
            consume!(/;/, "expected `;' or code block")
          end
        end
        @rules << Rule.new(rule_name, components, code, ptypename, @line_number)
        @modeline = nil
        true
      end
    end

    def parse_pattern_statement!
      if pattern = parse_pattern!
        consume!(/\s+/)
        if md = consume!(/\((#{IDENTIFIER_REGEX})\)\s*/)
          if @tree
            raise Error.new("Multiple ptypes are unsupported in tree mode")
          end
          ptypename = md[1]
        end
        unless code = parse_code_block!
          raise Error.new("Line #{@line_number}: expected code block to follow pattern")
        end
        @patterns << Pattern.new(pattern: pattern, line_number: @line_number, code: code, modes: get_modes_from_modeline, ptypename: ptypename)
        @modeline = nil
        true
      end
    end

    def parse_start_statement!
      if md = consume!(/start\s+([\w\s]*);/)
        start_rules = md[1].split(/\s+/).map(&:strip)
        start_rules.each do |start_rule|
          @start_rules << start_rule unless @start_rules.include?(start_rule)
        end
      end
    end

    def parse_code_block_statement!
      if md = consume!(/<<([a-z]*)(.*?)>>\n/m)
        name, code = md[1..2]
        code.sub!(/\A\n/, "")
        code += "\n" unless code.end_with?("\n")
        if @code_blocks[name]
          @code_blocks[name] += code
        else
          @code_blocks[name] = code
        end
        @modeline = nil
        true
      end
    end

    def parse_prefix_statement!
      if md = consume!(/prefix\s+(#{IDENTIFIER_REGEX})\s*;/)
        @prefix = md[1]
        true
      end
    end

    def parse_pattern!
      if md = consume!(%r{/})
        pattern = ""
        while !consume!(%r{/})
          if consume!(%r{\\})
            pattern += "\\"
            if md = consume!(%r{(.)})
              pattern += md[1]
            else
              raise Error.new("Line #{@line_number}: unterminated escape sequence")
            end
          elsif md = consume!(%r{(.)})
            pattern += md[1]
          elsif @input == "" || @input.start_with?("\n")
            raise Error.new("Line #{@line_number}: Unterminated pattern; expected `/`")
          end
        end
        pattern
      end
    end

    def parse_code_block!
      if md = consume!(/<<(.*?)>>\n/m)
        code = md[1]
        code.sub!(/\A\n/, "")
        code += "\n" unless code.end_with?("\n")
        code
      end
    end

    # Check if the input string matches the given regex.
    #
    # If so, remove the match from the input string, and update the line
    # number. If the regex is not matched and an error message is provided,
    # the error is raised.
    #
    # @param regex [Regexp]
    #   Regex to attempt to match.
    # @param error_message [String, nil]
    #   Error message to display if the regex is not matched. If nil and the
    #   regex is not matched, an error is not raised.
    #
    # @return [MatchData, nil]
    #   MatchData for the given regex if it was matched and removed from the
    #   input.
    def consume!(regex, error_message = nil)
      @line_number = @next_line_number
      if md = @input.match(/\A#{regex}/)
        @input.slice!(0, md[0].size)
        @next_line_number += md[0].count("\n")
        md
      elsif error_message
        raise Error.new("Line #{@line_number}: Error: #{error_message}")
      else
        false
      end
    end

    def get_modes_from_modeline
      if @modeline
        Set[*@modeline.split(",").map(&:strip)]
      else
        Set.new
      end
    end

  end

end
