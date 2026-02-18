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
    Start * start = p_result(context);
    assert(start->a != NULL);
    assert(*start->a->pvalue == 1);
    assert(start->b != NULL);
    assert(*start->b->pvalue == 2);

    p_tree_delete(start);
    p_context_delete(context);
}
