#include "testparser.h"
#include <assert.h>
#include <string.h>

int main()
{
    char const * input = "a";
    p_context_t context;
    p_context_init(&context, (uint8_t const *)input, strlen(input));
    assert(p_parse(&context) == P_UNEXPECTED_TOKEN);
    assert(p_position(&context).row == 0);
    assert(p_position(&context).col == 1);
    assert(context.token == TOKEN___EOF);

    input = "a b";
    p_context_init(&context, (uint8_t const *)input, strlen(input));
    assert(p_parse(&context) == P_SUCCESS);

    input = "bb";
    p_context_init(&context, (uint8_t const *)input, strlen(input));
    assert(p_parse(&context) == P_SUCCESS);

    return 0;
}
