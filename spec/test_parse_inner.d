import testparser;
import std.stdio;
import testutils;

int main()
{
    return 0;
}

unittest
{
    /* See test_parse_inner.c for details on the grammar and cases. */

    /* Standard parse succeeds on complete input. */
    string input = "a";
    p_context_t * context = p_context_new(input);
    assert(p_parse_Start(context) == P_SUCCESS);
    assert(p_result_Start(context) == 1);

    /* Standard parse fails when there's an unexpected trailing token. */
    input = "ab";
    context = p_context_new(input);
    assert(p_parse_Start(context) == P_UNEXPECTED_TOKEN);

    /* parse_inner succeeds via a chain of reduce retries (Y, then Start),
     * followed by the shift-side retry hitting $EOF at the final state. */
    input = "ab";
    context = p_context_new(input);
    p_token_t[] follow_tokens_b = [TOKEN_b];
    assert(p_parse_inner_Start(context, follow_tokens_b) == P_SUCCESS);
    assert(p_result_Start(context) == 1);

    /* parse_inner with a null follow-token slice behaves like a standard
     * parse. */
    input = "ab";
    context = p_context_new(input);
    assert(p_parse_inner_Start(context, null) == P_UNEXPECTED_TOKEN);

    /* parse_inner behaves like a standard parse when the input matches the
     * grammar fully. */
    input = "a";
    context = p_context_new(input);
    assert(p_parse_inner_Start(context, follow_tokens_b) == P_SUCCESS);
    assert(p_result_Start(context) == 1);

    /* parse_inner with a non-matching follow token still fails. */
    input = "ab";
    context = p_context_new(input);
    p_token_t[] follow_tokens_eof = [TOKEN___EOF];
    assert(p_parse_inner_Start(context, follow_tokens_eof) == P_UNEXPECTED_TOKEN);
}
