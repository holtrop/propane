import testparser;
import std.stdio;

int main()
{
    return 0;
}

unittest
{
    string input = "aba";
    auto parser = new Testparser.Parser(input);
    assert(parser.parse() == Testparser.P_SUCCESS);

    input = "abb";
    parser = new Testparser.Parser(input);
    assert(parser.parse() == Testparser.P_SUCCESS);
}
