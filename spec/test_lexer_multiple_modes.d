import testparser;
import std.stdio;

int main()
{
    return 0;
}

unittest
{
    string input = `abc.def`;
    p_context_t context;
    p_context_init(&context, input);
    assert(p_parse(&context) == P_SUCCESS);
    writeln("pass1");

    input = `abc .  abc`;
    p_context_init(&context, input);
    assert(p_parse(&context) == P_SUCCESS);
    writeln("pass2");
}
