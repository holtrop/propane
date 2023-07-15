import testparser;
import std.stdio;
import testutils;

int main()
{
    return 0;
}

unittest
{
    string input = "1 + 2 * 3 + 4";
    p_context_t context;
    p_context_init(&context, input);
    assert_eq(P_SUCCESS, p_parse(&context));
    assert_eq(11, p_result(&context));

    input = "1 * 2 ** 4 * 3";
    p_context_init(&context, input);
    assert_eq(P_SUCCESS, p_parse(&context));
    assert_eq(48, p_result(&context));

    input = "(1 + 2) * 3 + 4";
    p_context_init(&context, input);
    assert_eq(P_SUCCESS, p_parse(&context));
    assert_eq(13, p_result(&context));

    input = "(2 * 2) ** 3 + 4 + 5";
    p_context_init(&context, input);
    assert_eq(P_SUCCESS, p_parse(&context));
    assert_eq(73, p_result(&context));
}
