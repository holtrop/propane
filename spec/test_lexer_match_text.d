import testparser;
import std.stdio;

int main()
{
    return 0;
}

unittest
{
    string input = `identifier_123`;
    auto parser = new Testparser.Parser(input);
    assert(parser.parse() == Testparser.Parser.P_SUCCESS);
    writeln("pass1");
}
