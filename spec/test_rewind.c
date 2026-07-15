#include "testparser.h"
#include <assert.h>
#include <string.h>
#include "testutils.h"

/* Grammar (statement list of additions; a "repeat" directive handled entirely
 * by the lex function):
 *   ptype int;
 *   lex_fn mylexfn;
 *   token repeat /repeat/; token lbrace /\{/; token rbrace /\}/;
 *   token plus /\+/; token num /\d+/ << ... atoi ... >>
 *   Start      -> Statements;
 *   Statements -> ;
 *   Statements -> Statement Statements;
 *   Statement  -> Add;
 *   Add        -> num plus num  << record($1 + $3); >>
 *
 * Scenario: a "repeat <count> { <body> }" directive that expands its body
 * <count> times, similar to loop unrolling in a configuration DSL. The tokens
 * repeat, lbrace, and rbrace appear in no grammar rule; the lex function
 * interprets the directive and feeds the body's tokens to the parser <count>
 * times. Rather than buffering the body tokens, the lex function records the
 * input byte offset and text position at the start of the body (with
 * p_input_index() and p_position()) and, each time it reaches the closing '}',
 * rewinds the lexer back to that point (with p_set_input_index() and
 * p_set_position()) to re-read the body from the original input. Rewinding the
 * text position as well as the byte offset means each expansion reports the
 * same token positions as the first. */

static int nums[16];
static size_t n_nums;
static uint32_t num_cols[16];
static size_t n_num_cols;

void record(int value)
{
    nums[n_nums++] = value;
}

size_t mylexfn(p_context_t * context, p_token_info_t * out_token_info)
{
    static int remaining;
    static size_t body_index;
    static p_position_t body_position;

    for (;;)
    {
        size_t result = p_lex(context, out_token_info);
        if (result != P_SUCCESS)
        {
            return result;
        }

        if (out_token_info->token == TOKEN_repeat)
        {
            /* Consume "repeat <count> {" and remember where the body begins. */
            p_token_info_t count_info;
            size_t count_result = p_lex(context, &count_info);
            assert(count_result == P_SUCCESS);
            assert(count_info.token == TOKEN_num);
            p_token_info_t brace_info;
            size_t brace_result = p_lex(context, &brace_info);
            assert(brace_result == P_SUCCESS);
            assert(brace_info.token == TOKEN_lbrace);
            remaining = p_value_get(&count_info.pvalue);
            body_index = p_input_index(context);
            body_position = p_position(context);
            continue;
        }
        if (out_token_info->token == TOKEN_rbrace)
        {
            /* End of the body. If more expansions remain, rewind the lexer to
             * the start of the body and re-read it; otherwise fall through to
             * the input following the '}'. */
            if (remaining > 1)
            {
                remaining--;
                p_set_input_index(context, body_index);
                p_set_position(context, body_position);
                continue;
            }
            remaining = 0;
            continue;
        }
        if (out_token_info->token == TOKEN_num)
        {
            num_cols[n_num_cols++] = out_token_info->position.col;
        }
        return result;
    }
}

int main()
{
    /* "repeat 3 { 10 + 20 } 5 + 5": the body "10 + 20" is expanded three
     * times (recording 30 each time), followed by "5 + 5" (recording 10). */
    char const * input = "repeat 3 { 10 + 20 } 5 + 5";
    p_context_t * context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse(context) == P_SUCCESS);
    p_context_delete(context);

    /* The additions were recorded once per body expansion, then once more for
     * the trailing statement. */
    assert_eq(4u, n_nums);
    assert_eq(30u, (size_t)nums[0]);
    assert_eq(30u, (size_t)nums[1]);
    assert_eq(30u, (size_t)nums[2]);
    assert_eq(10u, (size_t)nums[3]);

    /* Each body expansion reported the same columns for its num tokens (12 and
     * 17), because the text position was rewound along with the byte offset.
     * The trailing statement's nums are at columns 22 and 26. */
    assert_eq(8u, n_num_cols);
    assert_eq(12u, (size_t)num_cols[0]);
    assert_eq(17u, (size_t)num_cols[1]);
    assert_eq(12u, (size_t)num_cols[2]);
    assert_eq(17u, (size_t)num_cols[3]);
    assert_eq(12u, (size_t)num_cols[4]);
    assert_eq(17u, (size_t)num_cols[5]);
    assert_eq(22u, (size_t)num_cols[6]);
    assert_eq(26u, (size_t)num_cols[7]);

    return 0;
}
