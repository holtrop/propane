#include "testparser.h"
#include <assert.h>
#include <string.h>

int main()
{
    char const * input = "a 42";
    p_context_t context;
    p_context_init(&context, (uint8_t const *)input, strlen(input));
    assert(p_parse(&context) == P_SUCCESS);

    input = "a\n123\na  a";
    p_context_init(&context, (uint8_t const *)input, strlen(input));
    assert(p_parse(&context) == P_UNEXPECTED_TOKEN);
    assert(p_position(&context).row == 2);
    assert(p_position(&context).col == 3);
    assert(context.token == TOKEN_a);

    input = "12";
    p_context_init(&context, (uint8_t const *)input, strlen(input));
    assert(p_parse(&context) == P_UNEXPECTED_TOKEN);
    assert(p_position(&context).row == 0);
    assert(p_position(&context).col == 0);
    assert(context.token == TOKEN_num);

    input = "a 12\n\nab";
    p_context_init(&context, (uint8_t const *)input, strlen(input));
    assert(p_parse(&context) == P_UNEXPECTED_INPUT);
    assert(p_position(&context).row == 2);
    assert(p_position(&context).col == 1);

    input = "a 12\n\na\n\n77\na   \xAA";
    p_context_init(&context, (uint8_t const *)input, strlen(input));
    assert(p_parse(&context) == P_DECODE_ERROR);
    assert(p_position(&context).row == 5);
    assert(p_position(&context).col == 4);

    return 0;
}
