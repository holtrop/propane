#include "testparser.h"
#include <assert.h>
#include <string.h>
#include "testutils.h"

int main()
{
    /* Grammar (recursive):
     *   Start -> a Start b   << $$ = $2; >>
     *   Start -> c           << $$ = $1; >>
     *   token a << $$ = 1; >>
     *   token b << $$ = 2; >>
     *   token c << $$ = 3; >>
     *
     * Here `Start` can appear in the middle of another `Start` rule, so the
     * inner-parse follow-token success must be blocked whenever an unfinished
     * outer `Start -> a Start b` remains on the parse stack (i.e. the parse
     * stack contains more than just the initial state and the reduced start
     * rule set). */

    /* Standard parse of `c` succeeds. */
    char const * input = "c";
    p_context_t * context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse_Start(context) == P_SUCCESS);
    assert_eq(3u, (size_t)p_result_Start(context));
    p_context_delete(context);

    /* Standard parse of `acb` succeeds (full outer rule). */
    input = "acb";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse_Start(context) == P_SUCCESS);
    assert_eq(3u, (size_t)p_result_Start(context));
    p_context_delete(context);

    /* Standard parse of `ac` fails (`b` missing). */
    input = "ac";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse_Start(context) == P_UNEXPECTED_TOKEN);
    p_context_delete(context);

    /* parse_inner with `ac` and follow token `b` also fails: even though the
     * inner `Start -> c` reduces and `Start` is shifted, the outer
     * `Start -> a Start . b` is still on the stack (stack length > 2), so the
     * "reduced start rule is the only thing on the parse stack" invariant
     * blocks the shift-side follow-token success. */
    {
        input = "ac";
        context = p_context_new((uint8_t const *)input, strlen(input));
        p_token_t follow_tokens[] = { TOKEN_b, TOKEN___EOF };
        assert(p_parse_inner_Start(context, follow_tokens, 2u) == P_UNEXPECTED_TOKEN);
        p_context_delete(context);
    }

    /* parse_inner with `acb` (complete outer rule) succeeds via the standard
     * path. */
    {
        input = "acb";
        context = p_context_new((uint8_t const *)input, strlen(input));
        p_token_t follow_tokens[] = { TOKEN_b };
        assert(p_parse_inner_Start(context, follow_tokens, 1u) == P_SUCCESS);
        assert_eq(3u, (size_t)p_result_Start(context));
        p_context_delete(context);
    }

    /* parse_inner with just `c` succeeds via the standard path even when a
     * follow-token vector is supplied. */
    {
        input = "c";
        context = p_context_new((uint8_t const *)input, strlen(input));
        p_token_t follow_tokens[] = { TOKEN_b };
        assert(p_parse_inner_Start(context, follow_tokens, 1u) == P_SUCCESS);
        assert_eq(3u, (size_t)p_result_Start(context));
        p_context_delete(context);
    }

    return 0;
}
