import testparser;
import std.stdio;
import testutils;

int main()
{
    return 0;
}

unittest
{
    string input = "\na\nb\nc";
    p_context_t * context;
    context = p_context_new(input);
    assert(p_parse(context) == P_SUCCESS);
    Start * start = p_result(context);

    assert_eq(TOKEN_a, start.first.pToken.token);
    assert_eq(TOKEN_b, start.second.pToken.token);
    assert_eq(TOKEN_c, start.third.pToken.token);
}
