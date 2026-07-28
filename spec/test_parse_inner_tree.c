#include "testparser.h"
#include <assert.h>
#include <string.h>
#include "testutils.h"

int main()
{
    /* See the D variant / grammar comments for details. In tree mode the tree
     * nodes live in the context arena and are freed with p_context_delete(). */

    /* Baseline: p_parse_R1 works on "ab" and the returned tree is
     * well-formed. */
    {
        char const * input = "ab";
        p_context_t * context = p_context_new((uint8_t const *)input, strlen(input));
        assert(p_parse_R1(context) == P_SUCCESS);
        R1 tree = p_result_R1(context);
        assert(p_node_valid(tree));
        assert(p_node_valid(p_R1_pToken1(tree)));
        assert_eq((size_t)TOKEN_a, (size_t)p_tree_walk_R1(tree, pToken1, token));
        assert(p_node_valid(p_R1_pToken2(tree)));
        assert_eq((size_t)TOKEN_b, (size_t)p_tree_walk_R1(tree, pToken2, token));
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
        R1 tree = p_result_R1(context);
        assert(p_node_valid(tree));
        assert(p_node_valid(p_R1_pToken1(tree)));
        assert_eq((size_t)TOKEN_a, (size_t)p_tree_walk_R1(tree, pToken1, token));
        assert_eq(1u, (size_t)p_node_position(p_R1_pToken1(tree)).row);
        assert_eq(1u, (size_t)p_node_position(p_R1_pToken1(tree)).col);
        assert(p_node_valid(p_R1_pToken2(tree)));
        assert_eq((size_t)TOKEN_b, (size_t)p_tree_walk_R1(tree, pToken2, token));
        assert_eq(1u, (size_t)p_node_position(p_R1_pToken2(tree)).row);
        assert_eq(2u, (size_t)p_node_position(p_R1_pToken2(tree)).col);

        /* The R1 tree covers positions 1..2 - the third `b` at column 3 is
         * the follow token and is not part of the tree. */
        assert_eq(1u, (size_t)p_node_position(tree).row);
        assert_eq(1u, (size_t)p_node_position(tree).col);
        assert_eq(1u, (size_t)p_node_end_position(tree).row);
        assert_eq(2u, (size_t)p_node_end_position(tree).col);

        /* Follow token remains in the input. */
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

    return 0;
}
