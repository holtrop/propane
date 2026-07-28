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
    p_context_t * context = p_context_new(input);
    assert(p_parse(context) == P_SUCCESS);
    Start start = p_result(context);
    assert(!start.pToken1.valid);
    assert(start.pToken2.valid);
    assert_eq(TOKEN_b, start.pToken2.token);
    assert(!start.pR3.valid);
    assert(!start.pR.valid);

    p_context_delete(context);

    input = "abcd";
    context = p_context_new(input);
    assert(p_parse(context) == P_SUCCESS);
    start = p_result(context);
    assert(start.pToken1.valid);
    assert_eq(TOKEN_a, start.pToken1.token);
    assert(start.pToken2.valid);
    assert(start.pR3.valid);
    assert(start.pR.valid);
    assert(start.pR == start.pR3);
    assert_eq(TOKEN_c, start.pR.pToken1.token);

    p_context_delete(context);

    input = "bdc";
    context = p_context_new(input);
    assert(p_parse(context) == P_SUCCESS);
    start = p_result(context);
    assert(!start.pToken1.valid);
    assert(start.pToken2.valid);
    assert(start.pR.valid);
    assert_eq(TOKEN_d, start.pR.pToken1.token);

    p_context_delete(context);
}
