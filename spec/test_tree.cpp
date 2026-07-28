#include "testparser.h"
#include <cassert>
#include <cstring>
#include "testutils.h"

int main()
{
    char const * input = "a, ((b)), b";
    p_context_t * context;
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert_eq(P_SUCCESS, p_parse(context));
    Start start = p_result(context);
    assert(start.pItems1().valid());
    assert(start.pItems().valid());
    Items items = start.pItems();
    assert(items.pItem().valid());
    assert(items.pItem().pToken1().valid());
    assert_eq(TOKEN_a, items.pItem().pToken1().token());
    assert_eq(11, items.pItem().pToken1().pvalue());
    assert(items.pItemsMore().valid());
    ItemsMore itemsmore = items.pItemsMore();
    assert(itemsmore.pItem().valid());
    assert(itemsmore.pItem().pItem().valid());
    assert(itemsmore.pItem().pItem().pItem().valid());
    assert(itemsmore.pItem().pItem().pItem().pToken1().valid());
    assert_eq(TOKEN_b, itemsmore.pItem().pItem().pItem().pToken1().token());
    assert_eq(22, itemsmore.pItem().pItem().pItem().pToken1().pvalue());
    assert(itemsmore.pItemsMore().valid());
    itemsmore = itemsmore.pItemsMore();
    assert(itemsmore.pItem().valid());
    assert(itemsmore.pItem().pToken1().valid());
    assert_eq(TOKEN_b, itemsmore.pItem().pToken1().token());
    assert_eq(22, itemsmore.pItem().pToken1().pvalue());
    assert(!itemsmore.pItemsMore().valid());

    p_context_delete(context);

    input = "";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert_eq(P_SUCCESS, p_parse(context));
    start = p_result(context);
    assert(!start.pItems().valid());

    p_context_delete(context);

    input = "2 1";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert_eq(P_SUCCESS, p_parse(context));
    start = p_result(context);
    assert(start.pItems().valid());
    assert(start.pItems().pItem().valid());
    assert(start.pItems().pItem().pDual().valid());
    assert(start.pItems().pItem().pDual().pTwo1().valid());
    assert(start.pItems().pItem().pDual().pOne2().valid());
    assert(!start.pItems().pItem().pDual().pTwo2().valid());
    assert(!start.pItems().pItem().pDual().pOne1().valid());

    p_context_delete(context);

    return 0;
}
