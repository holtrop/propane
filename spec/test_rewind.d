import testparser;
import testutils;

/* Grammar and scenario: see test_rewind.c. */

int[16] nums;
size_t n_nums;
uint[16] num_cols;
size_t n_num_cols;

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

        if (out_token_info.token == TOKEN_repeat)
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
        if (out_token_info.token == TOKEN_rbrace)
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
        if (out_token_info.token == TOKEN_num)
        {
            num_cols[n_num_cols++] = out_token_info.position.col;
        }
        return result;
    }
}

int main()
{
    return 0;
}

unittest
{
    /* "repeat 3 { 10 + 20 } 5 + 5": the body "10 + 20" is expanded three
     * times (recording 30 each time), followed by "5 + 5" (recording 10). */
    string input = "repeat 3 { 10 + 20 } 5 + 5";
    p_context_t * context = p_context_new(input);
    assert(p_parse(context) == P_SUCCESS);
    p_context_delete(context);

    assert_eq(4u, n_nums);
    assert_eq(30, nums[0]);
    assert_eq(30, nums[1]);
    assert_eq(30, nums[2]);
    assert_eq(10, nums[3]);

    /* Each body expansion reported the same columns for its num tokens (12 and
     * 17), because the text position was rewound along with the byte offset.
     * The trailing statement's nums are at columns 22 and 26. */
    assert_eq(8u, n_num_cols);
    assert_eq(12u, num_cols[0]);
    assert_eq(17u, num_cols[1]);
    assert_eq(12u, num_cols[2]);
    assert_eq(17u, num_cols[3]);
    assert_eq(12u, num_cols[4]);
    assert_eq(17u, num_cols[5]);
    assert_eq(22u, num_cols[6]);
    assert_eq(26u, num_cols[7]);
}
