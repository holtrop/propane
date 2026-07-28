#include "testparser.h"
#include <assert.h>
#include <string.h>
#include "testutils.h"

int main()
{
    char const * input = "b";
    p_context_t * context;
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse(context) == P_SUCCESS);
    Start start = p_result(context);
    assert(!p_node_valid(p_Start_pToken1(start)));
    assert(p_node_valid(p_Start_pToken2(start)));
    assert_eq(TOKEN_b, p_tree_walk_Start(start, pToken2, token));
    assert(!p_node_valid(p_Start_pR3(start)));
    assert(!p_node_valid(p_Start_pR(start)));

    p_context_delete(context);

    input = "abcd";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse(context) == P_SUCCESS);
    start = p_result(context);
    assert(p_node_valid(p_Start_pToken1(start)));
    assert_eq(TOKEN_a, p_tree_walk_Start(start, pToken1, token));
    assert(p_node_valid(p_Start_pToken2(start)));
    assert(p_node_valid(p_Start_pR3(start)));
    assert(p_node_valid(p_Start_pR(start)));
    assert(p_node_id(p_Start_pR(start)) == p_node_id(p_Start_pR3(start)));
    assert_eq(TOKEN_c, p_tree_walk_Start(start, pR, pToken1, token));

    p_context_delete(context);

    input = "bdc";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse(context) == P_SUCCESS);
    start = p_result(context);
    assert(!p_node_valid(p_Start_pToken1(start)));
    assert(p_node_valid(p_Start_pToken2(start)));
    assert(p_node_valid(p_Start_pR(start)));
    assert_eq(TOKEN_d, p_tree_walk_Start(start, pR, pToken1, token));

    p_context_delete(context);

    return 0;
}
