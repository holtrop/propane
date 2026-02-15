require "fileutils"
require "open3"

Results = Struct.new(:stdout, :stderr, :status)

describe Propane do
  before(:all) do
    @statics = {}
  end

  def write_grammar(grammar, options = {})
    options[:name] ||= ""
    File.write("spec/run/testparser#{options[:name]}.propane", grammar)
  end

  def run_propane(options = {})
    @statics[:build_test_id] ||= 0
    @statics[:build_test_id] += 1
    if ENV["dist_specs"]
      command = %W[dist/propane]
    else
      command = %W[ruby -I spec/run -r _simplecov_setup -I lib bin/propane]
      command_prefix =
        if ENV["partial_specs"]
          "p"
        else
          "b"
        end
      command_name = "#{command_prefix}#{@statics[:build_test_id]}"
      File.open("spec/run/_simplecov_setup.rb", "w") do |fh|
        fh.puts <<EOF
require "bundler"
Bundler.setup
require "simplecov"
class MyFormatter
  def format(*args)
  end
end
SimpleCov.start do
  command_name(#{command_name.inspect})
  filters.clear
  add_filter do |src|
    !(src.filename[SimpleCov.root])
  end
  formatter(MyFormatter)
end
# force color off
ENV["TERM"] = nil
EOF
      end
    end
    if options[:args]
      command += options[:args]
    else
      command += %W[spec/run/testparser#{options[:name]}.propane spec/run/testparser#{options[:name]}.#{options[:language]} --log spec/run/testparser#{options[:name]}.log]
    end
    command += (options[:extra_args] || [])
    if (options[:capture])
      stdout, stderr, status = Open3.capture3(*command)
      Results.new(stdout, stderr, status)
    else
      result = system(*command)
      expect(result).to be_truthy
    end
  end

  def compile(test_files, options = {})
    test_files = Array(test_files).map do |test_file|
      if !File.exist?(test_file) && test_file.end_with?(".cpp")
        test_file.sub(%r{\.cpp$}, ".c")
      else
        test_file
      end
    end
    options[:parsers] ||= [""]
    parsers = options[:parsers].map do |name|
      "spec/run/testparser#{name}.#{options[:language]}"
    end
    case options[:language]
    when "c"
      command = [*%w[gcc -g -Wall -o spec/run/testparser -Ispec -Ispec/run], *parsers, *test_files, "spec/testutils.c", "-lm"]
    when "cpp"
      command = [*%w[g++ -g -x c++ -Wall -o spec/run/testparser -Ispec -Ispec/run], *parsers, *test_files, "spec/testutils.c", "-lm"]
    when "d"
      command = [*%w[ldc2 -g --unittest -of spec/run/testparser -Ispec], *parsers, *test_files, "spec/testutils.d"]
    end
    result = system(*command)
    expect(result).to be_truthy
  end

  def run_test(options)
    stdout, stderr, status = Open3.capture3("spec/run/testparser")
    File.binwrite("spec/run/.stderr", stderr)
    File.binwrite("spec/run/.stdout", stdout)
    stderr.sub!(/^.*modules passed unittests\n/, "")
    results = Results.new(stdout, stderr, status)
    if %w[c cpp].include?(options[:language])
      stdout, stderr, status = Open3.capture3("valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes --verbose spec/run/testparser")
      vgout = stdout + stderr
      File.binwrite("spec/run/.vgout", vgout)
      vgout.scan(/lost: (\d+) bytes/) do |match|
        bytes = $1.to_i
        if bytes > 0
          raise "Valgrind detected memory leak"
        end
      end
    end
    results
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

  it "reports its version" do
    results = run_propane(args: %w[--version], capture: true)
    expect(results.stdout).to match /propane version \d+\.\d+/
    expect(results.stderr).to eq ""
    expect(results.status).to eq 0
  end

  it "shows help usage" do
    results = run_propane(args: %w[-h], capture: true)
    expect(results.stdout).to match /Usage/i
    expect(results.stderr).to eq ""
    expect(results.status).to eq 0
  end

  it "errors with unknown option" do
    results = run_propane(args: %w[-i], capture: true)
    expect(results.stderr).to match /Error: unknown option -i/
    expect(results.status).to_not eq 0
  end

  it "errors when input and output files are not specified" do
    results = run_propane(args: [], capture: true)
    expect(results.stderr).to match /Error: specify input and output files/
    expect(results.status).to_not eq 0
  end

  it "errors when input file is not readable" do
    results = run_propane(args: %w[nope.txt out.d], capture: true)
    expect(results.stderr).to match /Error: cannot read nope.txt/
    expect(results.status).to_not eq 0
  end

  it "raises an error when a pattern referenced ptype has not been defined" do
    write_grammar <<EOF
ptype yes = int;
/foo/ (yes) <<
>>
/bar/ (no) <<
>>
EOF
    results = run_propane(capture: true)
    expect(results.stderr).to match /Error: Line 4: ptype no not declared\. Declare with `ptype` statement\./
    expect(results.status).to_not eq 0
  end

  it "raises an error when a token referenced ptype has not been defined" do
    write_grammar <<EOF
ptype yes = int;
token foo (yes);
token bar (no);
EOF
    results = run_propane(capture: true)
    expect(results.stderr).to match /Error: Line 3: ptype no not declared\. Declare with `ptype` statement\./
    expect(results.status).to_not eq 0
  end

  it "raises an error when a rule referenced ptype has not been defined" do
    write_grammar <<EOF
ptype yes = int;
token xyz;
foo (yes) -> bar;
bar (no) -> xyz;
EOF
    results = run_propane(capture: true)
    expect(results.stderr).to match /Error: Line 4: ptype no not declared\. Declare with `ptype` statement\./
    expect(results.status).to_not eq 0
  end

  it "warns on shift/reduce conflicts" do
    write_grammar <<EOF
token a;
token b;
Start -> As? b?;
As -> a As2?;
As2 -> b a As2?;
EOF
    results = run_propane(capture: true)
    expect(results.stderr).to eq ""
    expect(results.status).to eq 0
    expect(File.binread("spec/run/testparser.log")).to match %r{Shift/Reduce conflict \(state \d+\) between token b and rule As2\? \(defined on line 4\)}
  end

  it "errors on shift/reduce conflicts with -w" do
    write_grammar <<EOF
token a;
token b;
Start -> As? b?;
As -> a As2?;
As2 -> b a As2?;
EOF
    results = run_propane(extra_args: %w[-w], capture: true)
    expect(results.stderr).to match %r{Shift/Reduce conflict \(state \d+\) between token b and rule As2\? \(defined on line 4\)}m
    expect(results.status).to_not eq 0
    expect(File.binread("spec/run/testparser.log")).to match %r{Shift/Reduce conflict \(state \d+\) between token b and rule As2\? \(defined on line 4\)}
  end

  it "errors on duplicate field aliases in a rule" do
    write_grammar <<EOF
token a;
token b;
Start -> a:foo b:foo;
EOF
    results = run_propane(extra_args: %w[-w], capture: true)
    expect(results.stderr).to match %r{Error: duplicate field alias `foo` for rule Start defined on line 3}
    expect(results.status).to_not eq 0
  end

  it "errors when an alias is in different positions for different rules in a rule set when tree mode is enabled" do
    write_grammar <<EOF
tree;
token a;
token b;
Start -> a:foo b;
Start -> b b:foo;
EOF
    results = run_propane(extra_args: %w[-w], capture: true)
    expect(results.stderr).to match %r{Error: conflicting tree node field positions for alias `foo`}
    expect(results.status).to_not eq 0
  end

  it "does not error when an alias is in different positions for different rules in a rule set when tree mode is not enabled" do
    write_grammar <<EOF
token a;
token b;
Start -> a:foo b;
Start -> b b:foo;
EOF
    results = run_propane(extra_args: %w[-w], capture: true)
    expect(results.stderr).to eq ""
    expect(results.status).to eq 0
  end

  it "shows error line number for unmatched left curly brace" do
    write_grammar <<EOF
# Line 1
# Line 2
token a /a{/;
Start -> a;
EOF
    results = run_propane(capture: true)
    expect(results.stderr).to match /Line 3: unexpected match count following \{/
    expect(results.status).to_not eq 0
  end

  %w[d c cpp].each do |language|

    context "#{language.upcase} language" do

      it "generates a lexer" do
        write_grammar <<EOF
token int /\\d+/;
token plus /\\+/;
token times /\\*/;
drop /\\s+/;
Start -> Foo;
Foo -> int <<>>
Foo -> plus <<>>
EOF
        run_propane(language: language)
        compile("spec/test_lexer.#{language}", language: language)
        results = run_test(language: language)
        expect(results.stderr).to eq ""
        expect(results.status).to eq 0
      end

      it "detects a lexer error when an unknown character is seen" do
        case language
        when "c", "cpp"
          write_grammar <<EOF
ptype int;
token int /\\d+/ <<
  int v = 0;
  for (size_t i = 0u; i < match_length; i++)
  {
    v *= 10;
    v += (match[i] - '0');
  }
  $$ = v;
>>
Start -> int << $$ = $1; >>
EOF
        when "d"
          write_grammar <<EOF
ptype int;
token int /\\d+/ <<
  int v;
  foreach (c; match)
  {
    v *= 10;
    v += (c - '0');
  }
  $$ = v;
>>
Start -> int << $$ = $1; >>
EOF
        end
        run_propane(language: language)
        compile("spec/test_lexer_unknown_character.#{language}", language: language)
        results = run_test(language: language)
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
        run_propane(language: language)
      end

      it "generates a parser that does basic math - user guide example" do
        case language
        when "c", "cpp"
          write_grammar <<EOF
<<
#include <math.h>
>>

ptype size_t;

token plus /\\+/;
token times /\\*/;
token power /\\*\\*/;
token integer /\\d+/ <<
  size_t v = 0u;
  for (size_t i = 0u; i < match_length; i++)
  {
    v *= 10;
    v += (match[i] - '0');
  }
  $$ = v;
>>
token lparen /\\(/;
token rparen /\\)/;
drop /\\s+/;

Start -> E1 << $$ = $1; >>
E1 -> E2 << $$ = $1; >>
E1 -> E1 plus E2 << $$ = $1 + $3; >>
E2 -> E3 << $$ = $1; >>
E2 -> E2 times E3 << $$ = $1 * $3; >>
E3 -> E4 << $$ = $1; >>
E3 -> E3 power E4 << $$ = (size_t)pow($1, $3); >>
E4 -> integer << $$ = $1; >>
E4 -> lparen E1 rparen << $$ = $2; >>
EOF
        when "d"
          write_grammar <<EOF
<<
import std.math;
>>

ptype ulong;

token plus /\\+/;
token times /\\*/;
token power /\\*\\*/;
token integer /\\d+/ <<
  ulong v;
  foreach (c; match)
  {
    v *= 10;
    v += (c - '0');
  }
  $$ = v;
>>
token lparen /\\(/;
token rparen /\\)/;
drop /\\s+/;

Start -> E1 << $$ = $1; >>
E1 -> E2 << $$ = $1; >>
E1 -> E1 plus E2 << $$ = $1 + $3; >>
E2 -> E3 << $$ = $1; >>
E2 -> E2 times E3 << $$ = $1 * $3; >>
E3 -> E4 << $$ = $1; >>
E3 -> E3 power E4 << $$ = pow($1, $3); >>
E4 -> integer << $$ = $1; >>
E4 -> lparen E1 rparen << $$ = $2; >>
EOF
        end
        run_propane(language: language)
        compile("spec/test_basic_math_grammar.#{language}", language: language)
        results = run_test(language: language)
        expect(results.stderr).to eq ""
        expect(results.status).to eq 0
      end

      it "generates an SLR parser" do
        write_grammar <<EOF
token one /1/;
Start -> E;
E -> one E;
E -> one;
EOF
        run_propane(language: language)
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
        run_propane(language: language)
        compile("spec/test_parser_identical_rules_lookahead.#{language}", language: language)
        results = run_test(language: language)
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
        run_propane(language: language)
        compile("spec/test_parser_rule_from_multiple_states.#{language}", language: language)
        results = run_test(language: language)
        expect(results.status).to eq 0
      end

      it "executes user code when matching lexer token" do
        case language
        when "c", "cpp"
          write_grammar <<EOF
<<
#include <stdio.h>
>>
token abc <<
  printf("abc!\\n");
>>
token def;
Start -> Abcs def;
Abcs -> ;
Abcs -> abc Abcs;
EOF
        when "d"
          write_grammar <<EOF
<<
import std.stdio;
>>
token abc <<
  writeln("abc!");
>>
token def;
Start -> Abcs def;
Abcs -> ;
Abcs -> abc Abcs;
EOF
        end
        run_propane(language: language)
        compile("spec/test_user_code.#{language}", language: language)
        results = run_test(language: language)
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
        case language
        when "c", "cpp"
          write_grammar <<EOF
<<
#include <stdio.h>
>>
token abc;
/def/ <<
  printf("def!\\n");
>>
Start -> abc;
EOF
        when "d"
          write_grammar <<EOF
<<
import std.stdio;
>>
token abc;
/def/ << writeln("def!"); >>
Start -> abc;
EOF
        end
        run_propane(language: language)
        compile("spec/test_pattern.#{language}", language: language)
        results = run_test(language: language)
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
        case language
        when "c", "cpp"
          write_grammar <<EOF
<<
#include <stdio.h>
>>
token abc;
/def/ << printf("def!\\n"); >>
/ghi/ <<
  printf("ghi!\\n");
  return $token(abc);
>>
Start -> abc;
EOF
        when "d"
          write_grammar <<EOF
<<
import std.stdio;
>>
token abc;
/def/ << writeln("def!"); >>
/ghi/ <<
  writeln("ghi!");
  return $token(abc);
>>
Start -> abc;
EOF
        end
        run_propane(language: language)
        compile("spec/test_return_token_from_pattern.#{language}", language: language)
        results = run_test(language: language)
        expect(results.status).to eq 0
        verify_lines(results.stdout, [
          "def!",
          "ghi!",
          "def!",
        ])
      end

      it "supports lexer modes" do
        case language
        when "c", "cpp"
          write_grammar <<EOF
<<
#include <stdio.h>
>>
token abc;
token def;
tokenid string;
drop /\\s+/;
/"/ <<
  printf("begin string mode\\n");
  $mode(string);
>>
string: /[^"]+/ <<
  printf("captured string\\n");
>>
string: /"/ <<
  $mode(default);
  return $token(string);
>>
Start -> abc string def;
EOF
        when "d"
          write_grammar <<EOF
<<
import std.stdio;
>>
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
        end
        run_propane(language: language)
        compile("spec/test_lexer_modes.#{language}", language: language)
        results = run_test(language: language)
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

      it "multiple lexer modes may apply to a pattern" do
        case language
        when "c", "cpp"
          write_grammar <<EOF
<<
#include <stdio.h>
>>
ptype char;
token abc;
token def;
default, identonly: token ident /[a-z]+/ <<
  $$ = match[0];
  $mode(default);
  return $token(ident);
>>
token dot /\\./ <<
  $mode(identonly);
>>
default, identonly: drop /\\s+/;
Start -> abc dot ident <<
  printf("ident: %c\\n", $3);
>>
EOF
        when "d"
          write_grammar <<EOF
<<
import std.stdio;
>>
ptype char;
token abc;
token def;
default, identonly: token ident /[a-z]+/ <<
  $$ = match[0];
  $mode(default);
>>
token dot /\\./ <<
  $mode(identonly);
>>
default, identonly: drop /\\s+/;
Start -> abc dot ident <<
  writeln("ident: ", $3);
>>
EOF
        end
        run_propane(language: language)
        compile("spec/test_lexer_multiple_modes.#{language}", language: language)
        results = run_test(language: language)
        expect(results.status).to eq 0
        verify_lines(results.stdout, [
          "ident: d",
          "pass1",
          "ident: a",
          "pass2",
        ])
      end

      it "executes user code associated with a parser rule" do
        case language
        when "c", "cpp"
          write_grammar <<EOF
<<
#include <stdio.h>
>>
token a;
token b;
Start -> A B << printf("Start!\\n"); >>
A -> a << printf("A!\\n"); >>
B -> b << printf("B!\\n"); >>
EOF
        when "d"
          write_grammar <<EOF
<<
import std.stdio;
>>
token a;
token b;
Start -> A B << writeln("Start!"); >>
A -> a << writeln("A!"); >>
B -> b << writeln("B!"); >>
EOF
        end
        run_propane(language: language)
        compile("spec/test_parser_rule_user_code.#{language}", language: language)
        results = run_test(language: language)
        expect(results.status).to eq 0
        verify_lines(results.stdout, [
          "A!",
          "B!",
          "Start!",
        ])
      end

      it "parses lists" do
        write_grammar <<EOF
ptype #{language == "d" ? "uint" : "uint32_t"};
token a;
Start -> As << $$ = $1; >>
As -> << $$ = 0u; >>
As -> As a << $$ = $1 + 1u; >>
EOF
        run_propane(language: language)
        compile("spec/test_parsing_lists.#{language}", language: language)
        results = run_test(language: language)
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
        results = run_propane(capture: true, language: language)
        expect(results.status).to_not eq 0
        expect(results.stderr).to match %r{Error: reduce/reduce conflict \(state \d+\) between rule E#\d+ \(defined on line 10\) and rule F#\d+ \(defined on line 11\)}
        expect(File.binread("spec/run/testparser.log")).to match %r{Reduce.actions:}
      end

      it "provides matched text to user code blocks" do
        case language
        when "c", "cpp"
          write_grammar <<EOF
<<
#include <stdio.h>
#include <stdlib.h>
>>
token id /[a-zA-Z_][a-zA-Z0-9_]*/ <<
  char * t = (char *)malloc(match_length + 1);
  strncpy(t, (char *)match, match_length);
  printf("Matched token is %s\\n", t);
  free(t);
>>
Start -> id;
EOF
        when "d"
          write_grammar <<EOF
<<
import std.stdio;
>>
token id /[a-zA-Z_][a-zA-Z0-9_]*/ <<
  writeln("Matched token is ", match);
>>
Start -> id;
EOF
        end
        run_propane(language: language)
        compile("spec/test_lexer_match_text.#{language}", language: language)
        results = run_test(language: language)
        expect(results.status).to eq 0
        verify_lines(results.stdout, [
          "Matched token is identifier_123",
          "pass1",
        ])
      end

      it "allows storing a result value for the lexer" do
        case language
        when "c", "cpp"
          write_grammar <<EOF
ptype uint64_t;
token word /[a-z]+/ <<
  $$ = match_length;
>>
Start -> word <<
  $$ = $1;
>>
EOF
        when "d"
          write_grammar <<EOF
ptype ulong;
token word /[a-z]+/ <<
  $$ = match.length;
>>
Start -> word <<
  $$ = $1;
>>
EOF
        end
        run_propane(language: language)
        compile("spec/test_lexer_result_value.#{language}", language: language)
        results = run_test(language: language)
        expect(results.stderr).to eq ""
        expect(results.status).to eq 0
      end

      it "tracks position of parser errors" do
        write_grammar <<EOF
token a;
token num /\\d+/;
drop /\\s+/;
Start -> a num Start;
Start -> a num;
EOF
        run_propane(language: language)
        compile("spec/test_error_positions.#{language}", language: language)
        results = run_test(language: language)
        expect(results.stderr).to eq ""
        expect(results.status).to eq 0
      end

      it "allows creating a JSON parser" do
        ext = language == "cpp" ? "c" : language
        write_grammar(File.read("spec/json_parser.#{ext}.propane"))
        run_propane(language: language)
        compile(["spec/test_parsing_json.#{language}", "spec/json_types.#{language}"], language: language)
      end

      it "allows generating multiple parsers in the same program" do
        write_grammar(<<EOF, name: "myp1")
prefix myp1_;
token a;
token num /\\d+/;
drop /\\s+/;
Start -> a num;
EOF
        run_propane(name: "myp1", language: language)
        write_grammar(<<EOF, name: "myp2")
prefix myp2_;
token b;
token c;
Start -> b c b;
EOF
        run_propane(name: "myp2", language: language)
        compile("spec/test_multiple_parsers.#{language}", parsers: %w[myp1 myp2], language: language)
        results = run_test(language: language)
        expect(results.stderr).to eq ""
        expect(results.status).to eq 0
      end

      it "allows the user to terminate the lexer" do
        write_grammar <<EOF
token a;
token b <<
  $terminate(8675309);
>>
token c;
Start -> Any;
Any -> a;
Any -> b;
Any -> c;
EOF
        run_propane(language: language)
        compile("spec/test_user_terminate_lexer.#{language}", language: language)
        results = run_test(language: language)
        expect(results.stderr).to eq ""
        expect(results.status).to eq 0
      end

      it "allows the user to terminate the parser" do
        write_grammar <<EOF
token a;
token b;
token c;
Start -> Any;
Any -> a Any;
Any -> b Any << $terminate(4200); >>
Any -> c Any;
Any -> ;
EOF
        run_propane(language: language)
        compile("spec/test_user_terminate.#{language}", language: language)
        results = run_test(language: language)
        expect(results.stderr).to eq ""
        expect(results.status).to eq 0
      end

      it "matches backslash escape sequences" do
        case language
        when "c", "cpp"
          write_grammar <<EOF
<<
  #include <stdio.h>
>>
tokenid t;
/\\a/ << printf("A\\n"); >>
/\\b/ << printf("B\\n"); >>
/\\t/ << printf("T\\n"); >>
/\\n/ << printf("N\\n"); >>
/\\v/ << printf("V\\n"); >>
/\\f/ << printf("F\\n"); >>
/\\r/ << printf("R\\n"); >>
/t/ << return $token(t); >>
Start -> t;
EOF
        when "d"
          write_grammar <<EOF
<<
  import std.stdio;
>>
tokenid t;
/\\a/ << writeln("A"); >>
/\\b/ << writeln("B"); >>
/\\t/ << writeln("T"); >>
/\\n/ << writeln("N"); >>
/\\v/ << writeln("V"); >>
/\\f/ << writeln("F"); >>
/\\r/ << writeln("R"); >>
/t/ <<
  return $token(t);
>>
Start -> t;
EOF
        end
        run_propane(language: language)
        compile("spec/test_match_backslashes.#{language}", language: language)
        results = run_test(language: language)
        expect(results.stderr).to eq ""
        expect(results.status).to eq 0
        verify_lines(results.stdout, [
          "A",
          "B",
          "T",
          "N",
          "V",
          "F",
          "R",
        ])
      end

      it "handles when an item set leads to itself" do
        write_grammar <<EOF
token one;
token two;

Start -> Opt one Start;
Start -> ;

Opt -> two;
Opt -> ;
EOF
        run_propane(language: language)
      end

      it "generates a tree" do
        write_grammar <<EOF
tree;

ptype int;

token a << $$ = 11; >>
token b << $$ = 22; >>
token one /1/;
token two /2/;
token comma /,/ <<
  $$ = 42;
>>
token lparen /\\(/;
token rparen /\\)/;
drop /\\s+/;

Start -> Items;

Items -> Item ItemsMore;
Items -> ;

ItemsMore -> comma Item ItemsMore;
ItemsMore -> ;

Item -> a;
Item -> b;
Item -> lparen Item rparen;
Item -> Dual;

Dual -> One Two;
Dual -> Two One;
One -> one;
Two -> two;
EOF
        run_propane(language: language)
        compile("spec/test_tree.#{language}", language: language)
        results = run_test(language: language)
        expect(results.stderr).to eq ""
        expect(results.status).to eq 0
      end

      it "supports tree node prefix and suffix" do
        write_grammar <<EOF
tree;
tree_prefix P ;
tree_suffix  S;

ptype int;

token a << $$ = 11; >>
token b << $$ = 22; >>
token one /1/;
token two /2/;
token comma /,/ <<
  $$ = 42;
>>
token lparen /\\(/;
token rparen /\\)/;
drop /\\s+/;

Start -> Items;

Items -> Item ItemsMore;
Items -> ;

ItemsMore -> comma Item ItemsMore;
ItemsMore -> ;

Item -> a;
Item -> b;
Item -> lparen Item rparen;
Item -> Dual;

Dual -> One Two;
Dual -> Two One;
One -> one;
Two -> two;
EOF
        run_propane(language: language)
        compile("spec/test_tree_ps.#{language}", language: language)
        results = run_test(language: language)
        expect(results.stderr).to eq ""
        expect(results.status).to eq 0
      end

      it "allows specifying a different start rule" do
        write_grammar <<EOF
token hi;
start Top;
Top -> hi;
EOF
        run_propane(language: language)
        compile("spec/test_start_rule.#{language}", language: language)
      end

      it "allows specifying a different start rule with tree generation" do
        write_grammar <<EOF
tree;
token hi;
start Top;
Top -> hi;
EOF
        run_propane(language: language)
        compile("spec/test_start_rule_tree.#{language}", language: language)
      end

      it "allows marking a rule component as optional" do
        if language == "d"
          write_grammar <<EOF
<<
import std.stdio;
>>

ptype int;
ptype float = float;
ptype string = string;

token a (float) << $$ = 1.5; >>
token b << $$ = 2; >>
token c << $$ = 3; >>
token d << $$ = 4; >>
Start -> a? b R? <<
  writeln("a: ", $1);
  writeln("b: ", $2);
  writeln("R: ", $3);
>>
R -> c d << $$ = "cd"; >>
R (string) -> d c << $$ = "dc"; >>
EOF
        else
          write_grammar <<EOF
<<
#include <stdio.h>
>>

ptype int;
ptype float = float;
ptype string = char *;

token a (float) << $$ = 1.5; >>
token b << $$ = 2; >>
token c << $$ = 3; >>
token d << $$ = 4; >>
Start -> a? b R? <<
  printf("a: %.1f\\n", $1);
  printf("b: %d\\n", $2);
  printf("R: %s\\n", $3 == NULL ? "" : $3);
>>
R -> c d << $$ = (char *)"cd"; >>
R (string) -> d c << $$ = (char *)"dc"; >>
EOF
        end
        run_propane(language: language)
        compile("spec/test_optional_rule_component.#{language}", language: language)
        results = run_test(language: language)
        expect(results.stderr).to eq ""
        expect(results.status).to eq 0
        verify_lines(results.stdout, [
          "a: 0#{language == "d" ? "" : ".0"}",
          "b: 2",
          "R: ",
          "a: 1.5",
          "b: 2",
          "R: cd",
          "a: 1.5",
          "b: 2",
          "R: dc",
        ])
      end

      it "allows marking a rule component as optional in tree generation mode" do
        if language == "d"
          write_grammar <<EOF
tree;

<<
import std.stdio;
>>

token a;
token b;
token c;
token d;
Start -> a? b R?;
R -> c d;
R -> d c;
EOF
        else
          write_grammar <<EOF
tree;

<<
#include <stdio.h>
>>

token a;
token b;
token c;
token d;
Start -> a? b R?;
R -> c d;
R -> d c;
EOF
        end
        run_propane(language: language)
        compile("spec/test_optional_rule_component_tree.#{language}", language: language)
        results = run_test(language: language)
        expect(results.stderr).to eq ""
        expect(results.status).to eq 0
      end

      it "allows naming an optional rule component in tree generation mode" do
        if language == "d"
          write_grammar <<EOF
tree;

<<
import std.stdio;
>>

token a;
token b;
token c;
token d;
Start -> a?:a b R?:r;
R -> c d;
R -> d c;
EOF
        else
          write_grammar <<EOF
tree;

<<
#include <stdio.h>
>>

token a;
token b;
token c;
token d;
Start -> a?:a b R?:r;
R -> c d;
R -> d c;
EOF
        end
        run_propane(language: language)
        compile("spec/test_named_optional_rule_component_tree.#{language}", language: language)
        results = run_test(language: language)
        expect(results.stderr).to eq ""
        expect(results.status).to eq 0
      end

      it "stores token and rule positions in tree nodes" do
        write_grammar <<EOF
tree;

token a;
token bb;
token c /c(.|\\n)*c/;
drop /\\s+/;
Start -> T T T;
T -> a;
T -> bb;
T -> c;
EOF
        run_propane(language: language)
        compile("spec/test_tree_token_positions.#{language}", language: language)
        results = run_test(language: language)
        expect(results.stderr).to eq ""
        expect(results.status).to eq 0
      end

      it "stores invalid positions for empty rule matches" do
        write_grammar <<EOF
tree;

token a;
token bb;
token c /c(.|\\n)*c/;
drop /\\s+/;
Start -> T Start;
Start -> ;
T -> a A;
A -> bb? c?;
EOF
        run_propane(language: language)
        compile("spec/test_tree_invalid_positions.#{language}", language: language)
        results = run_test(language: language)
        expect(results.stderr).to eq ""
        expect(results.status).to eq 0
      end

      it "allows specifying field aliases in tree mode" do
        write_grammar <<EOF
tree;

token a;
token b;
token c;
drop /\\s+/;
Start -> T:first T:second T:third;
T -> a;
T -> b;
T -> c;
EOF
        run_propane(language: language)
        compile("spec/test_tree_field_aliases.#{language}", language: language)
        results = run_test(language: language)
        expect(results.stderr).to eq ""
        expect(results.status).to eq 0
      end

      it "aliases the correct field when multiple rules are in a rule set in tree mode" do
        write_grammar <<EOF
tree;

token a;
token b;
token c;
drop /\\s+/;
Start -> a;
Start -> Foo;
Start -> T:first T:second T:third;
Foo -> b;
T -> a;
T -> b;
T -> c;
EOF
        run_propane(language: language)
        compile("spec/test_tree_field_aliases.#{language}", language: language)
        results = run_test(language: language)
        expect(results.stderr).to eq ""
        expect(results.status).to eq 0
      end

      it "allows specifying field aliases when tree mode is not enabled" do
        if language == "d"
          write_grammar <<EOF
<<
import std.stdio;
>>
ptype string;
token id /[a-zA-Z_][a-zA-Z0-9_]*/ <<
  $$ = match;
>>
drop /\\s+/;
Start -> id:first id:second <<
  writeln("first is ", ${first});
  writeln("second is ", ${second});
>>
EOF
        else
          write_grammar <<EOF
<<
#include <stdio.h>
#include <string.h>
>>
ptype char *;
token id /[a-zA-Z_][a-zA-Z0-9_]*/ <<
  char * s = (char *)malloc(match_length + 1);
  strncpy(s, (char const *)match, match_length);
  s[match_length] = 0;
  $$ = s;
>>
drop /\\s+/;
Start -> id:first id:second <<
  printf("first is %s\\n", ${first});
  printf("second is %s\\n", ${second});
  free(${first});
  free(${second});
>>
EOF
        end
        run_propane(language: language)
        compile("spec/test_field_aliases.#{language}", language: language)
        results = run_test(language: language)
        expect(results.stderr).to eq ""
        expect(results.status).to eq 0
        expect(results.stdout).to match /first is foo1.*second is bar2/m
      end

      it "aliases the correct field when multiple rules are in a rule set when tree mode is not enabled" do
        if language == "d"
          write_grammar <<EOF
<<
import std.stdio;
>>
ptype string;
token id /[a-zA-Z_][a-zA-Z0-9_]*/ <<
  $$ = match;
>>
drop /\\s+/;
Start -> id;
Start -> Foo;
Start -> id:first id:second <<
  writeln("first is ", ${first});
  writeln("second is ", ${second});
>>
Foo -> ;
EOF
        else
          write_grammar <<EOF
<<
#include <stdio.h>
#include <string.h>
>>
ptype char *;
token id /[a-zA-Z_][a-zA-Z0-9_]*/ <<
  char * s = (char *)malloc(match_length + 1);
  strncpy(s, (char const *)match, match_length);
  s[match_length] = 0;
  $$ = s;
>>
drop /\\s+/;
Start -> id;
Start -> Foo;
Start -> id:first id:second <<
  printf("first is %s\\n", ${first});
  printf("second is %s\\n", ${second});
  free(${first});
  free(${second});
>>
Foo -> ;
EOF
        end
        run_propane(language: language)
        compile("spec/test_field_aliases.#{language}", language: language)
        results = run_test(language: language)
        expect(results.stderr).to eq ""
        expect(results.status).to eq 0
        expect(results.stdout).to match /first is foo1.*second is bar2/m
      end

      it "does not free memory allocated for tree nodes" do
        ext = language == "cpp" ? "c" : language
        write_grammar(File.read("spec/tree_node_memory_remains.#{ext}.propane"))
        run_propane(language: language)
        compile("spec/test_tree_node_memory_remains.#{language}", language: language)
        results = run_test(language: language)
        expect(results.stderr).to eq ""
        expect(results.status).to eq 0
      end

      it "allows multiple starting rules" do
    write_grammar <<EOF
ptype int;
token a << $$ = 1; >>
token b << $$ = 2; >>
token c << $$ = 3; >>
Start -> a b R;
Start -> Bs:bs << $$ = $1; >>
R -> c:c << $$ = $1; >>
Bs -> << $$ = 0; >>
Bs -> b:b Bs:bs << $$ = $1 + $2; >>
start Start R Bs;
EOF
        run_propane(language: language)
        compile("spec/test_starting_rules.#{language}", language: language)
        results = run_test(language: language)
        expect(results.stderr).to eq ""
        expect(results.status).to eq 0
      end

      it "allows multiple starting rules in tree mode" do
    write_grammar <<EOF
tree;
ptype int;
token a << $$ = 1; >>
token b << $$ = 2; >>
token c << $$ = 3; >>
Start -> a b R;
Start -> Bs:bs;
R -> c:c;
Bs -> ;
Bs -> b:b Bs:bs;
start Start R Bs;
EOF
        run_propane(language: language)
        compile("spec/test_starting_rules_tree.#{language}", language: language)
        results = run_test(language: language)
        expect(results.stderr).to eq ""
        expect(results.status).to eq 0
      end

      if %w[c cpp].include?(language)
        it "allows a user function to free token node memory in tree mode" do
          write_grammar <<EOF
<<
static void free_token(Token * token)
{
    free(token->pvalue);
}
>>
tree;
free_token_node free_token;
ptype int *;
token a <<
  $$ = (int *)malloc(sizeof(int));
  *$$ = 1;
>>
token b <<
  $$ = (int *)malloc(sizeof(int));
  *$$ = 2;
>>
Start -> a:a b:b;
EOF
          run_propane(language: language)
          compile("spec/test_free_tree_token_node_memory.#{language}", language: language)
          results = run_test(language: language)
          expect(results.stderr).to eq ""
          expect(results.status).to eq 0
        end
      end

      it "executes code blocks associated with drop statements" do
        if language == "d"
          write_grammar <<EOF
<<
import std.stdio;
>>
drop /\\s+/;
drop /#(.*)\\n/ <<
  stderr.write("comment: ", match);
>>
token a;
Start -> a;
EOF
        else
          write_grammar <<EOF
<<
#include <stdio.h>
#include <string.h>
>>
drop /\\s+/;
drop /#(.*)\\n/ <<
  fprintf(stderr, "comment: %.*s", (int)match_length, match);
>>
token a;
Start -> a;
EOF
        end
        run_propane(language: language)
        compile("spec/test_drop_code_block.#{language}", language: language)
        results = run_test(language: language)
        expect(results.stderr).to match %r{comment: # comment 1\n.*comment: #    comment 2}m
        expect(results.status).to eq 0
      end

      it "allows user-defined context fields" do
        if language == "d"
          write_grammar <<EOF
context_user_fields <<
    string comments;
    uint acount;
>>
drop /\\s+/;
drop /#(.*)\\n/ <<
    ${context.comments} ~= match;
>>
token a <<
    ${context.acount}++;
>>
Start -> As;
As -> ;
As -> a As;
EOF
        else
          write_grammar <<EOF
<<
#include <string.h>
#include <stdlib.h>
>>
context_user_fields <<
    char * comments;
    unsigned int acount;
>>
drop /\\s+/;
drop /#(.*)\\n/ <<
    size_t cur_len = 0u;
    if (${context.comments} != NULL)
        cur_len = strlen(${context.comments});
    char * commentsnew = (char *)malloc(cur_len + match_length + 1);
    if (${context.comments} != NULL)
        memcpy(commentsnew, ${context.comments}, cur_len);
    memcpy(&commentsnew[cur_len], match, match_length);
    commentsnew[cur_len + match_length] = '\\0';
    if (${context.comments} != NULL)
    {
        free(${context.comments});
    }
    ${context.comments} = commentsnew;
>>
token a <<
    ${context.acount}++;
>>
Start -> As;
As -> ;
As -> a As;
EOF
        end
        run_propane(language: language)
        compile("spec/test_user_context_fields.#{language}", language: language)
        results = run_test(language: language)
        expect(results.stderr).to include %r{comments: # comment 1\n#    comment 2}
        expect(results.stderr).to include %r{acount: 11\n}
        expect(results.status).to eq 0
      end
    end
  end
end
