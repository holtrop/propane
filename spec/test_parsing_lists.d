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
    assert(parser.parse() == P_SUCCESS);
    assert(parser.result == 1u);

    input = "";
    parser = new Parser(input);
    assert(parser.parse() == P_SUCCESS);
    assert(parser.result == 0u);

    input = "aaaaaaaaaaaaaaaa";
    parser = new Parser(input);
    assert(parser.parse() == P_SUCCESS);
    assert(parser.result == 16u);
}
