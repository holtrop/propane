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
    assert(parser.parse() == P_UNEXPECTED_INPUT);

    input = `123`;
    parser = new Parser(input);
    assert(parser.parse() == P_SUCCESS);
    assert(parser.result == 123u);
}
