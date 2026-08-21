#include "testparser.h"
#include <cassert>
#include <cstring>
#include "testutils.h"

int main()
{
    char input[128];

    /* Enough tokens that the tree node arena is reallocated during the parse. */
    memset(input, 0, sizeof(input));
    for (size_t i = 0u; i < 40u; i++)
    {
        input[i] = 'a';
    }

    p_context_t * context = p_context_new((uint8_t const *)input, strlen(input));
    assert_eq(P_SUCCESS, p_parse(context));

    /* The handle was stored in a context user field during the parse, before
     * the remaining nodes were created. It still refers to the same node. */
    assert_eq(1u, context->have_first);
    assert(context->first_item.valid());
    Token token = context->first_item.pToken1();
    assert(token.valid());
    assert_eq(TOKEN_a, token.token());
    assert_eq(7u, token.pvalue());

    /* The stored handle refers to the first Item, which starts at column 1. */
    assert_eq(1u, context->first_item.position().row);
    assert_eq(1u, context->first_item.position().col);

    p_context_delete(context);

    return 0;
}
