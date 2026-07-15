#include "testparser.h"
#include <assert.h>
#include <string.h>
#include "testutils.h"

/* Grammar (integer evaluator; parentheses handled by the lex function):
 *   ptype int;
 *   lex_fn mylexfn;
 *   token lparen /\(/; token rparen /\)/; token plus /\+/;
 *   token num /\d+/          << ... atoi ... >>
 *   Start -> Expr            << $$ = $1; >>
 *   Expr  -> num             << $$ = $1; >>
 *   Expr  -> Expr plus num   << $$ = $1 + $3; >>
 *
 * The tokens lparen and rparen appear in no grammar rule. Instead, when the
 * lex function lexes a '(', it performs a nested parse (p_parse_inner_Start)
 * of the parenthesized sub-expression -- reentrantly, while the outer parse is
 * still suspended in this callback -- reads the computed value with
 * p_result_Start, consumes the ')' that p_parse_inner deliberately left in the
 * input, and hands a single synthesized num token carrying that value back to
 * the outer parse. Nested groups recurse this process to arbitrary depth. */

size_t mylexfn(p_context_t * context, p_token_info_t * out_token_info)
{
    size_t result = p_lex(context, out_token_info);
    if (result != P_SUCCESS)
    {
        return result;
    }
    if (out_token_info->token == TOKEN_lparen)
    {
        /* Nested parse of the parenthesized sub-expression, stopping at the
         * closing ')' follow token. This re-enters the parser while the outer
         * parse is suspended in this lex callback. */
        p_token_t follow_tokens[] = { TOKEN_rparen };
        size_t inner_result = p_parse_inner_Start(context, follow_tokens, 1u);
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
        out_token_info->token = TOKEN_num;
        out_token_info->pvalue = p_value(value);
    }
    return P_SUCCESS;
}

static int eval(char const * input)
{
    p_context_t * context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse(context) == P_SUCCESS);
    int value = p_result(context);
    p_context_delete(context);
    return value;
}

int main()
{
    /* No parentheses: plain outer parse. */
    assert_eq(5u, (size_t)eval("2 + 3"));
    /* A single group evaluated by the nested parse. */
    assert_eq(3u, (size_t)eval("(1 + 2)"));
    /* A group in the middle of an outer expression. */
    assert_eq(14u, (size_t)eval("2 + (3 + 4) + 5"));
    /* Nested groups: the nested parse re-enters itself. */
    assert_eq(37u, (size_t)eval("2 + (10 + (20 + 5))"));
    assert_eq(15u, (size_t)eval("(1 + 2) + (3 + (4 + 5))"));

    return 0;
}
