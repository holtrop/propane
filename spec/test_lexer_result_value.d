import testparser;
import std.stdio;

int main()
{
    return 0;
}

unittest
{
    string input = `x`;
    p_context_t context;
    p_context_init(&context, input);
    assert(p_parse(&context) == P_SUCCESS);
    assert(p_result(&context) == 1u);

    input = `fabulous`;
    p_context_init(&context, input);
    assert(p_parse(&context) == P_SUCCESS);
    assert(p_result(&context) == 8u);
}
