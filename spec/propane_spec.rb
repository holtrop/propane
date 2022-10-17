require "fileutils"
require "open3"

Results = Struct.new(:stdout, :stderr, :status)

describe Propane do
  def write_grammar(grammar)
    File.write("spec/run/testparser.propane", grammar)
  end

  def build_parser(options = {})
    command = %w[./propane.sh spec/run/testparser.propane spec/run/testparser.d --log spec/run/testparser.log]
    if (options[:capture])
      stdout, stderr, status = Open3.capture3(*command)
      Results.new(stdout, stderr, status)
    else
      result = system(*command)
      expect(result).to be_truthy
    end
  end

  def compile(*test_files)
    result = system(*%w[gdc -funittest -o spec/run/testparser spec/run/testparser.d -Ispec], *test_files)
    expect(result).to be_truthy
  end

  def run
    stdout, stderr, status = Open3.capture3("spec/run/testparser")
    File.binwrite("spec/run/.stderr", stderr)
    File.binwrite("spec/run/.stdout", stdout)
    Results.new(stdout, stderr, status)
  end

  def lines(str)
    str.lines.map(&:chomp)
  end

  def verify_lines(lines, patterns)
    if lines.is_a?(String)
      lines = lines.lines.map(&:chomp)
    end
    patterns.each_with_index do |pattern, i|
      found_index =
        if pattern.is_a?(Regexp)
          lines.find_index {|line| line =~ pattern}
        else
          lines.find_index do |line|
            line.chomp == pattern.chomp
          end
        end
      unless found_index
        $stderr.puts "Lines:"
        $stderr.puts lines
        raise "A line matching #{pattern.inspect} (index #{i}) was not found."
      end
    end
  end

  before(:each) do
    FileUtils.rm_rf("spec/run")
    FileUtils.mkdir_p("spec/run")
  end

  it "generates a D lexer" do
    write_grammar <<EOF
token int /\\d+/;
token plus /\\+/;
token times /\\*/;
drop /\\s+/;
Start -> Foo;
Foo -> int <<
>>
Foo -> plus <<
>>
EOF
    build_parser
    compile("spec/test_d_lexer.d")
    results = run
    expect(results.stderr).to eq ""
    expect(results.status).to eq 0
  end

  it "generates a parser" do
    write_grammar <<EOF
token plus /\\+/;
token times /\\*/;
token zero /0/;
token one /1/;
Start -> E;
E -> E times B;
E -> E plus B;
E -> B;
B -> zero;
B -> one;
EOF
    build_parser
  end

  it "generates an SLR parser" do
    write_grammar <<EOF
token one /1/;
Start -> E;
E -> one E;
E -> one;
EOF
    build_parser
  end

  it "distinguishes between multiple identical rules with lookahead symbol" do
    write_grammar <<EOF
token a;
token b;
Start -> R1 a;
Start -> R2 b;
R1 -> a b;
R2 -> a b;
EOF
    build_parser
    compile("spec/test_d_parser_identical_rules_lookahead.d")
    results = run
    expect(results.status).to eq 0
  end

  it "handles reducing a rule that could be arrived at from multiple states" do
    write_grammar <<EOF
token a;
token b;
drop /\\s+/;
Start -> a R1;
Start -> b R1;
R1 -> b;
EOF
    build_parser
    compile("spec/test_d_parser_rule_from_multiple_states.d")
    results = run
    expect(results.status).to eq 0
  end

  it "executes user code when matching lexer token" do
    write_grammar <<EOF
token abc <<
  writeln("abc!");
>>
token def;
Start -> Abcs def;
Abcs -> ;
Abcs -> abc Abcs;
EOF
    build_parser
    compile("spec/test_user_code.d")
    results = run
    expect(results.status).to eq 0
    verify_lines(results.stdout, [
      "abc!",
      "pass1",
      "abc!",
      "abc!",
      "pass2",
    ])
  end

  it "supports a pattern statement" do
    write_grammar <<EOF
