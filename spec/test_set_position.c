#include "testparser.h"
#include <assert.h>
#include <string.h>
#include "testutils.h"

int main()
{
    /* Grammar (simple):
     *   token a; token b;
     *   Start -> a b;
     *
     * Verifies that p_set_position() overrides the default (1, 1) starting
     * position so that lexed tokens and error positions are reported
     * relative to the caller-supplied position. */

    /* Baseline: without p_set_position(), positions start at (1, 1). */
    {
        char const * input = "ab";
        p_context_t * context = p_context_new((uint8_t const *)input, strlen(input));
        p_position_t pos = p_position(context);
        assert_eq(1u, (size_t)pos.row);
        assert_eq(1u, (size_t)pos.col);
        p_token_info_t token_info;
        assert(p_lex(context, &token_info) == P_SUCCESS);
        assert_eq((size_t)TOKEN_a, (size_t)token_info.token);
        assert_eq(1u, (size_t)token_info.position.row);
        assert_eq(1u, (size_t)token_info.position.col);
        p_context_delete(context);
    }

    /* p_set_position() overrides the initial position; subsequent lex calls
     * report token positions relative to the set position. */
    {
        char const * input = "ab";
        p_context_t * context = p_context_new((uint8_t const *)input, strlen(input));
        p_position_t initial = {5u, 20u};
        p_set_position(context, initial);
        p_position_t pos = p_position(context);
        assert_eq(5u, (size_t)pos.row);
        assert_eq(20u, (size_t)pos.col);
        p_token_info_t token_info;
        assert(p_lex(context, &token_info) == P_SUCCESS);
        assert_eq((size_t)TOKEN_a, (size_t)token_info.token);
        assert_eq(5u, (size_t)token_info.position.row);
        assert_eq(20u, (size_t)token_info.position.col);
        assert(p_lex(context, &token_info) == P_SUCCESS);
        assert_eq((size_t)TOKEN_b, (size_t)token_info.token);
        assert_eq(5u, (size_t)token_info.position.row);
        assert_eq(21u, (size_t)token_info.position.col);
        p_context_delete(context);
    }

    /* p_set_position() before a full parse: successful parse still works and
     * text_position tracking is relative to the set starting point. */
    {
        char const * input = "ab";
        p_context_t * context = p_context_new((uint8_t const *)input, strlen(input));
        p_position_t initial = {3u, 7u};
        p_set_position(context, initial);
        assert(p_parse_Start(context) == P_SUCCESS);
        p_context_delete(context);
    }

    /* p_set_position() before a parse that fails: the reported error
     * position is relative to the set starting point. */
    {
        char const * input = "aa";
        p_context_t * context = p_context_new((uint8_t const *)input, strlen(input));
        p_position_t initial = {10u, 2u};
        p_set_position(context, initial);
        assert(p_parse_Start(context) == P_UNEXPECTED_TOKEN);
        p_position_t err_pos = p_position(context);
        /* Error is at the second `a`, which is one column past the initial
         * column. */
        assert_eq(10u, (size_t)err_pos.row);
        assert_eq(3u, (size_t)err_pos.col);
        p_context_delete(context);
    }

    return 0;
}
