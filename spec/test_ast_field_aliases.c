#include "testparser.h"
#include <assert.h>
#include <string.h>
#include "testutils.h"

int main()
{
    char const * input = "\na\nb\nc";
    p_context_t context;
    p_context_init(&context, (uint8_t const *)input, strlen(input));
    assert(p_parse(&context) == P_SUCCESS);
    Start * start = p_result(&context);

    assert_eq(TOKEN_a, start->first->pToken->token);
    assert_eq(TOKEN_b, start->second->pToken->token);
    assert_eq(TOKEN_c, start->third->pToken->token);

    return 0;
}
