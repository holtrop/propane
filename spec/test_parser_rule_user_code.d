import testparser;
import std.stdio;

int main()
{
    return 0;
}

unittest
{
    string input = "ab";
    auto parser = new Parser(input);
    assert(parser.parse() == P_SUCCESS);
}
