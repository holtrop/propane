import testparser;
import std.stdio;
import testutils;

int main()
{
    return 0;
}

unittest
{
    /* See test_parse_inner_recursive.c for details on the grammar. */

    /* Standard parse of `c` succeeds. */
    string input = "c";
    p_context_t * context = p_context_new(input);
    assert(p_parse_Start(context) == P_SUCCESS);
    assert(p_result_Start(context) == 3);

    /* Standard parse of `acb` succeeds. */
    input = "acb";
    context = p_context_new(input);
    assert(p_parse_Start(context) == P_SUCCESS);
    assert(p_result_Start(context) == 3);

    /* Standard parse of `ac` fails. */
    input = "ac";
    context = p_context_new(input);
    assert(p_parse_Start(context) == P_UNEXPECTED_TOKEN);

    /* parse_inner with `ac` fails: outer rule still on the stack. */
    input = "ac";
    context = p_context_new(input);
    p_token_t[] follow_tokens_bothway = [TOKEN_b, TOKEN___EOF];
    assert(p_parse_inner_Start(context, follow_tokens_bothway) == P_UNEXPECTED_TOKEN);

    /* parse_inner with `acb` succeeds via the standard path. */
    input = "acb";
    context = p_context_new(input);
    p_token_t[] follow_tokens_b = [TOKEN_b];
    assert(p_parse_inner_Start(context, follow_tokens_b) == P_SUCCESS);
    assert(p_result_Start(context) == 3);

    /* parse_inner with just `c` succeeds via the standard path. */
    input = "c";
    context = p_context_new(input);
    assert(p_parse_inner_Start(context, follow_tokens_b) == P_SUCCESS);
    assert(p_result_Start(context) == 3);
}
