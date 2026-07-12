import testparser;
import std.stdio;
import testutils;

int main()
{
    return 0;
}

unittest
{
    /* See test_input_index.c for details on the grammar and cases. */

    /* Fresh context: input_index starts at 0. */
    {
        string input = "ab";
        p_context_t * context = p_context_new(input);
        assert(p_input_index(context) == 0);
    }

    /* After each successful lex the byte offset advances past the token. */
    {
        string input = "a b";
        p_context_t * context = p_context_new(input);
        p_token_info_t token_info;
        assert(p_lex(context, &token_info) == P_SUCCESS);
        assert(token_info.token == TOKEN_a);
        assert(p_input_index(context) == 1);
        assert(p_lex(context, &token_info) == P_SUCCESS);
        assert(token_info.token == TOKEN_b);
        assert(p_input_index(context) == 3);
    }

    /* After a full successful parse, input_index has reached the end. */
    {
        string input = "ab";
        p_context_t * context = p_context_new(input);
        assert(p_parse_Start(context) == P_SUCCESS);
        assert(p_input_index(context) == 2);
    }

    /* When parse_inner completes via a follow token, the follow token is not
     * consumed, so input_index points at the start of the follow token. */
    {
        string input = "abb";
        p_context_t * context = p_context_new(input);
        p_token_t[] follow_tokens = [TOKEN_b];
        assert(p_parse_inner_Start(context, follow_tokens) == P_SUCCESS);
        assert(p_input_index(context) == 2);
    }
}