token abc;
/def/ <<
  writeln("def!");
>>
Start -> abc;
EOF
    build_parser
    compile("spec/test_pattern.d")
    results = run
    expect(results.status).to eq 0
    verify_lines(results.stdout, [
      "def!",
      "pass1",
      "def!",
      "def!",
      "pass2",
    ])
  end

  it "supports returning tokens from pattern code blocks" do
    write_grammar <<EOF
token abc;
/def/ <<
  writeln("def!");
>>
/ghi/ <<
  writeln("ghi!");
  return $token(abc);
>>
Start -> abc;
EOF
    build_parser
    compile("spec/test_return_token_from_pattern.d")
    results = run
    expect(results.status).to eq 0
    verify_lines(results.stdout, [
      "def!",
      "ghi!",
      "def!",
    ])
  end

  it "supports lexer modes" do
    write_grammar <<EOF
token abc;
token def;
tokenid string;
drop /\\s+/;
/"/ <<
  writeln("begin string mode");
  $mode(string);
>>
string: /[^"]+/ <<
  writeln("captured string");
>>
string: /"/ <<
  $mode(default);
  return $token(string);
>>
Start -> abc string def;
EOF
    build_parser
    compile("spec/test_lexer_modes.d")
    results = run
    expect(results.status).to eq 0
    verify_lines(results.stdout, [
      "begin string mode",
      "captured string",
      "pass1",
      "begin string mode",
      "captured string",
      "pass2",
    ])
  end

  it "executes user code associated with a parser rule" do
    write_grammar <<EOF
token a;
token b;
Start -> A B <<
  writeln("Start!");
>>
A -> a <<
  writeln("A!");
>>
B -> b <<
  writeln("B!");
>>
EOF
    build_parser
    compile("spec/test_parser_rule_user_code.d")
    results = run
    expect(results.status).to eq 0
    verify_lines(results.stdout, [
      "A!",
      "B!",
      "Start!",
    ])
  end

  it "parses lists" do
    write_grammar <<EOF
ptype uint;
token a;
Start -> As <<
  $$ = $1;
>>
As -> <<
  $$ = 0u;
>>
As -> As a <<
  $$ = $1 + 1u;
>>
EOF
    build_parser
    compile("spec/test_parsing_lists.d")
    results = run
    expect(results.status).to eq 0
    expect(results.stderr).to eq ""
  end

  it "fails to generate a parser for a LR(1) grammar that is not LALR" do
    write_grammar <<EOF
token a;
token b;
token c;
token d;
token e;
Start -> a E c;
Start -> a F d;
Start -> b F c;
Start -> b E d;
E -> e;
F -> e;
EOF
    results = build_parser(capture: true)
    expect(results.status).to_not eq 0
    expect(results.stderr).to match %r{reduce/reduce conflict.*\(E\).*\(F\)}
  end

  it "provides matched text to user code blocks" do
    write_grammar <<EOF
token id /[a-zA-Z_][a-zA-Z0-9_]*/ <<
  writeln("Matched token is ", match);
>>
Start -> id;
EOF
    build_parser
    compile("spec/test_lexer_match_text.d")
    results = run
    expect(results.status).to eq 0
    verify_lines(results.stdout, [
      "Matched token is identifier_123",
      "pass1",
    ])
  end

  it "allows storing a result value for the lexer" do
    write_grammar <<EOF
ptype ulong;
token word /[a-z]+/ <<
  $$ = match.length;
>>
Start -> word <<
  $$ = $1;
>>
EOF
    build_parser
    compile("spec/test_lexer_result_value.d")
    results = run
    expect(results.stderr).to eq ""
    expect(results.status).to eq 0
  end

  it "allows creating a JSON parser" do
    write_grammar <<EOF
<<
    import std.math;
    import json_types;
    string string_value;
>>

ptype JSONValue;
ptype array = JSONValue[];
ptype dict = JSONValue[string];
ptype string = string;

drop /\\s+/;
token lbrace /\\{/;
token rbrace /\\}/;
token lbracket /\\[/;
token rbracket /\\]/;
token comma /,/;
token colon /:/;
token number /-?(0|[1-9][0-9]*)(\\.[0-9]+)?([eE][-+]?[0-9]+)?/ <<
    double n;
    bool negative;
    size_t i = 0u;
    if (match[i] == '-')
    {
        negative = true;
        i++;
    }
    while ('0' <= match[i] && match[i] <= '9')
    {
        n *= 10.0;
        n += (match[i] - '0');
        i++;
    }
    if (match[i] == '.')
    {
        i++;
        double mult = 0.1;
        while ('0' <= match[i] && match[i] <= '9')
        {
            n += mult * (match[i] - '0');
            mult /= 10.0;
            i++;
        }
    }
    if (match[i] == 'e' || match[i] == 'E')
    {
        bool exp_negative;
        i++;
        if (match[i] == '-')
        {
            exp_negative = true;
            i++;
        }
        else if (match[i] == '+')
        {
            i++;
        }
        long exp;
        while ('0' <= match[i] && match[i] <= '9')
        {
            exp *= 10;
            exp += (match[i] - '0');
            i++;
        }
        if (exp_negative)
        {
            exp = -exp;
        }
        n = pow(n, exp);
    }
    if (negative)
    {
        n = -n;
    }
    $$ = new JSONNumber(n);
>>
token true <<
  $$ = new JSONTrue();
>>
token false <<
  $$ = new JSONFalse();
>>
token null <<
  $$ = new JSONNull();
>>
/"/ <<
  $mode(string);
  string_value = "";
>>
string: token string (string) /"/ <<
  $$ = string_value;
  $mode(default);
>>
string: /\\\\"/ <<
  string_value ~= "\\"";
>>
string: /\\\\\\\\/ <<
  string_value ~= "\\\\";
>>
string: /\\\\\\// <<
  string_value ~= "/";
>>
string: /\\\\b/ <<
  string_value ~= "\\b";
>>
string: /\\\\f/ <<
  string_value ~= "\\f";
>>
string: /\\\\n/ <<
  string_value ~= "\\n";
>>
string: /\\\\r/ <<
  string_value ~= "\\r";
>>
string: /\\\\t/ <<
  string_value ~= "\\t";
>>
string: /\\\\u[0-9a-fA-F]{4}/ <<
  /* Not actually going to encode the code point for this example... */
  string_value ~= "{" ~ match[2..6] ~ "}";
>>
string: /[^\\\\]/ <<
  string_value ~= match;
>>
Start -> Value <<
  $$ = $1;
>>
Value -> string <<
  $$ = new JSONString($1);
>>
Value -> number <<
  $$ = $1;
>>
Value -> Object <<
  $$ = $1;
>>
Value -> Array <<
  $$ = $1;
>>
Value -> true <<
  $$ = $1;
>>
Value -> false <<
  $$ = $1;
>>
Value -> null <<
  $$ = $1;
>>
Object -> lbrace rbrace <<
  $$ = new JSONObject();
>>
Object -> lbrace KeyValues rbrace <<
  $$ = new JSONObject($2);
>>
KeyValues (dict) -> KeyValue <<
  $$ = $1;
>>
KeyValues -> KeyValues comma KeyValue <<
  foreach (key, value; $3)
  {
    $1[key] = value;
  }
  $$ = $1;
>>
KeyValue (dict) -> string colon Value <<
  $$ = [$1: $3];
>>
Array -> lbracket rbracket <<
  $$ = new JSONArray();
>>
Array -> lbracket Values rbracket <<
  $$ = new JSONArray($2);
>>
Values (array) -> Value <<
  $$ = [$1];
>>
Values -> Values comma Value <<
  $$ = $1 ~ [$3];
>>
EOF
    build_parser
    compile("spec/test_parsing_json.d", "spec/json_types.d")
  end
end
