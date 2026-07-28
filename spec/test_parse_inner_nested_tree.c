#include "testparser.h"
#include <assert.h>
#include <string.h>
#include "testutils.h"

/* Grammar: see the D variant / spec. Tree generation mode; parentheses handled
 * by the lex function. Tree nodes live in the context arena. */

size_t mylexfn(p_context_t * context, p_token_info_t * out_token_info)
{
    size_t result = p_lex(context, out_token_info);
    if (result != P_SUCCESS)
    {
        return result;
    }
    if (out_token_info->token == TOKEN_lparen)
    {
        p_position_t start_position = out_token_info->position;
        /* Reentrant nested parse of the parenthesized sub-expression. */
        p_token_t follow_tokens[] = { TOKEN_rparen };
        size_t inner_result = p_parse_inner_Start(context, follow_tokens, 1u);
        if (inner_result != P_SUCCESS)
        {
            return inner_result;
        }
        Start inner = p_result_Start(context);
        assert(p_node_valid(inner));
        /* p_parse_inner rewound the input so that ')' was not consumed; consume
         * it now. */
        p_token_info_t rparen_info;
        size_t rparen_result = p_lex(context, &rparen_info);
        assert(rparen_result == P_SUCCESS);
        assert(rparen_info.token == TOKEN_rparen);
        /* The subtree covers the region strictly between the parentheses. */
        assert_eq((size_t)(start_position.col + 1u), (size_t)p_node_position(inner).col);
        assert_eq((size_t)(rparen_info.position.col - 1u), (size_t)p_node_end_position(inner).col);
        /* The inner subtree is discarded (the lexer synthesizes a num token in
         * its place), but its nodes remain in the shared context arena and are
         * freed with the context. */
        out_token_info->token = TOKEN_num;
        out_token_info->position = start_position;
        out_token_info->end_position = rparen_info.end_position;
    }
    return P_SUCCESS;
}

int main()
{
    /* "(3 + 4) + (5 + 6)": two parenthesized groups, each collapsed by the
     * lexer into a single num token spanning its group. */
    char const * input = "(3 + 4) + (5 + 6)";
    p_context_t * context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse(context) == P_SUCCESS);

    Start tree = p_result(context);
    assert(p_node_valid(tree));

    /* Start -> Expr, where the top Expr is "Expr plus num". */
    Expr top = p_Start_pExpr(tree);
    assert(p_node_valid(top));
    assert(p_node_valid(p_Expr_pExpr(top)));
    assert(p_node_valid(p_Expr_pToken2(top)));
    assert(p_node_valid(p_Expr_pToken3(top)));

    /* The '+' joining the two groups is at column 9. */
    assert_eq(1u, (size_t)p_node_position(p_Expr_pToken2(top)).row);
    assert_eq(9u, (size_t)p_node_position(p_Expr_pToken2(top)).col);

    /* Right operand: synthesized num for "(5 + 6)", spanning columns 11..17. */
    assert_eq(1u, (size_t)p_node_position(p_Expr_pToken3(top)).row);
    assert_eq(11u, (size_t)p_node_position(p_Expr_pToken3(top)).col);
    assert_eq(1u, (size_t)p_node_end_position(p_Expr_pToken3(top)).row);
    assert_eq(17u, (size_t)p_node_end_position(p_Expr_pToken3(top)).col);

    /* Left operand: Expr -> num, the synthesized num for "(3 + 4)", spanning
     * columns 1..7. */
    Expr left = p_Expr_pExpr(top);
    assert(p_node_valid(p_Expr_pToken1(left)));
    assert_eq(1u, (size_t)p_node_position(p_Expr_pToken1(left)).row);
    assert_eq(1u, (size_t)p_node_position(p_Expr_pToken1(left)).col);
    assert_eq(1u, (size_t)p_node_end_position(p_Expr_pToken1(left)).row);
    assert_eq(7u, (size_t)p_node_end_position(p_Expr_pToken1(left)).col);

    /* The whole tree spans columns 1..17. */
    assert_eq(1u, (size_t)p_node_position(tree).col);
    assert_eq(17u, (size_t)p_node_end_position(tree).col);

    p_context_delete(context);

    return 0;
}
