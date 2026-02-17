import testparser;
import std.stdio;
import testutils;

int main()
{
    return 0;
}

unittest
{
    string input = "bbbb";
    p_context_t * context;
    context = p_context_new(input);
    assert(p_parse(context) == P_SUCCESS);
    int result = p_result(context);
    assert(result == 8);

    context = p_context_new(input);
    assert(p_parse_Bs(context) == P_SUCCESS);
    result = p_result_Bs(context);
    assert(result == 8);

    input = "c";
    context = p_context_new(input);
    assert(p_parse_R(context) == P_SUCCESS);
    result = p_result_R(context);
    assert(result == 3);
}
