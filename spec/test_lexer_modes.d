import testparser;
import std.stdio;

int main()
{
    return 0;
}

unittest
{
    string input = `abc "a string" def`;
    auto parser = new Testparser.Parser(input);
    assert(parser.parse() == Testparser.Parser.P_SUCCESS);
    writeln("pass1");

    input = `abc "abc def" def`;
    parser = new Testparser.Parser(input);
    assert(parser.parse() == Testparser.Parser.P_SUCCESS);
    writeln("pass2");
}
