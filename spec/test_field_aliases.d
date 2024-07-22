import testparser;
import std.stdio;

int main()
{
    return 0;
}

unittest
{
    string input = "foo1\nbar2";
    p_context_t context;
    p_context_init(&context, input);
    assert(p_parse(&context) == P_SUCCESS);
}
