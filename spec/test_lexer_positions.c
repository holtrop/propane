#include "testparser.h"
#include <assert.h>
#include <string.h>

int main()
{
    char const * input = "abc\n  defg hi\n!";
    p_context_t * context = p_context_new((uint8_t const *)input, strlen(input));
    p_token_info_t token_info;

    /* First token "abc" on row 1, cols 1-3. */
    assert(p_lex(context, &token_info) == P_SUCCESS);
    assert(token_info.token == TOKEN_word);
    assert(context->last_start.row == 1u);
    assert(context->last_start.col == 1u);
    assert(context->last_end.row == 1u);
    assert(context->last_end.col == 3u);
    /* The lexer code block observed the same positions reported to the caller. */
    assert(context->last_start.row == token_info.position.row);
    assert(context->last_start.col == token_info.position.col);
    assert(context->last_end.row == token_info.end_position.row);
    assert(context->last_end.col == token_info.end_position.col);

    /* Second token "defg" on row 2, cols 3-6. */
    assert(p_lex(context, &token_info) == P_SUCCESS);
    assert(token_info.token == TOKEN_word);
    assert(context->last_start.row == 2u);
    assert(context->last_start.col == 3u);
    assert(context->last_end.row == 2u);
    assert(context->last_end.col == 6u);

    /* Third token "hi" on row 2, cols 8-9. */
    assert(p_lex(context, &token_info) == P_SUCCESS);
    assert(token_info.token == TOKEN_word);
    assert(context->last_start.row == 2u);
    assert(context->last_start.col == 8u);
    assert(context->last_end.row == 2u);
    assert(context->last_end.col == 9u);

    /* The "!" stop token terminates the lexer. The context input text position
     * must not be updated when the lexer user code requests termination, so it
     * still points at the "!" token on row 3, col 1. */
    assert(p_lex(context, &token_info) == P_USER_TERMINATED);
    assert(p_user_terminate_code(context) == 42u);
    assert(context->text_position.row == 3u);
    assert(context->text_position.col == 1u);

    p_context_delete(context);
    return 0;
}
