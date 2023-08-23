#include "testparser.h"
#include <stdio.h>
#include <assert.h>
#include <string.h>

int main()
{
    char const * input = "abcdef";
    p_context_t context;
    p_context_init(&context, (uint8_t const *)input, strlen(input));
    assert(p_parse(&context) == P_SUCCESS);
    printf("pass1\n");

    input = "defabcdef";
    p_context_init(&context, (uint8_t const *)input, strlen(input));
    assert(p_parse(&context) == P_SUCCESS);
    printf("pass2\n");

    return 0;
}
