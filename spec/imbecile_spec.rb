require "fileutils"

def write_grammar(grammar)
  File.write("spec/run/test.i", grammar)
end

def build_parser
  result = system(*%w[./imbecile.sh spec/run/test.i spec/run/test.d])
  expect(result).to be_truthy
end

def compile
  result = system(*%w[gdc -o spec/run/test spec/run/test.d])
  expect(result).to be_truthy
end

describe Imbecile do
  before(:each) do
    FileUtils.rm_rf("spec/run")
    FileUtils.mkdir_p("spec/run")
  end

  it "generates a D lexer" do
    write_grammar <<EOF
token int \\d+
token plus \\+
token times \\*
drop \\s+
rule Start [] <<
>>
EOF
    build_parser
    compile
  end
end
