import testparser;
import std.stdio;

int main()
{
    return 0;
}

unittest
{
    string input = `abc "a string" def`;
    p_context_t context;
    p_context_init(&context, input);
    assert(p_parse(&context) == P_SUCCESS);
    writeln("pass1");

    input = `abc "abc def" def`;
    p_context_init(&context, input);
    assert(p_parse(&context) == P_SUCCESS);
    writeln("pass2");
}
