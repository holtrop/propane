import testparser;
import std.stdio;

int main()
{
    return 0;
}

unittest
{
    string input = `abc "a string" def`;
    auto parser = new Testparser.Parser(cast(const(ubyte) *)input.ptr, input.length);
    assert(parser.parse() == true);
    writeln("pass1");

    input = `abc "abc def" def`;
    parser = new Testparser.Parser(cast(const(ubyte) *)input.ptr, input.length);
    assert(parser.parse() == true);
    writeln("pass2");
}
