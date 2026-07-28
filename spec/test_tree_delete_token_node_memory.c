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
    Start start = p_result(context);
    assert(p_node_valid(p_Start_a(start)));
    assert(*p_tree_walk_Start(start, a, pvalue) == 1);
    assert(p_node_valid(p_Start_b(start)));
    assert(*p_tree_walk_Start(start, b, pvalue) == 2);

    p_context_delete(context);
}
