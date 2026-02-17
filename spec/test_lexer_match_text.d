import testparser;
import std.stdio;

int main()
{
    return 0;
}

unittest
{
    string input = `identifier_123`;
    p_context_t * context;
    context = p_context_new(input);
    assert(p_parse(context) == P_SUCCESS);
    writeln("pass1");
}
