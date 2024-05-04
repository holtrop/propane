#include "testparser.h"
#include <assert.h>
#include <string.h>
#include "testutils.h"

int main()
{
    char const * input = "a, ((b)), b";
    p_context_t context;
    p_context_init(&context, (uint8_t const *)input, strlen(input));
    assert_eq(P_SUCCESS, p_parse(&context));
    PStartS * start = p_result(&context);
    assert(start->pItems1 != NULL);
    assert(start->pItems != NULL);
    PItemsS * items = start->pItems;
    assert(items->pItem != NULL);
    assert(items->pItem->pToken1 != NULL);
    assert_eq(TOKEN_a, items->pItem->pToken1->token);
    assert_eq(11, items->pItem->pToken1->pvalue);
    assert(items->pItemsMore != NULL);
    PItemsMoreS * itemsmore = items->pItemsMore;
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

    input = "";
    p_context_init(&context, (uint8_t const *)input, strlen(input));
    assert_eq(P_SUCCESS, p_parse(&context));
    start = p_result(&context);
    assert(start->pItems == NULL);

    input = "2 1";
    p_context_init(&context, (uint8_t const *)input, strlen(input));
    assert_eq(P_SUCCESS, p_parse(&context));
    start = p_result(&context);
    assert(start->pItems != NULL);
    assert(start->pItems->pItem != NULL);
    assert(start->pItems->pItem->pDual != NULL);
    assert(start->pItems->pItem->pDual->pTwo1 != NULL);
    assert(start->pItems->pItem->pDual->pOne2 != NULL);
    assert(start->pItems->pItem->pDual->pTwo2 == NULL);
    assert(start->pItems->pItem->pDual->pOne1 == NULL);

    return 0;
}
