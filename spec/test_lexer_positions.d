import testparser;
import std.stdio;

int main()
{
    return 0;
}

unittest
{
    string input = "abc\n  defg hi\n!";
    p_context_t * context = p_context_new(input);
    p_token_info_t token_info;

    /* First token "abc" on row 1, cols 1-3. */
    assert(p_lex(context, &token_info) == P_SUCCESS);
    assert(token_info.token == TOKEN_word);
    assert(context.last_start == p_position_t(1, 1));
    assert(context.last_end == p_position_t(1, 3));
    /* The lexer code block observed the same positions reported to the caller. */
    assert(context.last_start == token_info.position);
    assert(context.last_end == token_info.end_position);

    /* Second token "defg" on row 2, cols 3-6. */
    assert(p_lex(context, &token_info) == P_SUCCESS);
    assert(token_info.token == TOKEN_word);
    assert(context.last_start == p_position_t(2, 3));
    assert(context.last_end == p_position_t(2, 6));

    /* Third token "hi" on row 2, cols 8-9. */
    assert(p_lex(context, &token_info) == P_SUCCESS);
    assert(token_info.token == TOKEN_word);
    assert(context.last_start == p_position_t(2, 8));
    assert(context.last_end == p_position_t(2, 9));

    /* The "!" stop token terminates the lexer. The context input text position
     * must not be updated when the lexer user code requests termination, so it
     * still points at the "!" token on row 3, col 1. */
    assert(p_lex(context, &token_info) == P_USER_TERMINATED);
    assert(p_user_terminate_code(context) == 42u);
    assert(context.text_position == p_position_t(3, 1));
}
