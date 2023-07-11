import testparser;
import std.stdio;

int main()
{
    return 0;
}

unittest
{
    string input = `x`;
    auto parser = new Parser(input);
    assert(parser.parse() == P_SUCCESS);
    assert(parser.result == 1u);

    input = `fabulous`;
    parser = new Parser(input);
    assert(parser.parse() == P_SUCCESS);
    assert(parser.result == 8u);
}
