import testparser;
import std.stdio;
import testutils;

int main()
{
    return 0;
}

unittest
{
    string input = "a, ((b)), b";
    p_context_t * context;
    context = p_context_new(input);
    assert_eq(P_SUCCESS, p_parse(context));
    Start * start = p_result(context);
    assert(start.pItems1 !is null);
    assert(start.pItems !is null);
    Items * items = start.pItems;
    assert(items.pItem !is null);
    assert(items.pItem.pToken1 !is null);
    assert_eq(TOKEN_a, items.pItem.pToken1.token);
    assert_eq(11, items.pItem.pToken1.pvalue);
    assert(items.pItemsMore !is null);
    ItemsMore * itemsmore = items.pItemsMore;
    assert(itemsmore.pItem !is null);
    assert(itemsmore.pItem.pItem !is null);
    assert(itemsmore.pItem.pItem.pItem !is null);
    assert(itemsmore.pItem.pItem.pItem.pToken1 !is null);
    assert_eq(TOKEN_b, itemsmore.pItem.pItem.pItem.pToken1.token);
    assert_eq(22, itemsmore.pItem.pItem.pItem.pToken1.pvalue);
    assert(itemsmore.pItemsMore !is null);
    itemsmore = itemsmore.pItemsMore;
    assert(itemsmore.pItem !is null);
    assert(itemsmore.pItem.pToken1 !is null);
    assert_eq(TOKEN_b, itemsmore.pItem.pToken1.token);
    assert_eq(22, itemsmore.pItem.pToken1.pvalue);
    assert(itemsmore.pItemsMore is null);

    input = "";
    context = p_context_new(input);
    assert_eq(P_SUCCESS, p_parse(context));
    start = p_result(context);
    assert(start.pItems is null);

    input = "2 1";
    context = p_context_new(input);
    assert_eq(P_SUCCESS, p_parse(context));
    start = p_result(context);
    assert(start.pItems !is null);
    assert(start.pItems.pItem !is null);
    assert(start.pItems.pItem.pDual !is null);
    assert(start.pItems.pItem.pDual.pTwo1 !is null);
    assert(start.pItems.pItem.pDual.pOne2 !is null);
    assert(start.pItems.pItem.pDual.pTwo2 is null);
    assert(start.pItems.pItem.pDual.pOne1 is null);
}
