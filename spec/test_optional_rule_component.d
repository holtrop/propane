import testparser;
import std.stdio;

int main()
{
    return 0;
}

unittest
{
    string input = "b";
    p_context_t context;
    p_context_init(&context, input);
    assert(p_parse(&context) == P_SUCCESS);

    input = "abcd";
    p_context_init(&context, input);
    assert(p_parse(&context) == P_SUCCESS);

    input = "abdc";
    p_context_init(&context, input);
    assert(p_parse(&context) == P_SUCCESS);
}
