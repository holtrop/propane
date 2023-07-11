import testparser;
import std.stdio;

int main()
{
    return 0;
}

unittest
{
    string input = `identifier_123`;
    auto parser = new Parser(input);
    assert(parser.parse() == P_SUCCESS);
    writeln("pass1");
}
