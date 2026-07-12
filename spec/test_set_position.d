import testparser;
import std.stdio;
import testutils;

int main()
{
    return 0;
}

unittest
{
    /* See test_set_position.c for details. */

    /* Baseline: without p_set_position(), positions start at (1, 1). */
    {
        string input = "ab";
        p_context_t * context = p_context_new(input);
        p_position_t pos = p_position(context);
        assert(pos.row == 1);
        assert(pos.col == 1);
        p_token_info_t token_info;
        assert(p_lex(context, &token_info) == P_SUCCESS);
        assert(token_info.token == TOKEN_a);
        assert(token_info.position.row == 1);
        assert(token_info.position.col == 1);
    }

    /* p_set_position() overrides the initial position. */
    {
        string input = "ab";
        p_context_t * context = p_context_new(input);
        p_set_position(context, p_position_t(5u, 20u));
        p_position_t pos = p_position(context);
        assert(pos.row == 5);
        assert(pos.col == 20);
        p_token_info_t token_info;
        assert(p_lex(context, &token_info) == P_SUCCESS);
        assert(token_info.token == TOKEN_a);
        assert(token_info.position.row == 5);
        assert(token_info.position.col == 20);
        assert(p_lex(context, &token_info) == P_SUCCESS);
        assert(token_info.token == TOKEN_b);
        assert(token_info.position.row == 5);
        assert(token_info.position.col == 21);
    }

    /* p_set_position() before a full parse still parses successfully. */
    {
        string input = "ab";
        p_context_t * context = p_context_new(input);
        p_set_position(context, p_position_t(3u, 7u));
        assert(p_parse_Start(context) == P_SUCCESS);
    }

    /* p_set_position() before a parse that fails: error position is
     * relative to the set starting point. */
    {
        string input = "aa";
        p_context_t * context = p_context_new(input);
        p_set_position(context, p_position_t(10u, 2u));
        assert(p_parse_Start(context) == P_UNEXPECTED_TOKEN);
        p_position_t err_pos = p_position(context);
        assert(err_pos.row == 10);
        assert(err_pos.col == 3);
    }
}
