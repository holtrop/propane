#include "testparser.h"
#include <assert.h>
#include <string.h>
#include "testutils.h"

/* Grammar (tree generation mode; parentheses handled by the lex function):
 *   tree;
 *   lex_fn mylexfn;
 *   token lparen /\(/; token rparen /\)/; token plus /\+/; token num /\d+/;
 *   Start -> Expr;
 *   Expr  -> num;
 *   Expr  -> Expr plus num;
 *
 * The same lexer-driven nested parse as test_parse_inner_nested, but in tree
 * generation mode. Each "( ... )" group is parsed by a reentrant
 * p_parse_inner_Start() call from the lex function; the resulting subtree is
 * discarded and a single synthesized num token is handed to the outer parse.
 * The synthesized token's position is set to span the whole group ('(' start
 * through ')' end), so this verifies that positions survive the nested-parse
 * boundary and land correctly in the outer tree. */

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
        Start * inner = p_result_Start(context);
        assert_not_null(inner);
        /* p_parse_inner rewound the input so that ')' was not consumed; consume
         * it now. */
        p_token_info_t rparen_info;
        size_t rparen_result = p_lex(context, &rparen_info);
        assert(rparen_result == P_SUCCESS);
        assert(rparen_info.token == TOKEN_rparen);
        /* The subtree covers the region strictly between the parentheses. */
        assert_eq((size_t)(start_position.col + 1u), (size_t)inner->position.col);
        assert_eq((size_t)(rparen_info.position.col - 1u), (size_t)inner->end_position.col);
        p_tree_delete_Start(inner);
        /* Synthesize a num token spanning the entire "( ... )" group. */
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

    Start * tree = p_result(context);
    assert_not_null(tree);

    /* Start -> Expr, where the top Expr is "Expr plus num". */
    Expr * top = tree->pExpr;
    assert_not_null(top);
    assert_not_null(top->pExpr);
    assert_not_null(top->pToken2);
    assert_not_null(top->pToken3);

    /* The '+' joining the two groups is at column 9. */
    assert_eq(1u, (size_t)top->pToken2->position.row);
    assert_eq(9u, (size_t)top->pToken2->position.col);

    /* Right operand: synthesized num for "(5 + 6)", spanning columns 11..17. */
    assert_eq(1u, (size_t)top->pToken3->position.row);
    assert_eq(11u, (size_t)top->pToken3->position.col);
    assert_eq(1u, (size_t)top->pToken3->end_position.row);
    assert_eq(17u, (size_t)top->pToken3->end_position.col);

    /* Left operand: Expr -> num, the synthesized num for "(3 + 4)", spanning
     * columns 1..7. */
    Expr * left = top->pExpr;
    assert_not_null(left->pToken1);
    assert_eq(1u, (size_t)left->pToken1->position.row);
    assert_eq(1u, (size_t)left->pToken1->position.col);
    assert_eq(1u, (size_t)left->pToken1->end_position.row);
    assert_eq(7u, (size_t)left->pToken1->end_position.col);

    /* The whole tree spans columns 1..17. */
    assert_eq(1u, (size_t)tree->position.col);
    assert_eq(17u, (size_t)tree->end_position.col);

    p_tree_delete(tree);
    p_context_delete(context);

    return 0;
}
