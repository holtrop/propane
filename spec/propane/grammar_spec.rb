class Propane
  describe Grammar do
    it "parses a user grammar" do
      input = <<EOF
# Comment line

module a.b;
ptype   XYZ  *  ;

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
      expect(grammar.modulename).to eq "a.b"
      expect(grammar.ptype).to eq "XYZ  *"
      expect(grammar.ptypes).to eq("default" => "XYZ  *")
      expect(grammar.prefix).to eq "p_"

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

prefix myparser_;
EOF
      grammar = Grammar.new(input)
      expect(grammar.prefix).to eq "myparser_"

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

    it "allows assigning ptypes to tokens and rules" do
      input = <<EOF
ptype Subnode *;
ptype string = char *;
ptype integer = int;
ptype node = Node *;

token abc(string);
token bar;
tokenid int(integer);

/xyz/ (string) <<
>>

/z28/ <<
>>

Start (node) -> R;
R -> abc int;
EOF
      grammar = Grammar.new(input)

      o = grammar.tokens.find {|token| token.name == "abc"}
      expect(o).to_not be_nil
      expect(o.ptypename).to eq "string"

      o = grammar.tokens.find {|token| token.name == "bar"}
      expect(o).to_not be_nil
      expect(o.ptypename).to be_nil

      o = grammar.tokens.find {|token| token.name == "int"}
      expect(o).to_not be_nil
      expect(o.ptypename).to eq "integer"

      o = grammar.rules.find {|rule| rule.name == "Start"}
      expect(o).to_not be_nil
      expect(o.ptypename).to eq "node"

      o = grammar.rules.find {|rule| rule.name == "R"}
      expect(o).to_not be_nil
      expect(o.ptypename).to be_nil

      o = grammar.patterns.find {|pattern| pattern.pattern == "xyz"}
      expect(o).to_not be_nil
      expect(o.ptypename).to eq "string"

      o = grammar.patterns.find {|pattern| pattern.pattern == "z28"}
      expect(o).to_not be_nil
      expect(o.ptypename).to be_nil
    end
  end
end
