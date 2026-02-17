#include "testparser.h"
#include <assert.h>
#include <stdio.h>
#include <string.h>

int main()
{
    char const * input = "aacc";
    p_context_t * context;
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse(context) == P_SUCCESS);
    p_context_delete(context);

    input = "abc";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse(context) == P_USER_TERMINATED);
    assert(p_user_terminate_code(context) == 4200);
    p_context_delete(context);

    return 0;
}
