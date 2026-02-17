import testparser;
import std.stdio;
import testutils;

int main()
{
    return 0;
}

unittest
{
    string input = "hi";
    p_context_t * context;
    context = p_context_new(input);
    assert_eq(P_SUCCESS, p_parse(context));
    Top * top = p_result(context);
    assert(top.pToken !is null);
    assert_eq(TOKEN_hi, top.pToken.token);
}
