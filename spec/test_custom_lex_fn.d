import testparser;
import std.stdio;
import testutils;

int main()
{
    return 0;
}

unittest
{
    string input = "cbacba";
    p_context_t * context = p_context_new(input);
    assert_eq(P_SUCCESS, p_parse(context));
    size_t result = p_result(context);
    assert_eq(0x932187932187, result);
    p_context_delete(context);
}
