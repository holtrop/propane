#include "testparser.h"
#include <assert.h>
#include <string.h>
#include "testutils.h"

int main()
{
    /* Grammar (tree generation mode, shared reduce state):
     *   tree;
     *   token a; token b;
     *   start Start;
     *   start R1;
     *   Start -> R1 a;
     *   Start -> R2 b;
     *   R1 -> a b;
     *   R2 -> a b;
     *
     * Exercises p_parse_inner_R1() with a non-EOF follow token in tree
     * generation mode. Verifies:
     *   * The reduced tree for R1 is well-formed after a follow-token
     *     completion.
     *   * The follow token is not consumed and remains available for a
     *     subsequent p_lex() call.
     *   * p_tree_delete_R1() cleans up the returned tree without leaks
     *     (verified in CI via valgrind). */

    /* Baseline: p_parse_R1 works on "ab" and the returned tree is
     * well-formed. */
    {
        char const * input = "ab";
        p_context_t * context = p_context_new((uint8_t const *)input, strlen(input));
        assert(p_parse_R1(context) == P_SUCCESS);
        R1 * tree = p_result_R1(context);
        assert_not_null(tree);
        assert_not_null(tree->pToken1);
        assert_eq((size_t)TOKEN_a, (size_t)tree->pToken1->token);
        assert_not_null(tree->pToken2);
        assert_eq((size_t)TOKEN_b, (size_t)tree->pToken2->token);
        p_tree_delete_R1(tree);
        p_context_delete(context);
    }

    /* Primary case: p_parse_inner_R1 with a non-EOF follow token completes
     * the parse, returns a well-formed tree, and leaves the follow token
     * unconsumed. */
    {
        char const * input = "abb";
        p_context_t * context = p_context_new((uint8_t const *)input, strlen(input));
        p_token_t follow_tokens[] = { TOKEN_b };
        assert(p_parse_inner_R1(context, follow_tokens, 1u) == P_SUCCESS);

        /* Tree is well-formed. */
        R1 * tree = p_result_R1(context);
        assert_not_null(tree);
        assert_not_null(tree->pToken1);
        assert_eq((size_t)TOKEN_a, (size_t)tree->pToken1->token);
        assert_eq(1u, (size_t)tree->pToken1->position.row);
        assert_eq(1u, (size_t)tree->pToken1->position.col);
        assert_not_null(tree->pToken2);
        assert_eq((size_t)TOKEN_b, (size_t)tree->pToken2->token);
        assert_eq(1u, (size_t)tree->pToken2->position.row);
        assert_eq(2u, (size_t)tree->pToken2->position.col);

        /* The R1 tree covers positions 1..2 — the third `b` at column 3 is
         * the follow token and is not part of the tree. */
        assert_eq(1u, (size_t)tree->position.row);
        assert_eq(1u, (size_t)tree->position.col);
        assert_eq(1u, (size_t)tree->end_position.row);
        assert_eq(2u, (size_t)tree->end_position.col);

        /* Follow token remains in the input. */
        p_position_t pos = p_position(context);
        assert_eq(1u, (size_t)pos.row);
        assert_eq(3u, (size_t)pos.col);
        p_token_info_t token_info;
        assert(p_lex(context, &token_info) == P_SUCCESS);
        assert_eq((size_t)TOKEN_b, (size_t)token_info.token);
        assert_eq(1u, (size_t)token_info.position.row);
        assert_eq(3u, (size_t)token_info.position.col);

        /* p_tree_delete_R1 must free every node reachable from the tree
         * without leaking anything. valgrind (invoked by the spec runner on
         * Linux) will detect any missed frees. */
        p_tree_delete_R1(tree);
        p_context_delete(context);
    }

    return 0;
}
