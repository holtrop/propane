import testparser;
import std.stdio;
import testutils;

int main()
{
    return 0;
}

unittest
{
    /* See test_parse_inner_tree.c for details on the grammar and cases. */

    /* Baseline: p_parse_R1 works on "ab". */
    {
        string input = "ab";
        p_context_t * context = p_context_new(input);
        assert(p_parse_R1(context) == P_SUCCESS);
        R1 * tree = p_result_R1(context);
        assert(tree !is null);
        assert(tree.pToken1 !is null);
        assert(tree.pToken1.token == TOKEN_a);
        assert(tree.pToken2 !is null);
        assert(tree.pToken2.token == TOKEN_b);
        p_tree_delete_R1(tree);
    }

    /* Primary case: p_parse_inner_R1 with a non-EOF follow token completes
     * the parse, returns a well-formed tree, and leaves the follow token
     * unconsumed. */
    {
        string input = "abb";
        p_context_t * context = p_context_new(input);
        p_token_t[] follow_tokens = [TOKEN_b];
        assert(p_parse_inner_R1(context, follow_tokens) == P_SUCCESS);

        /* Tree is well-formed. */
        R1 * tree = p_result_R1(context);
        assert(tree !is null);
        assert(tree.pToken1 !is null);
        assert(tree.pToken1.token == TOKEN_a);
        assert(tree.pToken1.position.row == 1);
        assert(tree.pToken1.position.col == 1);
        assert(tree.pToken2 !is null);
        assert(tree.pToken2.token == TOKEN_b);
        assert(tree.pToken2.position.row == 1);
        assert(tree.pToken2.position.col == 2);

        /* The R1 tree covers positions 1..2. The third `b` at column 3 is
         * the follow token and is not part of the tree. */
        assert(tree.position.row == 1);
        assert(tree.position.col == 1);
        assert(tree.end_position.row == 1);
        assert(tree.end_position.col == 2);

        /* Follow token remains in the input. */
        p_position_t pos = p_position(context);
        assert(pos.row == 1);
        assert(pos.col == 3);
        p_token_info_t token_info;
        assert(p_lex(context, &token_info) == P_SUCCESS);
        assert(token_info.token == TOKEN_b);
        assert(token_info.position.row == 1);
        assert(token_info.position.col == 3);

        p_tree_delete_R1(tree);
    }
}
