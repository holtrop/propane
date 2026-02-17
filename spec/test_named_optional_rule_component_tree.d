import testparser;
import std.stdio;
import testutils;

int main()
{
    return 0;
}

unittest
{
    string input = "b";
    p_context_t * context;
    context = p_context_new(input);
    assert(p_parse(context) == P_SUCCESS);
    Start * start = p_result(context);
    assert(start.pToken1 is null);
    assert(start.pToken2 !is null);
    assert_eq(TOKEN_b, start.pToken2.token);
    assert(start.pR3 is null);
    assert(start.pR is null);
    assert(start.r is null);

    input = "abcd";
    context = p_context_new(input);
    assert(p_parse(context) == P_SUCCESS);
    start = p_result(context);
    assert(start.pToken1 != null);
    assert_eq(TOKEN_a, start.pToken1.token);
    assert(start.pToken2 != null);
    assert(start.pR3 != null);
    assert(start.pR != null);
    assert(start.r != null);
    assert(start.pR == start.pR3);
    assert(start.pR == start.r);
    assert_eq(TOKEN_c, start.pR.pToken1.token);

    input = "bdc";
    context = p_context_new(input);
    assert(p_parse(context) == P_SUCCESS);
    start = p_result(context);
    assert(start.pToken1 is null);
    assert(start.pToken2 !is null);
    assert(start.pR !is null);
    assert_eq(TOKEN_d, start.pR.pToken1.token);
}
