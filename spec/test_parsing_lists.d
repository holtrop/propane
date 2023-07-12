import testparser;
import std.stdio;

int main()
{
    return 0;
}

unittest
{
    string input = "a";
    p_context_t context;
    p_context_init(&context, input);
    assert(p_parse(&context) == P_SUCCESS);
    assert(p_result(&context) == 1u);

    input = "";
    p_context_init(&context, input);
    assert(p_parse(&context) == P_SUCCESS);
    assert(p_result(&context) == 0u);

    input = "aaaaaaaaaaaaaaaa";
    p_context_init(&context, input);
    assert(p_parse(&context) == P_SUCCESS);
    assert(p_result(&context) == 16u);
}
