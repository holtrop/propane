require "fileutils"

describe Imbecile do
  def write_grammar(grammar)
    File.write("spec/run/testparser.i", grammar)
  end

  def build_parser
    result = system(*%w[./imbecile.sh spec/run/testparser.i spec/run/testparser.d])
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
token int \\d+
token plus \\+
token times \\*
drop \\s+
Start: [] <<
>>
EOF
    build_parser
    compile("spec/test_d_lexer.d")
    run
  end
end
