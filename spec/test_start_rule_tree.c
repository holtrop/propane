#include "testparser.h"
#include <assert.h>
#include <string.h>
#include "testutils.h"

int main()
{
    char const * input = "hi";
    p_context_t * context;
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert_eq(P_SUCCESS, p_parse(context));
    Top * top = p_result(context);
    assert(top->pToken != NULL);
    assert_eq(TOKEN_hi, top->pToken->token);

    p_tree_delete(top);
    p_context_delete(context);

    return 0;
}
