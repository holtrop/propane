#include "testparser.h"
#include <assert.h>
#include <string.h>
#include "testutils.h"

int main()
{
    /* Grammar:
     *   start Start;
     *   start R1;
     *   Start -> R1 a;
     *   Start -> R2 b;
     *   R1 -> a b   << $$ = 11; >>
     *   R2 -> a b   << $$ = 22; >>
     *   token a; token b;
     *
     * The rules `R1 -> a b` and `R2 -> a b` produce identical input. Within
     * parse_Start, the generated parser differentiates the reduce by
     * lookahead: `a` selects R1 (because `Start -> R1 a`) and `b` selects R2
     * (because `Start -> R2 b`). Within parse_R1, the reduce is unconditional
     * on any lookahead. This test exercises p_parse_inner_R1() to confirm
     * that reductions to R1 succeed even when the incoming follow token is
     * not the natural lookahead used by parse_Start's disambiguation. */

    /* Sanity-check that parse_Start resolves R1 vs R2 via lookahead in the
     * shared "a b" state. */
    char const * input = "aba";
    p_context_t * context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse_Start(context) == P_SUCCESS);
    p_context_delete(context);

    input = "abb";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse_Start(context) == P_SUCCESS);
    p_context_delete(context);

    /* Standard parse of R1 succeeds on "ab". */
    input = "ab";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse_R1(context) == P_SUCCESS);
    assert_eq(11u, (size_t)p_result_R1(context));
    p_context_delete(context);

    /* Standard parse of R1 fails on "abb" (unexpected trailing token). */
    input = "abb";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse_R1(context) == P_UNEXPECTED_TOKEN);
    p_context_delete(context);

    /* parse_inner_R1("abb", [b]) succeeds: even though `b` is the lookahead
     * that parse_Start uses to select R2 over R1 in the ambiguous state, from
     * R1's start state the reduce to R1 is unconditional, and the follow-
     * token shift retry at the R1-accepting state completes the parse.
     *
     * The follow token that completed the parse must not be consumed from
     * the input: p_position() should point to the follow token, and a
     * subsequent p_lex() should return it. */
    {
        input = "abb";
        context = p_context_new((uint8_t const *)input, strlen(input));
        p_token_t follow_tokens[] = { TOKEN_b };
        assert(p_parse_inner_R1(context, follow_tokens, 1u) == P_SUCCESS);
        assert_eq(11u, (size_t)p_result_R1(context));
        /* Follow token `b` is at column 3 (1-based). */
        p_position_t pos = p_position(context);
        assert_eq(1u, (size_t)pos.row);
        assert_eq(3u, (size_t)pos.col);
        p_token_info_t token_info;
        assert(p_lex(context, &token_info) == P_SUCCESS);
        assert_eq((size_t)TOKEN_b, (size_t)token_info.token);
        assert_eq(1u, (size_t)token_info.position.row);
        assert_eq(3u, (size_t)token_info.position.col);
        p_context_delete(context);
    }

    /* parse_inner_R1("aba", [a]) also succeeds: `a` is the follow token
     * parse_Start uses to select R1, and it works here as a follow token
     * too. */
    {
        input = "aba";
        context = p_context_new((uint8_t const *)input, strlen(input));
        p_token_t follow_tokens[] = { TOKEN_a };
        assert(p_parse_inner_R1(context, follow_tokens, 1u) == P_SUCCESS);
        assert_eq(11u, (size_t)p_result_R1(context));
        /* Follow token `a` is at column 3 (1-based) and remains in the
         * input. */
        p_position_t pos = p_position(context);
        assert_eq(1u, (size_t)pos.row);
        assert_eq(3u, (size_t)pos.col);
        p_token_info_t token_info;
        assert(p_lex(context, &token_info) == P_SUCCESS);
        assert_eq((size_t)TOKEN_a, (size_t)token_info.token);
        p_context_delete(context);
    }

    /* parse_inner_R1("ab", NULL) behaves like p_parse_R1("ab"). */
    input = "ab";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse_inner_R1(context, NULL, 0u) == P_SUCCESS);
    assert_eq(11u, (size_t)p_result_R1(context));
    p_context_delete(context);

    return 0;
}
