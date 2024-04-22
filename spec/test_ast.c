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
    Start * start = p_result(&context);
    assert(start->pItems1 != NULL);
    Items * items = start->pItems1;
    assert(items->pItem1 != NULL);
    assert(items->pItem1->pToken1 != NULL);
    assert_eq(TOKEN_a, items->pItem1->pToken1->token);
    assert_eq(11, items->pItem1->pToken1->pvalue);
    assert(items->pItemsMore2 != NULL);
    ItemsMore * itemsmore = items->pItemsMore2;
    assert(itemsmore->pItem2 != NULL);
    assert(itemsmore->pItem2->pItem2 != NULL);
    assert(itemsmore->pItem2->pItem2->pItem2 != NULL);
    assert(itemsmore->pItem2->pItem2->pItem2->pToken1 != NULL);
    assert_eq(TOKEN_b, itemsmore->pItem2->pItem2->pItem2->pToken1->token);
    assert_eq(22, itemsmore->pItem2->pItem2->pItem2->pToken1->pvalue);
    assert(itemsmore->pItemsMore3 != NULL);
    itemsmore = itemsmore->pItemsMore3;
    assert(itemsmore->pItem2 != NULL);
    assert(itemsmore->pItem2->pToken1 != NULL);
    assert_eq(TOKEN_b, itemsmore->pItem2->pToken1->token);
    assert_eq(22, itemsmore->pItem2->pToken1->pvalue);
    assert(itemsmore->pItemsMore3 == NULL);

    input = "";
    p_context_init(&context, (uint8_t const *)input, strlen(input));
    assert_eq(P_SUCCESS, p_parse(&context));
    start = p_result(&context);
    assert(start->pItems1 == NULL);

    input = "2 1";
    p_context_init(&context, (uint8_t const *)input, strlen(input));
    assert_eq(P_SUCCESS, p_parse(&context));
    start = p_result(&context);
    assert(start->pItems1 != NULL);
    assert(start->pItems1->pItem1 != NULL);
    assert(start->pItems1->pItem1->pDual1 != NULL);
    assert(start->pItems1->pItem1->pDual1->pTwo1 != NULL);
    assert(start->pItems1->pItem1->pDual1->pOne2 != NULL);
    assert(start->pItems1->pItem1->pDual1->pTwo2 == NULL);
    assert(start->pItems1->pItem1->pDual1->pOne1 == NULL);

    return 0;
}
