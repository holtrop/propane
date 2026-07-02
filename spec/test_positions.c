#include "testparser.h"
#include <assert.h>
#include <string.h>
#include <stdio.h>

int main()
{
    char const * input = "    Hello\n\n        4200\n";
    p_context_t * context;
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse(context) == P_SUCCESS);
    p_context_delete(context);

    printf("\n");

    input = "\n tok2";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse(context) == P_SUCCESS);
    p_context_delete(context);

    printf("\n");

    input = "  tok1";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse(context) == P_SUCCESS);
    p_context_delete(context);

    return 0;
}
