class Propane

  class Grammar

    # Reserve identifiers beginning with a double-underscore for internal use.
    IDENTIFIER_REGEX = /(?:[a-zA-Z]|_[a-zA-Z0-9])[a-zA-Z_0-9]*/

    attr_reader :classname
    attr_reader :modulename
    attr_reader :patterns
    attr_reader :rules
    attr_reader :tokens
    attr_reader :code_blocks
    attr_reader :ptypes

    def initialize(input)
      @patterns = []
      @tokens = []
      @rules = []
      @code_blocks = []
      @line_number = 1
      @next_line_number = @line_number
      @mode = nil
      @input = input.gsub("\r\n", "\n")
      @ptypes = {"default" => "void *"}
      parse_grammar!
    end

    def ptype
      @ptypes["default"]
    end

    def invalid_token_id
      @tokens.size
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
      elsif @mode.nil? && parse_mode_label!
      elsif parse_module_statement!
      elsif parse_class_statement!
      elsif parse_ptype_statement!
      elsif parse_pattern_statement!
      elsif parse_token_statement!
      elsif parse_tokenid_statement!
      elsif parse_drop_statement!
      elsif parse_rule_statement!
      elsif parse_code_block_statement!
      else
        if @input.size > 25
          @input = @input.slice(0..20) + "..."
        end
        raise Error.new("Unexpected grammar input at line #{@line_number}: #{@input.chomp}")
      end
    end

    def parse_mode_label!
      if md = consume!(/(#{IDENTIFIER_REGEX})\s*:/)
        @mode = md[1]
      end
    end

    def parse_white_space!
      consume!(/\s+/)
    end

    def parse_comment_line!
      consume!(/#.*\n/)
    end

    def parse_module_statement!
      if consume!(/module\s+/)
        md = consume!(/([\w.]+)\s*/, "expected module name")
        @modulename = md[1]
        consume!(/;/, "expected `;'")
        @mode = nil
        true
      end
    end

    def parse_class_statement!
      if consume!(/class\s+/)
        md = consume!(/([\w.]+)\s*/, "expected class name")
        @classname = md[1]
        consume!(/;/, "expected `;'")
        @mode = nil
        true
      end
    end

    def parse_ptype_statement!
      if consume!(/ptype\s+/)
        name = "default"
        if md = consume!(/(#{IDENTIFIER_REGEX})\s*=\s*/)
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
          ptypename = md[1]
        end
        pattern = parse_pattern! || name
        consume!(/\s+/)
        unless code = parse_code_block!
          consume!(/;/, "expected pattern or `;' or code block")
        end
        token = Token.new(name, ptypename, @line_number)
        @tokens << token
        pattern = Pattern.new(pattern: pattern, token: token, line_number: @line_number, code: code, mode: @mode, ptypename: ptypename)
        @patterns << pattern
        @mode = nil
        true
      end
    end

    def parse_tokenid_statement!
      if md = consume!(/tokenid\s+/)
        md = consume!(/(#{IDENTIFIER_REGEX})\s*/, "expected token name")
        name = md[1]
        if md = consume!(/\((#{IDENTIFIER_REGEX})\)\s*/)
          ptypename = md[1]
        end
        consume!(/;/, "expected `;'");
        token = Token.new(name, ptypename, @line_number)
        @tokens << token
        @mode = nil
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
        consume!(/;/, "expected `;'")
        @patterns << Pattern.new(pattern: pattern, line_number: @line_number, mode: @mode)
        @mode = nil
        true
      end
    end

    def parse_rule_statement!
      if md = consume!(/(#{IDENTIFIER_REGEX})\s*(?:\((#{IDENTIFIER_REGEX})\))?\s*->\s*/)
        rule_name, ptypename = *md[1, 2]
        md = consume!(/((?:#{IDENTIFIER_REGEX}\s*)*)\s*/, "expected rule component list")
        components = md[1].strip.split(/\s+/)
        unless code = parse_code_block!
          consume!(/;/, "expected pattern or `;' or code block")
        end
        @rules << Rule.new(rule_name, components, code, ptypename, @line_number)
        @mode = nil
        true
      end
    end

    def parse_pattern_statement!
      if pattern = parse_pattern!
        consume!(/\s+/)
        if md = consume!(/\((#{IDENTIFIER_REGEX})\)\s*/)
          ptypename = md[1]
        end
        unless code = parse_code_block!
          raise Error.new("Line #{@line_number}: expected code block to follow pattern")
        end
        @patterns << Pattern.new(pattern: pattern, line_number: @line_number, code: code, mode: @mode, ptypename: ptypename)
        @mode = nil
        true
      end
    end

    def parse_code_block_statement!
      if code = parse_code_block!
        @code_blocks << code
        @mode = nil
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
          end
        end
        pattern
      end
    end

    def parse_code_block!
      if md = consume!(/<<\n(.*?)^>>\n/m)
        md[1]
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

  end

end
