#include "testparser.h"
#include <assert.h>
#include <string.h>
#include "testutils.h"

int main()
{
    /* Grammar (simple):
     *   drop /\\s+/;
     *   token a; token b;
     *   Start -> a b;
     *
     * Verifies that p_input_index() reports the parser/lexer's current byte
     * offset into the input text. */

    /* Fresh context: input_index starts at 0. */
    {
        char const * input = "ab";
        p_context_t * context = p_context_new((uint8_t const *)input, strlen(input));
        assert_eq(0u, p_input_index(context));
        p_context_delete(context);
    }

    /* After each successful lex the byte offset advances past the token. */
    {
        char const * input = "a b";
        p_context_t * context = p_context_new((uint8_t const *)input, strlen(input));
        p_token_info_t token_info;
        assert(p_lex(context, &token_info) == P_SUCCESS);
        assert_eq((size_t)TOKEN_a, (size_t)token_info.token);
        assert_eq(1u, p_input_index(context));
        assert(p_lex(context, &token_info) == P_SUCCESS);
        assert_eq((size_t)TOKEN_b, (size_t)token_info.token);
        /* The dropped space between `a` and `b` advances input_index too. */
        assert_eq(3u, p_input_index(context));
        p_context_delete(context);
    }

    /* After a full successful parse, input_index has reached the end. */
    {
        char const * input = "ab";
        p_context_t * context = p_context_new((uint8_t const *)input, strlen(input));
        assert(p_parse_Start(context) == P_SUCCESS);
        assert_eq(2u, p_input_index(context));
        p_context_delete(context);
    }

    /* When parse_inner completes via a follow token, the follow token is not
     * consumed, so input_index points at the start of the follow token. */
    {
        char const * input = "abb";
        p_context_t * context = p_context_new((uint8_t const *)input, strlen(input));
        p_token_t follow_tokens[] = { TOKEN_b };
        assert(p_parse_inner_Start(context, follow_tokens, 1u) == P_SUCCESS);
        assert_eq(2u, p_input_index(context));
        p_context_delete(context);
    }

    return 0;
}
