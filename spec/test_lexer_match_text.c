#include "testparser.h"
#include <assert.h>
#include <string.h>
#include <stdio.h>

int main()
{
    char const * input = "identifier_123";
    p_context_t * context;
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse(context) == P_SUCCESS);
    printf("pass1\n");
    p_context_delete(context);

    return 0;
}
