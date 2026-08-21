#include "testparser.h"
#include <assert.h>
#include <string.h>
#include "testutils.h"

int main()
{
    char input[128];
    size_t i;
    p_context_t * context;
    Token token;

    /* Enough tokens that the tree node arena is reallocated during the parse. */
    memset(input, 0, sizeof(input));
    for (i = 0u; i < 40u; i++)
    {
        input[i] = 'a';
    }

    context = p_context_new((uint8_t const *)input, strlen(input));
    assert_eq(P_SUCCESS, p_parse(context));

    /* The handle was stored in a context user field during the parse, before
     * the remaining nodes were created. It still refers to the same node. */
    assert_eq(1u, context->have_first);
    assert(p_node_valid(context->first_item));
    token = p_Item_pToken1(context->first_item);
    assert(p_node_valid(token));
    assert_eq(TOKEN_a, p_Token_token(token));
    assert_eq(7u, p_Token_pvalue(token));

    /* The stored handle refers to the first Item, which starts at column 1. */
    assert_eq(1u, p_node_position(context->first_item).row);
    assert_eq(1u, p_node_position(context->first_item).col);

    p_context_delete(context);

    return 0;
}
