#include "testparser.h"
#include <assert.h>
#include <string.h>

int main()
{
    char const * input = "a";
    p_context_t context;
    p_context_init(&context, (uint8_t const *)input, strlen(input));
    assert(p_parse(&context) == P_SUCCESS);
    assert(p_result(&context) == 1u);

    input = "";
    p_context_init(&context, (uint8_t const *)input, strlen(input));
    assert(p_parse(&context) == P_SUCCESS);
    assert(p_result(&context) == 0u);

    input = "aaaaaaaaaaaaaaaa";
    p_context_init(&context, (uint8_t const *)input, strlen(input));
    assert(p_parse(&context) == P_SUCCESS);
    assert(p_result(&context) == 16u);

    return 0;
}
