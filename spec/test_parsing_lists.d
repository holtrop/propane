import testparser;
import std.stdio;

int main()
{
    return 0;
}

unittest
{
    string input = "a";
    auto parser = new Testparser.Parser(cast(const(ubyte) *)input.ptr, input.length);
    assert(parser.parse() == true);
    assert(parser.result == 1u);

    input = "";
    parser = new Testparser.Parser(cast(const(ubyte) *)input.ptr, input.length);
    assert(parser.parse() == true);
    assert(parser.result == 0u);

    input = "aaaaaaaaaaaaaaaa";
    parser = new Testparser.Parser(cast(const(ubyte) *)input.ptr, input.length);
    assert(parser.parse() == true);
    assert(parser.result == 16u);
}
