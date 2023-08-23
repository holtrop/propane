#include "testparser.h"
#include <assert.h>
#include <string.h>

int main()
{
    char const * input = "x";
    p_context_t context;
    p_context_init(&context, (uint8_t const *)input, strlen(input));
    assert(p_parse(&context) == P_SUCCESS);
    assert(p_result(&context) == 1u);

    input = "fabulous";
    p_context_init(&context, (uint8_t const *)input, strlen(input));
    assert(p_parse(&context) == P_SUCCESS);
    assert(p_result(&context) == 8u);

    return 0;
}
