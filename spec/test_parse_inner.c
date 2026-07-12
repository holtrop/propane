#include "testparser.h"
#include <assert.h>
#include <string.h>
#include "testutils.h"

int main()
{
    /* Grammar (chain reduce):
     *   Start -> Y      << $$ = $1; >>
     *   Y     -> a      << $$ = $1; >>
     *   token a         << $$ = 1; >>
     *
     * The reduce lookahead for both `Y -> a` and `Start -> Y` is only $EOF,
     * so `p_parse_Start("ab")` fails at token `b`. p_parse_inner_Start with
     * `b` as a follow token should succeed via the reduce-side retry chain
     * (Y then Start) followed by the shift-side retry hitting $EOF at the
     * final state. */

    /* Standard parse succeeds on complete input. */
    char const * input = "a";
    p_context_t * context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse_Start(context) == P_SUCCESS);
    assert_eq(1u, (size_t)p_result_Start(context));
    p_context_delete(context);

    /* Standard parse fails when there's an unexpected trailing token. */
    input = "ab";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse_Start(context) == P_UNEXPECTED_TOKEN);
    p_context_delete(context);

    /* parse_inner succeeds via a chain of reduce retries (Y, then Start),
     * followed by the shift-side retry hitting $EOF at the final state. */
    {
        input = "ab";
        context = p_context_new((uint8_t const *)input, strlen(input));
        p_token_t follow_tokens[] = { TOKEN_b };
        assert(p_parse_inner_Start(context, follow_tokens, 1u) == P_SUCCESS);
        assert_eq(1u, (size_t)p_result_Start(context));
        p_context_delete(context);
    }

    /* parse_inner with an empty (NULL) follow-token vector behaves like a
     * standard parse. */
    input = "ab";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse_inner_Start(context, NULL, 0u) == P_UNEXPECTED_TOKEN);
    p_context_delete(context);

    /* parse_inner behaves like a standard parse when the input matches the
     * grammar fully. */
    input = "a";
    context = p_context_new((uint8_t const *)input, strlen(input));
    {
        p_token_t follow_tokens[] = { TOKEN_b };
        assert(p_parse_inner_Start(context, follow_tokens, 1u) == P_SUCCESS);
        assert_eq(1u, (size_t)p_result_Start(context));
    }
    p_context_delete(context);

    /* parse_inner with a non-matching follow token still fails. The grammar
     * can't consume `b` and it isn't listed as a follow token, so the retries
     * do not fire. */
    {
        input = "ab";
        context = p_context_new((uint8_t const *)input, strlen(input));
        p_token_t follow_tokens[] = { TOKEN___EOF };
        assert(p_parse_inner_Start(context, follow_tokens, 1u) == P_UNEXPECTED_TOKEN);
        p_context_delete(context);
    }

    return 0;
}
