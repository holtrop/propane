#include "testparser.h"
#include <assert.h>
#include <string.h>

int main()
{
    char const * input = "a";
    p_context_t * context;
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse(context) == P_UNEXPECTED_TOKEN);
    assert(p_position(context).row == 1);
    assert(p_position(context).col == 2);
    assert(context->token == TOKEN___EOF);
    p_context_delete(context);

    input = "a b";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse(context) == P_SUCCESS);
    p_context_delete(context);

    input = "bb";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse(context) == P_SUCCESS);
    p_context_delete(context);

    return 0;
}
