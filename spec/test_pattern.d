import testparser;
import std.stdio;

int main()
{
    return 0;
}

unittest
{
    string input = "abcdef";
    auto parser = new Testparser.Parser(cast(const(ubyte) *)input.ptr, input.length);
    assert(parser.parse() == true);
    writeln("pass1");

    input = "defabcdef";
    parser = new Testparser.Parser(cast(const(ubyte) *)input.ptr, input.length);
    assert(parser.parse() == true);
    writeln("pass2");
}
