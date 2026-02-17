import testparser;
import std.stdio;

int main()
{
    return 0;
}

unittest
{
    string input = "a";
    p_context_t * context;
    context = p_context_new(input);
    assert(p_parse(context) == P_SUCCESS);
    assert(p_result(context) == 1u);

    input = "";
    context = p_context_new(input);
    assert(p_parse(context) == P_SUCCESS);
    assert(p_result(context) == 0u);

    input = "aaaaaaaaaaaaaaaa";
    context = p_context_new(input);
    assert(p_parse(context) == P_SUCCESS);
    assert(p_result(context) == 16u);
}
