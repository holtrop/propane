import testparser;
import std.stdio;

int main()
{
    return 0;
}

unittest
{
    string input = "a";
    auto parser = new Parser(input);
    assert(parser.parse() == P_UNEXPECTED_TOKEN);

    input = "a b";
    parser = new Parser(input);
    assert(parser.parse() == P_SUCCESS);

    input = "bb";
    parser = new Parser(input);
    assert(parser.parse() == P_SUCCESS);
}
