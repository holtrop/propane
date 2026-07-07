#include "testparser.h"
#include <assert.h>
#include <string.h>
#include "testutils.h"

int main()
{
    char const * input = "ab";
    p_context_t * context;
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert_eq(P_SUCCESS, p_parse(context));

    /* The parser user code recorded values accessed via $$, $1, and $2 while
     * the tree node for the Start rule was being formed. */
    assert_eq(3, context->start_n_fields);
    assert_eq(11, context->start_a_value);
    assert_eq(11, context->a_value);
    assert_eq(22, context->b_value);
    assert_eq(TOKEN_b, context->b_token);

    /* The empty-matched rule C has a null $$ tree node, and its field in the
     * Start node is null as well. */
    assert_eq(1, context->c_is_null);
    assert_eq(1, context->c_field_is_null);

    /* Field aliases reference the same component tree nodes as the positional
     * references. */
    assert_eq(11, context->alias_a_value);
    assert_eq(22, context->alias_b_value);

    Start * start = p_result(context);
    assert(start->pA != NULL);
    assert(start->pB != NULL);
    assert(start->pC == NULL);
    p_tree_delete(start);
    p_context_delete(context);

    return 0;
}
