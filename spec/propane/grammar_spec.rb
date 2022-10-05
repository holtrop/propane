class Propane
  describe Grammar do
    it "parses a user grammar" do
      input = <<EOF
# Comment line

module a.b;
class Foobar;

token while;

token id
  /[a-zA-Z_][a-zA-Z_0-9]*/;

token token_with_code <<
Code for the token
>>

tokenid token_with_no_pattern;

drop /\\s+/;

A -> B <<
  a = 42;
>>
B -> C while id;
B -> <<
  b = 0;
>>
EOF
      grammar = Grammar.new(input)
      expect(grammar.classname).to eq "Foobar"
      expect(grammar.modulename).to eq "a.b"

      o = grammar.tokens.find {|token| token.name == "while"}
      expect(o).to_not be_nil
      expect(o.line_number).to eq 6

      o = grammar.patterns.find {|pattern| pattern.token == o}
      expect(o).to_not be_nil
      expect(o.pattern).to eq "while"
      expect(o.line_number).to eq 6
      expect(o.code).to be_nil

      o = grammar.tokens.find {|token| token.name == "id"}
      expect(o).to_not be_nil
      expect(o.line_number).to eq 9

      o = grammar.patterns.find {|pattern| pattern.token == o}
      expect(o).to_not be_nil
      expect(o.pattern).to eq "[a-zA-Z_][a-zA-Z_0-9]*"
      expect(o.line_number).to eq 9
      expect(o.code).to be_nil

      o = grammar.tokens.find {|token| token.name == "token_with_code"}
      expect(o).to_not be_nil
      expect(o.line_number).to eq 11

      o = grammar.patterns.find {|pattern| pattern.token == o}
      expect(o).to_not be_nil
      expect(o.pattern).to eq "token_with_code"
      expect(o.line_number).to eq 11
      expect(o.code).to eq "Code for the token\n"

      o = grammar.tokens.find {|token| token.name == "token_with_no_pattern"}
      expect(o).to_not be_nil
      expect(o.line_number).to eq 15

      o = grammar.patterns.find {|pattern| pattern.token == o}
      expect(o).to be_nil

      o = grammar.patterns.find {|pattern| pattern.pattern == "\\s+"}
      expect(o).to_not be_nil
      expect(o.line_number).to eq 17
      expect(o.token).to be_nil
      expect(o.code).to be_nil

      expect(grammar.rules.size).to eq 3

      o = grammar.rules[0]
      expect(o.name).to eq "A"
      expect(o.components).to eq %w[B]
      expect(o.line_number).to eq 19
      expect(o.code).to eq "  a = 42;\n"

      o = grammar.rules[1]
      expect(o.name).to eq "B"
      expect(o.components).to eq %w[C while id]
      expect(o.line_number).to eq 22
      expect(o.code).to be_nil

      o = grammar.rules[2]
      expect(o.name).to eq "B"
      expect(o.components).to eq []
      expect(o.line_number).to eq 23
      expect(o.code).to eq "  b = 0;\n"
    end

    it "parses code segments with semicolons" do
      input = <<EOF
token code1 <<
  a = b;
  return c;
>>

token code2 <<
  writeln("Hello there");
>>

tokenid token_with_no_pattern;
EOF
      grammar = Grammar.new(input)

      o = grammar.tokens.find {|token| token.name == "code1"}
      expect(o).to_not be_nil
      expect(o.line_number).to eq 1

      o = grammar.patterns.find {|pattern| pattern.token == o}
      expect(o).to_not be_nil
      expect(o.code).to eq "  a = b;\n  return c;\n"

      o = grammar.tokens.find {|token| token.name == "code2"}
      expect(o).to_not be_nil
      expect(o.line_number).to eq 6

      o = grammar.patterns.find {|pattern| pattern.token == o}
      expect(o).to_not be_nil
      expect(o.code).to eq %[  writeln("Hello there");\n]
    end

    it "supports mode labels" do
      input = <<EOF
token a;
m1: token b;
/foo/ <<
>>
m2: /bar/ <<
>>
drop /q/;
m3: drop /r/;
EOF
      grammar = Grammar.new(input)

      o = grammar.tokens.find {|token| token.name == "a"}
      expect(o).to_not be_nil

      o = grammar.patterns.find {|pattern| pattern.token == o}
      expect(o).to_not be_nil
      expect(o.mode).to be_nil

      o = grammar.tokens.find {|token| token.name == "b"}
      expect(o).to_not be_nil

      o = grammar.patterns.find {|pattern| pattern.token == o}
      expect(o).to_not be_nil
      expect(o.mode).to eq "m1"

      o = grammar.patterns.find {|pattern| pattern.pattern == "foo"}
      expect(o).to_not be_nil
      expect(o.mode).to be_nil

      o = grammar.patterns.find {|pattern| pattern.pattern == "bar"}
      expect(o).to_not be_nil
      expect(o.mode).to eq "m2"

      o = grammar.patterns.find {|pattern| pattern.pattern == "q"}
      expect(o).to_not be_nil
      expect(o.mode).to be_nil

      o = grammar.patterns.find {|pattern| pattern.pattern == "r"}
      expect(o).to_not be_nil
      expect(o.mode).to eq "m3"
    end
  end
end
