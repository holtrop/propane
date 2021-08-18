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
      [last_accepts.name, last_s]
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
  g = Imbecile::Grammar.new(grammar)
  token_dfa = Imbecile::Lexer::DFA.new(g.tokens)
  test_lexer = TestLexer.new(token_dfa)
  test_lexer.lex(input)
end

describe Imbecile::Lexer::DFA do
  it "lexes a simple token" do
    expect(run(<<EOF, "foo")).to eq [["foo", "foo"]]
token foo
EOF
  end

  it "lexes two tokens" do
    expected = [
      ["foo", "foo"],
      ["bar", "bar"],
    ]
    expect(run(<<EOF, "foobar")).to eq expected
token foo
token bar
EOF
  end

  it "lexes the longer of multiple options" do
    expected = [
      ["identifier", "foobar"],
    ]
    expect(run(<<EOF, "foobar")).to eq expected
token foo
token bar
token identifier [a-z]+
EOF
    expected = [
      ["plusplus", "++"],
      ["plus", "+"],
    ]
    expect(run(<<EOF, "+++")).to eq expected
token plus \\+
token plusplus \\+\\+
EOF
  end

  it "lexes whitespace" do
    expected = [
      ["foo", "foo"],
      ["WS", " \t"],
      ["bar", "bar"],
    ]
    expect(run(<<EOF, "foo \tbar")).to eq expected
token foo
token bar
token WS \\s+
EOF
  end

  it "allows dropping a matched pattern" do
    expected = [
      ["foo", "foo"],
      [nil, " \t"],
      ["bar", "bar"],
    ]
    expect(run(<<EOF, "foo \tbar")).to eq expected
token foo
token bar
drop \\s+
EOF
  end
end
