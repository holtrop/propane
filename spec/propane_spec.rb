require "fileutils"

describe Propane do
  def write_grammar(grammar)
    File.write("spec/run/testparser.propane", grammar)
  end

  def build_parser
    result = system(*%w[./propane.sh spec/run/testparser.propane spec/run/testparser.d --log spec/run/testparser.log])
    expect(result).to be_truthy
  end

  def compile(test_file)
    result = system(*%w[gdc -funittest -o spec/run/testparser spec/run/testparser.d], test_file)
    expect(result).to be_truthy
  end

  def run
    result = system("spec/run/testparser")
    expect(result).to be_truthy
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
    run
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
    run
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
    run
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
    run
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
    run
  end
end
