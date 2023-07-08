import testparser;
import std.stdio;

int main()
{
    return 0;
}

unittest
{
    string input = "a";
    auto parser = new Testparser.Parser(input);
    assert(parser.parse() == Testparser.P_SUCCESS);
    assert(parser.result == 1u);

    input = "";
    parser = new Testparser.Parser(input);
    assert(parser.parse() == Testparser.P_SUCCESS);
    assert(parser.result == 0u);

    input = "aaaaaaaaaaaaaaaa";
    parser = new Testparser.Parser(input);
    assert(parser.parse() == Testparser.P_SUCCESS);
    assert(parser.result == 16u);
}
