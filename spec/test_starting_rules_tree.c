#include "testparser.h"
#include <assert.h>
#include <string.h>
#include "testutils.h"

int main()
{
    char const * input = "bbbb";
    p_context_t * context;
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse(context) == P_SUCCESS);
    Start start = p_result(context);
    assert(p_node_valid(p_Start_bs(start)));
    assert(p_node_valid(p_tree_walk_Start(start, bs, b)));
    assert(p_node_valid(p_tree_walk_Start(start, bs, bs, b)));
    assert(p_node_valid(p_tree_walk_Start(start, bs, bs, bs, b)));
    assert(p_node_valid(p_tree_walk_Start(start, bs, bs, bs, bs, b)));
    p_context_delete(context);

    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse_Bs(context) == P_SUCCESS);
    Bs bs = p_result_Bs(context);
    assert(p_node_valid(p_Bs_b(bs)));
    assert(p_node_valid(p_tree_walk_Bs(bs, bs, b)));
    assert(p_node_valid(p_tree_walk_Bs(bs, bs, bs, b)));
    assert(p_node_valid(p_tree_walk_Bs(bs, bs, bs, bs, b)));
    p_context_delete(context);

    input = "c";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse_R(context) == P_SUCCESS);
    R r = p_result_R(context);
    assert(p_node_valid(p_R_c(r)));
    p_context_delete(context);

    return 0;
}
