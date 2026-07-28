#include "testparser.h"
#include <assert.h>
#include <string.h>
#include "testutils.h"

int main()
{
    char const * input = "a, ((b)), b";
    p_context_t * context;
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert_eq(P_SUCCESS, p_parse(context));
    PStartS start = p_result(context);
    assert(p_node_valid(p_PStartS_pItems1(start)));
    assert(p_node_valid(p_PStartS_pItems(start)));
    PItemsS items = p_PStartS_pItems(start);
    assert(p_node_valid(p_PItemsS_pItem(items)));
    assert(p_node_valid(p_tree_walk_PItemsS(items, pItem, pToken1)));
    assert_eq(TOKEN_a, p_tree_walk_PItemsS(items, pItem, pToken1, token));
    assert_eq(11, p_tree_walk_PItemsS(items, pItem, pToken1, pvalue));
    assert(p_node_valid(p_PItemsS_pItemsMore(items)));
    PItemsMoreS itemsmore = p_PItemsS_pItemsMore(items);
    assert(p_node_valid(p_PItemsMoreS_pItem(itemsmore)));
    assert(p_node_valid(p_tree_walk_PItemsMoreS(itemsmore, pItem, pItem)));
    assert(p_node_valid(p_tree_walk_PItemsMoreS(itemsmore, pItem, pItem, pItem)));
    assert(p_node_valid(p_tree_walk_PItemsMoreS(itemsmore, pItem, pItem, pItem, pToken1)));
    assert_eq(TOKEN_b, p_tree_walk_PItemsMoreS(itemsmore, pItem, pItem, pItem, pToken1, token));
    assert_eq(22, p_tree_walk_PItemsMoreS(itemsmore, pItem, pItem, pItem, pToken1, pvalue));
    assert(p_node_valid(p_PItemsMoreS_pItemsMore(itemsmore)));
    itemsmore = p_PItemsMoreS_pItemsMore(itemsmore);
    assert(p_node_valid(p_PItemsMoreS_pItem(itemsmore)));
    assert(p_node_valid(p_tree_walk_PItemsMoreS(itemsmore, pItem, pToken1)));
    assert_eq(TOKEN_b, p_tree_walk_PItemsMoreS(itemsmore, pItem, pToken1, token));
    assert_eq(22, p_tree_walk_PItemsMoreS(itemsmore, pItem, pToken1, pvalue));
    assert(!p_node_valid(p_PItemsMoreS_pItemsMore(itemsmore)));

    p_context_delete(context);

    input = "";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert_eq(P_SUCCESS, p_parse(context));
    start = p_result(context);
    assert(!p_node_valid(p_PStartS_pItems(start)));

    p_context_delete(context);

    input = "2 1";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert_eq(P_SUCCESS, p_parse(context));
    start = p_result(context);
    assert(p_node_valid(p_PStartS_pItems(start)));
    assert(p_node_valid(p_tree_walk_PStartS(start, pItems, pItem)));
    assert(p_node_valid(p_tree_walk_PStartS(start, pItems, pItem, pDual)));
    assert(p_node_valid(p_tree_walk_PStartS(start, pItems, pItem, pDual, pTwo1)));
    assert(p_node_valid(p_tree_walk_PStartS(start, pItems, pItem, pDual, pOne2)));
    assert(!p_node_valid(p_tree_walk_PStartS(start, pItems, pItem, pDual, pTwo2)));
    assert(!p_node_valid(p_tree_walk_PStartS(start, pItems, pItem, pDual, pOne1)));

    p_context_delete(context);

    return 0;
}
