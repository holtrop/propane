import testparser;
import testutils;

/* Grammar: see test_parse_inner_nested_tree.c. */

size_t mylexfn(p_context_t * context, p_token_info_t * out_token_info)
{
    size_t result = p_lex(context, out_token_info);
    if (result != P_SUCCESS)
    {
        return result;
    }
    if (out_token_info.token == TOKEN_lparen)
    {
        p_position_t start_position = out_token_info.position;
        /* Reentrant nested parse of the parenthesized sub-expression. */
        p_token_t[] follow_tokens = [TOKEN_rparen];
        size_t inner_result = p_parse_inner_Start(context, follow_tokens);
        if (inner_result != P_SUCCESS)
        {
            return inner_result;
        }
        Start * inner = p_result_Start(context);
        assert(inner !is null);
        /* p_parse_inner rewound the input so that ')' was not consumed; consume
         * it now. */
        p_token_info_t rparen_info;
        size_t rparen_result = p_lex(context, &rparen_info);
        assert(rparen_result == P_SUCCESS);
        assert(rparen_info.token == TOKEN_rparen);
        /* The subtree covers the region strictly between the parentheses. */
        assert_eq(start_position.col + 1u, inner.position.col);
        assert_eq(rparen_info.position.col - 1u, inner.end_position.col);
        p_tree_delete_Start(inner);
        /* Synthesize a num token spanning the entire "( ... )" group. */
        out_token_info.token = TOKEN_num;
        out_token_info.position = start_position;
        out_token_info.end_position = rparen_info.end_position;
    }
    return P_SUCCESS;
}

int main()
{
    return 0;
}

unittest
{
    /* "(3 + 4) + (5 + 6)": two parenthesized groups, each collapsed by the
     * lexer into a single num token spanning its group. */
    string input = "(3 + 4) + (5 + 6)";
    p_context_t * context = p_context_new(input);
    assert(p_parse(context) == P_SUCCESS);

    Start * tree = p_result(context);
    assert(tree !is null);

    /* Start -> Expr, where the top Expr is "Expr plus num". */
    Expr * top = tree.pExpr;
    assert(top !is null);
    assert(top.pExpr !is null);
    assert(top.pToken2 !is null);
    assert(top.pToken3 !is null);

    /* The '+' joining the two groups is at column 9. */
    assert_eq(1u, top.pToken2.position.row);
    assert_eq(9u, top.pToken2.position.col);

    /* Right operand: synthesized num for "(5 + 6)", spanning columns 11..17. */
    assert_eq(1u, top.pToken3.position.row);
    assert_eq(11u, top.pToken3.position.col);
    assert_eq(1u, top.pToken3.end_position.row);
    assert_eq(17u, top.pToken3.end_position.col);

    /* Left operand: Expr -> num, the synthesized num for "(3 + 4)", spanning
     * columns 1..7. */
    Expr * left = top.pExpr;
    assert(left.pToken1 !is null);
    assert_eq(1u, left.pToken1.position.row);
    assert_eq(1u, left.pToken1.position.col);
    assert_eq(1u, left.pToken1.end_position.row);
    assert_eq(7u, left.pToken1.end_position.col);

    /* The whole tree spans columns 1..17. */
    assert_eq(1u, tree.position.col);
    assert_eq(17u, tree.end_position.col);

    p_tree_delete(tree);
    p_context_delete(context);
}
