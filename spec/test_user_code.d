import testparser;
import std.stdio;

int main()
{
    return 0;
}

unittest
{
    string input = "abcdef";
    auto parser = new Testparser.Parser(input);
    assert(parser.parse() == Testparser.Parser.P_SUCCESS);
    writeln("pass1");

    input = "abcabcdef";
    parser = new Testparser.Parser(input);
    assert(parser.parse() == Testparser.Parser.P_SUCCESS);
    writeln("pass2");
}
