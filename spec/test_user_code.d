import testparser;
import std.stdio;

int main()
{
    return 0;
}

unittest
{
    string input = "abcdef";
    auto parser = new Parser(input);
    assert(parser.parse() == P_SUCCESS);
    writeln("pass1");

    input = "abcabcdef";
    parser = new Parser(input);
    assert(parser.parse() == P_SUCCESS);
    writeln("pass2");
}
