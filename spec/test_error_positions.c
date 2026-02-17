#include "testparser.h"
#include <assert.h>
#include <string.h>

int main()
{
    char const * input = "a 42";
    p_context_t * context;
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse(context) == P_SUCCESS);
    p_context_delete(context);

    input = "a\n123\na  a";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse(context) == P_UNEXPECTED_TOKEN);
    assert(p_position(context).row == 3);
    assert(p_position(context).col == 4);
    assert(p_token(context) == TOKEN_a);
    p_context_delete(context);

    input = "12";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse(context) == P_UNEXPECTED_TOKEN);
    assert(p_position(context).row == 1);
    assert(p_position(context).col == 1);
    assert(p_token(context) == TOKEN_num);
    p_context_delete(context);

    input = "a 12\n\nab";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse(context) == P_UNEXPECTED_INPUT);
    assert(p_position(context).row == 3);
    assert(p_position(context).col == 2);
    p_context_delete(context);

    input = "a 12\n\na\n\n77\na   \xAA";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse(context) == P_DECODE_ERROR);
    assert(p_position(context).row == 6);
    assert(p_position(context).col == 5);

    assert(strcmp(p_token_names[TOKEN_a], "a") == 0);
    assert(strcmp(p_token_names[TOKEN_num], "num") == 0);
    p_context_delete(context);

    return 0;
}
