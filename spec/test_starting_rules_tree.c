#include "testparser.h"
#include <assert.h>
#include <string.h>
#include "testutils.h"

int main()
{
    char const * input = "bbbb";
    p_context_t * context;
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse(context) == P_SUCCESS);
    Start * start = p_result(context);
    assert_not_null(start->bs);
    assert_not_null(start->bs->b);
    assert_not_null(start->bs->bs->b);
    assert_not_null(start->bs->bs->bs->b);
    assert_not_null(start->bs->bs->bs->bs->b);
    p_tree_delete(start);
    p_context_delete(context);

    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse_Bs(context) == P_SUCCESS);
    Bs * bs = p_result_Bs(context);
    assert_not_null(bs->b);
    assert_not_null(bs->bs->b);
    assert_not_null(bs->bs->bs->b);
    assert_not_null(bs->bs->bs->bs->b);
    p_tree_delete_Bs(bs);
    p_context_delete(context);

    input = "c";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse_R(context) == P_SUCCESS);
    R * r = p_result_R(context);
    assert_not_null(r->c);
    p_tree_delete_R(r);
    p_context_delete(context);

    return 0;
}
