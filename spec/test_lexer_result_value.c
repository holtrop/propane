#include "testparser.h"
#include <assert.h>
#include <string.h>

int main()
{
    char const * input = "x";
    p_context_t * context;
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse(context) == P_SUCCESS);
    assert(p_result(context) == 1u);
    p_context_delete(context);

    input = "fabulous";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse(context) == P_SUCCESS);
    assert(p_result(context) == 8u);
    p_context_delete(context);

    return 0;
}
