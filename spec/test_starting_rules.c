#include "testparser.h"
#include <assert.h>
#include <string.h>
#include "testutils.h"

int main()
{
    char const * input = "bbbb";
    p_context_t * context;
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse(context) == P_SUCCESS);
    int result = p_result(context);
    assert_eq(8, result);
    p_context_delete(context);

    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse_Bs(context) == P_SUCCESS);
    result = p_result_Bs(context);
    assert_eq(8, result);
    p_context_delete(context);

    input = "c";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse_R(context) == P_SUCCESS);
    result = p_result_R(context);
    assert_eq(3, result);
    p_context_delete(context);

    return 0;
}
