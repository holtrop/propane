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
    assert(parser.parse() == false);

    input = "a b";
    parser = new Testparser.Parser(input);
    assert(parser.parse() == true);

    input = "bb";
    parser = new Testparser.Parser(input);
    assert(parser.parse() == true);
}
