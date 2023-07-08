import testparser;
import std.stdio;

int main()
{
    return 0;
}

unittest
{
    string input = `x`;
    auto parser = new Testparser.Parser(input);
    assert(parser.parse() == Testparser.P_SUCCESS);
    assert(parser.result == 1u);

    input = `fabulous`;
    parser = new Testparser.Parser(input);
    assert(parser.parse() == Testparser.P_SUCCESS);
    assert(parser.result == 8u);
}
