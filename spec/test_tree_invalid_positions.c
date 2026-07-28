#include "testparser.h"
#include <assert.h>
#include <string.h>
#include "testutils.h"

int main()
{
    char const * input = "\na\n  bb ccc";
    p_context_t * context;
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse(context) == P_SUCCESS);
    Start start = p_result(context);
    T t1 = p_Start_pT1(start);
    Token k1 = p_T_pToken(t1);
    A a1 = p_T_pA(t1);

    assert_eq(2, p_node_position(k1).row);
    assert_eq(1, p_node_position(k1).col);
    assert_eq(2, p_node_end_position(k1).row);
    assert_eq(1, p_node_end_position(k1).col);
    assert(p_position_valid(p_node_position(a1)));
    assert_eq(3, p_node_position(a1).row);
    assert_eq(3, p_node_position(a1).col);
    assert_eq(3, p_node_end_position(a1).row);
    assert_eq(8, p_node_end_position(a1).col);
    assert_eq(2, p_node_position(t1).row);
    assert_eq(1, p_node_position(t1).col);
    assert_eq(3, p_node_end_position(t1).row);
    assert_eq(8, p_node_end_position(t1).col);

    assert_eq(2, p_node_position(start).row);
    assert_eq(1, p_node_position(start).col);
    assert_eq(3, p_node_end_position(start).row);
    assert_eq(8, p_node_end_position(start).col);

    p_context_delete(context);

    input = "a\nbb";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse(context) == P_SUCCESS);
    start = p_result(context);
    t1 = p_Start_pT1(start);
    k1 = p_T_pToken(t1);
    a1 = p_T_pA(t1);

    assert_eq(1, p_node_position(k1).row);
    assert_eq(1, p_node_position(k1).col);
    assert_eq(1, p_node_end_position(k1).row);
    assert_eq(1, p_node_end_position(k1).col);
    assert(p_position_valid(p_node_position(a1)));
    assert_eq(2, p_node_position(a1).row);
    assert_eq(1, p_node_position(a1).col);
    assert_eq(2, p_node_end_position(a1).row);
    assert_eq(2, p_node_end_position(a1).col);
    assert_eq(1, p_node_position(t1).row);
    assert_eq(1, p_node_position(t1).col);
    assert_eq(2, p_node_end_position(t1).row);
    assert_eq(2, p_node_end_position(t1).col);

    assert_eq(1, p_node_position(start).row);
    assert_eq(1, p_node_position(start).col);
    assert_eq(2, p_node_end_position(start).row);
    assert_eq(2, p_node_end_position(start).col);

    p_context_delete(context);

    input = "a\nc\nc";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse(context) == P_SUCCESS);
    start = p_result(context);
    t1 = p_Start_pT1(start);
    k1 = p_T_pToken(t1);
    a1 = p_T_pA(t1);

    assert_eq(1, p_node_position(k1).row);
    assert_eq(1, p_node_position(k1).col);
    assert_eq(1, p_node_end_position(k1).row);
    assert_eq(1, p_node_end_position(k1).col);
    assert(p_position_valid(p_node_position(a1)));
    assert_eq(2, p_node_position(a1).row);
    assert_eq(1, p_node_position(a1).col);
    assert_eq(3, p_node_end_position(a1).row);
    assert_eq(1, p_node_end_position(a1).col);
    assert_eq(1, p_node_position(t1).row);
    assert_eq(1, p_node_position(t1).col);
    assert_eq(3, p_node_end_position(t1).row);
    assert_eq(1, p_node_end_position(t1).col);

    assert_eq(1, p_node_position(start).row);
    assert_eq(1, p_node_position(start).col);
    assert_eq(3, p_node_end_position(start).row);
    assert_eq(1, p_node_end_position(start).col);

    p_context_delete(context);

    input = "a";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse(context) == P_SUCCESS);
    start = p_result(context);
    t1 = p_Start_pT1(start);
    k1 = p_T_pToken(t1);
    a1 = p_T_pA(t1);

    assert_eq(1, p_node_position(k1).row);
    assert_eq(1, p_node_position(k1).col);
    assert_eq(1, p_node_end_position(k1).row);
    assert_eq(1, p_node_end_position(k1).col);
    assert(!p_position_valid(p_node_position(a1)));
    assert_eq(1, p_node_position(t1).row);
    assert_eq(1, p_node_position(t1).col);
    assert_eq(1, p_node_end_position(t1).row);
    assert_eq(1, p_node_end_position(t1).col);

    assert_eq(1, p_node_position(start).row);
    assert_eq(1, p_node_position(start).col);
    assert_eq(1, p_node_end_position(start).row);
    assert_eq(1, p_node_end_position(start).col);

    p_context_delete(context);

    return 0;
}
