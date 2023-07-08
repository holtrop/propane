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
    assert(parser.parse() == Testparser.P_UNEXPECTED_TOKEN);

    input = "a b";
    parser = new Testparser.Parser(input);
    assert(parser.parse() == Testparser.P_SUCCESS);

    input = "bb";
    parser = new Testparser.Parser(input);
    assert(parser.parse() == Testparser.P_SUCCESS);
}
