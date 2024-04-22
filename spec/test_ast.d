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
    p_context_t context;
    p_context_init(&context, input);
    assert_eq(P_SUCCESS, p_parse(&context));
    Start * start = p_result(&context);
    assert(start.pItems1 !is null);
    Items * items = start.pItems1;
    assert(items.pItem1 !is null);
    assert(items.pItem1.pToken1 !is null);
    assert_eq(TOKEN_a, items.pItem1.pToken1.token);
    assert_eq(11, items.pItem1.pToken1.pvalue);
    assert(items.pItemsMore2 !is null);
    ItemsMore * itemsmore = items.pItemsMore2;
    assert(itemsmore.pItem2 !is null);
    assert(itemsmore.pItem2.pItem2 !is null);
    assert(itemsmore.pItem2.pItem2.pItem2 !is null);
    assert(itemsmore.pItem2.pItem2.pItem2.pToken1 !is null);
    assert_eq(TOKEN_b, itemsmore.pItem2.pItem2.pItem2.pToken1.token);
    assert_eq(22, itemsmore.pItem2.pItem2.pItem2.pToken1.pvalue);
    assert(itemsmore.pItemsMore3 !is null);
    itemsmore = itemsmore.pItemsMore3;
    assert(itemsmore.pItem2 !is null);
    assert(itemsmore.pItem2.pToken1 !is null);
    assert_eq(TOKEN_b, itemsmore.pItem2.pToken1.token);
    assert_eq(22, itemsmore.pItem2.pToken1.pvalue);
    assert(itemsmore.pItemsMore3 is null);

    input = "";
    p_context_init(&context, input);
    assert_eq(P_SUCCESS, p_parse(&context));
    start = p_result(&context);
    assert(start.pItems1 is null);

    input = "2 1";
    p_context_init(&context, input);
    assert_eq(P_SUCCESS, p_parse(&context));
    start = p_result(&context);
    assert(start.pItems1 !is null);
    assert(start.pItems1.pItem1 !is null);
    assert(start.pItems1.pItem1.pDual1 !is null);
    assert(start.pItems1.pItem1.pDual1.pTwo1 !is null);
    assert(start.pItems1.pItem1.pDual1.pOne2 !is null);
    assert(start.pItems1.pItem1.pDual1.pTwo2 is null);
    assert(start.pItems1.pItem1.pDual1.pOne1 is null);
}
