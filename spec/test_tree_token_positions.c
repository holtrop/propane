#include "testparser.h"
#include <assert.h>
#include <string.h>
#include "testutils.h"

int main()
{
    char const * input = "abbccc";
    p_context_t * context;
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse(context) == P_SUCCESS);
    Start start = p_result(context);
    T t1 = p_Start_pT1(start);
    T t2 = p_Start_pT2(start);
    T t3 = p_Start_pT3(start);
    Token k1 = p_T_pToken(t1);
    Token k2 = p_T_pToken(t2);
    Token k3 = p_T_pToken(t3);

    assert_eq(1, p_node_position(k1).row);
    assert_eq(1, p_node_position(k1).col);
    assert_eq(1, p_node_end_position(k1).row);
    assert_eq(1, p_node_end_position(k1).col);
    assert_eq(1, p_node_position(t1).row);
    assert_eq(1, p_node_position(t1).col);
    assert_eq(1, p_node_end_position(t1).row);
    assert_eq(1, p_node_end_position(t1).col);

    assert_eq(1, p_node_position(k2).row);
    assert_eq(2, p_node_position(k2).col);
    assert_eq(1, p_node_end_position(k2).row);
    assert_eq(3, p_node_end_position(k2).col);
    assert_eq(1, p_node_position(t2).row);
    assert_eq(2, p_node_position(t2).col);
    assert_eq(1, p_node_end_position(t2).row);
    assert_eq(3, p_node_end_position(t2).col);

    assert_eq(1, p_node_position(k3).row);
    assert_eq(4, p_node_position(k3).col);
    assert_eq(1, p_node_end_position(k3).row);
    assert_eq(6, p_node_end_position(k3).col);
    assert_eq(1, p_node_position(t3).row);
    assert_eq(4, p_node_position(t3).col);
    assert_eq(1, p_node_end_position(t3).row);
    assert_eq(6, p_node_end_position(t3).col);

    assert_eq(1, p_node_position(start).row);
    assert_eq(1, p_node_position(start).col);
    assert_eq(1, p_node_end_position(start).row);
    assert_eq(6, p_node_end_position(start).col);

    p_context_delete(context);

    input = "\n\n  bb\nc\ncc\n\n     a";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse(context) == P_SUCCESS);
    start = p_result(context);
    t1 = p_Start_pT1(start);
    t2 = p_Start_pT2(start);
    t3 = p_Start_pT3(start);
    k1 = p_T_pToken(t1);
    k2 = p_T_pToken(t2);
    k3 = p_T_pToken(t3);

    assert_eq(3, p_node_position(k1).row);
    assert_eq(3, p_node_position(k1).col);
    assert_eq(3, p_node_end_position(k1).row);
    assert_eq(4, p_node_end_position(k1).col);
    assert_eq(3, p_node_position(t1).row);
    assert_eq(3, p_node_position(t1).col);
    assert_eq(3, p_node_end_position(t1).row);
    assert_eq(4, p_node_end_position(t1).col);

    assert_eq(4, p_node_position(k2).row);
    assert_eq(1, p_node_position(k2).col);
    assert_eq(5, p_node_end_position(k2).row);
    assert_eq(2, p_node_end_position(k2).col);
    assert_eq(4, p_node_position(t2).row);
    assert_eq(1, p_node_position(t2).col);
    assert_eq(5, p_node_end_position(t2).row);
    assert_eq(2, p_node_end_position(t2).col);

    assert_eq(7, p_node_position(k3).row);
    assert_eq(6, p_node_position(k3).col);
    assert_eq(7, p_node_end_position(k3).row);
    assert_eq(6, p_node_end_position(k3).col);
    assert_eq(7, p_node_position(t3).row);
    assert_eq(6, p_node_position(t3).col);
    assert_eq(7, p_node_end_position(t3).row);
    assert_eq(6, p_node_end_position(t3).col);

    assert_eq(3, p_node_position(start).row);
    assert_eq(3, p_node_position(start).col);
    assert_eq(7, p_node_end_position(start).row);
    assert_eq(6, p_node_end_position(start).col);

    p_context_delete(context);

    return 0;
}
