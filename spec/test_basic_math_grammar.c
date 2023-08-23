#include "testparser.h"
#include "testutils.h"
#include <string.h>

int main()
{
    char const * input = "1 + 2 * 3 + 4";
    p_context_t context;
    p_context_init(&context, (uint8_t const *)input, strlen(input));
    assert_eq(P_SUCCESS, p_parse(&context));
    assert_eq(11, p_result(&context));

    input = "1 * 2 ** 4 * 3";
    p_context_init(&context, (uint8_t const *)input, strlen(input));
    assert_eq(P_SUCCESS, p_parse(&context));
    assert_eq(48, p_result(&context));

    input = "(1 + 2) * 3 + 4";
    p_context_init(&context, (uint8_t const *)input, strlen(input));
    assert_eq(P_SUCCESS, p_parse(&context));
    assert_eq(13, p_result(&context));

    input = "(2 * 2) ** 3 + 4 + 5";
    p_context_init(&context, (uint8_t const *)input, strlen(input));
    assert_eq(P_SUCCESS, p_parse(&context));
    assert_eq(73, p_result(&context));

    return 0;
}
