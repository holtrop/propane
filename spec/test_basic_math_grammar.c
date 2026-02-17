#include "testparser.h"
#include "testutils.h"
#include <string.h>

int main()
{
    char const * input = "1 + 2 * 3 + 4";
    p_context_t * context;
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert_eq(P_SUCCESS, p_parse(context));
    assert_eq(11, p_result(context));
    p_context_delete(context);

    input = "1 * 2 ** 4 * 3";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert_eq(P_SUCCESS, p_parse(context));
    assert_eq(48, p_result(context));
    p_context_delete(context);

    input = "(1 + 2) * 3 + 4";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert_eq(P_SUCCESS, p_parse(context));
    assert_eq(13, p_result(context));
    p_context_delete(context);

    input = "(2 * 2) ** 3 + 4 + 5";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert_eq(P_SUCCESS, p_parse(context));
    assert_eq(73, p_result(context));
    p_context_delete(context);

    return 0;
}
