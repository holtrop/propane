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
    Start * start = p_result(context);
    assert(start->pItems1 != NULL);
    assert(start->pItems != NULL);
    Items * items = start->pItems;
    assert(items->pItem != NULL);
    assert(items->pItem->pToken1 != NULL);
    assert_eq(TOKEN_a, items->pItem->pToken1->token);
    assert_eq(11, items->pItem->pToken1->pvalue);
    assert(items->pItemsMore != NULL);
    ItemsMore * itemsmore = items->pItemsMore;
    assert(itemsmore->pItem != NULL);
    assert(itemsmore->pItem->pItem != NULL);
    assert(itemsmore->pItem->pItem->pItem != NULL);
    assert(itemsmore->pItem->pItem->pItem->pToken1 != NULL);
    assert_eq(TOKEN_b, itemsmore->pItem->pItem->pItem->pToken1->token);
    assert_eq(22, itemsmore->pItem->pItem->pItem->pToken1->pvalue);
    assert(itemsmore->pItemsMore != NULL);
    itemsmore = itemsmore->pItemsMore;
    assert(itemsmore->pItem != NULL);
    assert(itemsmore->pItem->pToken1 != NULL);
    assert_eq(TOKEN_b, itemsmore->pItem->pToken1->token);
    assert_eq(22, itemsmore->pItem->pToken1->pvalue);
    assert(itemsmore->pItemsMore == NULL);

    p_free_tree(start);
    p_context_delete(context);

    input = "";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert_eq(P_SUCCESS, p_parse(context));
    start = p_result(context);
    assert(start->pItems == NULL);

    p_free_tree(start);
    p_context_delete(context);

    input = "2 1";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert_eq(P_SUCCESS, p_parse(context));
    start = p_result(context);
    assert(start->pItems != NULL);
    assert(start->pItems->pItem != NULL);
    assert(start->pItems->pItem->pDual != NULL);
    assert(start->pItems->pItem->pDual->pTwo1 != NULL);
    assert(start->pItems->pItem->pDual->pOne2 != NULL);
    assert(start->pItems->pItem->pDual->pTwo2 == NULL);
    assert(start->pItems->pItem->pDual->pOne1 == NULL);

    p_free_tree(start);
    p_context_delete(context);

    return 0;
}
