import testparser;
import std.stdio;

int main()
{
    return 0;
}

unittest
{
    string input = "ab";
    auto parser = new Testparser.Parser(cast(const(ubyte) *)input.ptr, input.length);
    assert(parser.parse() == true);
}
