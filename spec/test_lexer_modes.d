import testparser;
import std.stdio;

int main()
{
    return 0;
}

unittest
{
    string input = `abc "a string" def`;
    auto parser = new Parser(input);
    assert(parser.parse() == P_SUCCESS);
    writeln("pass1");

    input = `abc "abc def" def`;
    parser = new Parser(input);
    assert(parser.parse() == P_SUCCESS);
    writeln("pass2");
}
