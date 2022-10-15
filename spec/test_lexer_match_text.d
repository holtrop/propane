import testparser;
import std.stdio;

int main()
{
    return 0;
}

unittest
{
    string input = `identifier_123`;
    auto parser = new Testparser.Parser(input);
    assert(parser.parse() == true);
    writeln("pass1");
}
