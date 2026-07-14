import testparser;
import testutils;

/* Grammar: see test_parse_inner_nested.c. */

size_t mylexfn(p_context_t * context, p_token_info_t * out_token_info)
{
    size_t result = p_lex(context, out_token_info);
    if (result != P_SUCCESS)
    {
        return result;
    }
    if (out_token_info.token == TOKEN_lparen)
    {
        /* Nested parse of the parenthesized sub-expression, stopping at the
         * closing ')' follow token. This re-enters the parser while the outer
         * parse is suspended in this lex callback. */
        p_token_t[] follow_tokens = [TOKEN_rparen];
        size_t inner_result = p_parse_inner_Start(context, follow_tokens);
        if (inner_result != P_SUCCESS)
        {
            return inner_result;
        }
        int value = p_result_Start(context);
        /* p_parse_inner rewound the input so that ')' was not consumed; consume
         * it now. */
        p_token_info_t rparen_info;
        size_t rparen_result = p_lex(context, &rparen_info);
        assert(rparen_result == P_SUCCESS);
        assert(rparen_info.token == TOKEN_rparen);
        /* Replace the '(' token with a synthesized num carrying the nested
         * parse result. */
        out_token_info.token = TOKEN_num;
        out_token_info.pvalue.v_default = value;
    }
    return P_SUCCESS;
}

int eval(string input)
{
    p_context_t * context = p_context_new(input);
    assert(p_parse(context) == P_SUCCESS);
    int value = p_result(context);
    p_context_delete(context);
    return value;
}

int main()
{
    return 0;
}

unittest
{
    /* No parentheses: plain outer parse. */
    assert_eq(5, eval("2 + 3"));
    /* A single group evaluated by the nested parse. */
    assert_eq(3, eval("(1 + 2)"));
    /* A group in the middle of an outer expression. */
    assert_eq(14, eval("2 + (3 + 4) + 5"));
    /* Nested groups: the nested parse re-enters itself. */
    assert_eq(37, eval("2 + (10 + (20 + 5))"));
    assert_eq(15, eval("(1 + 2) + (3 + (4 + 5))"));
}
