class TestLexer
  def initialize(token_dfa)
    @token_dfa = token_dfa
  end

  def lex(input)
    input_chars = input.chars
    output = []
    while lexed_token = lex_token(input_chars)
      output << lexed_token
      input_chars.slice!(0, lexed_token[1].size)
    end
    unless input_chars.empty?
      raise "Unmatched input #{input_chars.join(" ")}"
    end
    output
  end

  def lex_token(input_chars)
    return nil if input_chars.empty?
    s = ""
    current_state = @token_dfa.start_state
    last_accepts = nil
    last_s = nil
    input_chars.each_with_index do |input_char, index|
      if next_state = transition(current_state, input_char)
        s += input_char
        current_state = next_state
        if current_state.accepts
          last_accepts = current_state.accepts
          last_s = s
        end
      else
        break
      end
    end
    if last_accepts
      name = last_accepts.token ? last_accepts.token.name : nil
      [name, last_s]
    end
  end

  def transition(state, input_char)
    state.transitions.each do |transition|
      if transition.code_point_range.include?(input_char.ord)
        return transition.destination
      end
    end
    nil
  end
end

def run(grammar, input)
  grammar = Propane::Grammar.new(grammar)
  token_dfa = Propane::Lexer::DFA.new(grammar.patterns)
  test_lexer = TestLexer.new(token_dfa)
  test_lexer.lex(input)
end

describe Propane::Lexer::DFA do
  it "lexes a simple token" do
    expect(run(<<EOF, "foo")).to eq [["foo", "foo"]]
token foo;
EOF
  end

  it "lexes two tokens" do
    expected = [
      ["foo", "foo"],
      ["bar", "bar"],
    ]
    expect(run(<<EOF, "foobar")).to eq expected
token foo;
token bar;
EOF
  end

  it "lexes the longer of multiple options" do
    expected = [
      ["identifier", "foobar"],
    ]
    expect(run(<<EOF, "foobar")).to eq expected
token foo;
token bar;
token identifier /[a-z]+/;
EOF
    expected = [
      ["plusplus", "++"],
      ["plus", "+"],
    ]
    expect(run(<<EOF, "+++")).to eq expected
token plus /\\+/;
token plusplus /\\+\\+/;
EOF
  end

  it "lexes whitespace" do
    expected = [
      ["foo", "foo"],
      ["WS", " \t"],
      ["bar", "bar"],
    ]
    expect(run(<<EOF, "foo \tbar")).to eq expected
token foo;
token bar;
token WS /\\s+/;
EOF
  end

  it "allows dropping a matched pattern" do
    expected = [
      ["foo", "foo"],
      [nil, " \t"],
      ["bar", "bar"],
    ]
    expect(run(<<EOF, "foo \tbar")).to eq expected
token foo;
token bar;
drop /\\s+/;
EOF
  end

  it "matches a semicolon" do
    expected = [
      ["semicolon", ";"],
    ]
    expect(run(<<EOF, ";")).to eq expected
token semicolon /;/;
EOF
  end

  it "matches a negated character class" do
    expected = [
      ["pattern", "/abc/"],
    ]
    expect(run(<<EOF, "/abc/")).to eq expected
token pattern /\\/[^\\s]*\\//;
EOF
  end

  it "matches special character classes " do
    expected = [
      ["a", "abc123_FOO"],
    ]
    expect(run(<<EOF, "abc123_FOO")).to eq expected
token a /\\w+/;
EOF
    expected = [
      ["b", "FROG*%$#"],
    ]
    expect(run(<<EOF, "FROG*%$#")).to eq expected
token b /FROG\\D{1,4}/;
EOF
    expected = [
      ["c", "$883366"],
    ]
    expect(run(<<EOF, "$883366")).to eq expected
token c /$\\d+/;
EOF
    expected = [
      ["d", "^&$@"],
    ]
    expect(run(<<EOF, "^&$@")).to eq expected
token d /^\\W+/;
EOF
    expected = [
      ["a", "abc123_FOO"],
      [nil, " "],
      ["b", "FROG*%$#"],
      [nil, " "],
      ["c", "$883366"],
      [nil, " "],
      ["d", "^&$@"],
    ]
    expect(run(<<EOF, "abc123_FOO FROG*%$# $883366 ^&$@")).to eq expected
token a /\\w+/;
token b /FROG\\D{1,4}/;
token c /$\\d+/;
token d /^\\W+/;
drop /\\s+/;
EOF
  end

  it "matches a negated character class with a nested inner negated character class" do
    expected = [
      ["t", "$&*"],
    ]
    expect(run(<<EOF, "$&*")).to eq expected
token t /[^%\\W]+/;
EOF
  end

  it "\\s matches a newline" do
    expected = [["s", "\n"]]
    expect(run(<<EOF, "\n")).to eq expected
token s /\\s/;
EOF
  end
end
