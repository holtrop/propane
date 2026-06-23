#include "testparser.h"
#include <assert.h>
#include <string.h>

int main()
{
    p_token_info_t token_info;
    char const * input = "42 f s";
    p_context_t * context;
    context = p_context_new((uint8_t const *)input, strlen(input));

    /* Default ptype value extracted with p_value_get(). */
    assert(p_lex(context, &token_info) == P_SUCCESS);
    assert(token_info.token == TOKEN_num);
    assert(p_value_get(&token_info.pvalue) == 42);

    /* Named ptype values extracted with p_value_get_XXX(). */
    assert(p_lex(context, &token_info) == P_SUCCESS);
    assert(token_info.token == TOKEN_flt);
    assert(p_value_get_float(&token_info.pvalue) == 1.5);

    assert(p_lex(context, &token_info) == P_SUCCESS);
    assert(token_info.token == TOKEN_str);
    assert(strcmp(p_value_get_string(&token_info.pvalue), "hello") == 0);

    p_context_delete(context);

    return 0;
}
