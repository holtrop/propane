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

  def compile(test_file)
    result = system(*%w[gdc -funittest -o spec/run/testparser spec/run/testparser.d], test_file)
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
result_type uint;
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
end
