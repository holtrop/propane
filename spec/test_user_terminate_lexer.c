#include "testparser.h"
#include <assert.h>
#include <stdio.h>
#include <string.h>

int main()
{
    char const * input = "a";
    p_context_t context;
    p_context_init(&context, (uint8_t const *)input, strlen(input));
    assert(p_parse(&context) == P_SUCCESS);

    input = "b";
    p_context_init(&context, (uint8_t const *)input, strlen(input));
    assert(p_parse(&context) == P_USER_TERMINATED);
    assert(p_user_terminate_code(&context) == 8675309);

    return 0;
}
