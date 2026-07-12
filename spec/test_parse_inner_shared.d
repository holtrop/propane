import testparser;
import std.stdio;
import testutils;

int main()
{
    return 0;
}

unittest
{
    /* See test_parse_inner_shared.c for details on the grammar. */

    /* Sanity-check that parse_Start resolves R1 vs R2 via lookahead. */
    string input = "aba";
    p_context_t * context = p_context_new(input);
    assert(p_parse_Start(context) == P_SUCCESS);

    input = "abb";
    context = p_context_new(input);
    assert(p_parse_Start(context) == P_SUCCESS);

    /* Standard parse of R1 succeeds on "ab". */
    input = "ab";
    context = p_context_new(input);
    assert(p_parse_R1(context) == P_SUCCESS);
    assert(p_result_R1(context) == 11);

    /* Standard parse of R1 fails on "abb". */
    input = "abb";
    context = p_context_new(input);
    assert(p_parse_R1(context) == P_UNEXPECTED_TOKEN);

    /* parse_inner_R1("abb", [b]) succeeds: `b` is the lookahead that
     * parse_Start would use to select R2 over R1, but from R1's own start
     * state R1 reduces unconditionally, and the follow-token shift retry at
     * the R1-accepting state completes the parse. */
    input = "abb";
    context = p_context_new(input);
    p_token_t[] follow_tokens_b = [TOKEN_b];
    assert(p_parse_inner_R1(context, follow_tokens_b) == P_SUCCESS);
    assert(p_result_R1(context) == 11);

    /* parse_inner_R1("aba", [a]) also succeeds. */
    input = "aba";
    context = p_context_new(input);
    p_token_t[] follow_tokens_a = [TOKEN_a];
    assert(p_parse_inner_R1(context, follow_tokens_a) == P_SUCCESS);
    assert(p_result_R1(context) == 11);

    /* parse_inner_R1("ab", null) behaves like p_parse_R1("ab"). */
    input = "ab";
    context = p_context_new(input);
    assert(p_parse_inner_R1(context, null) == P_SUCCESS);
    assert(p_result_R1(context) == 11);
}
