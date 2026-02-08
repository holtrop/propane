#include "testparser.h"
#include <assert.h>
#include <string.h>
#include "testutils.h"

int main()
{
    char const * input = "hi";
    p_context_t context;
    p_context_init(&context, (uint8_t const *)input, strlen(input));
    assert_eq(P_SUCCESS, p_parse(&context));
    Top * top = p_result(&context);
    assert(top->pToken != NULL);
    assert_eq(TOKEN_hi, top->pToken->token);

    p_free_ast(top);

    return 0;
}
