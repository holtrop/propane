#include "testparser.h"
#include <assert.h>
#include <string.h>
#include "testutils.h"

int main()
{
    char const * input = "b";
    p_context_t context;
    p_context_init(&context, (uint8_t const *)input, strlen(input));
    assert(p_parse(&context) == P_SUCCESS);
    Start * start = p_result(&context);
    assert(start->pToken1 == NULL);
    assert(start->pToken2 != NULL);
    assert_eq(TOKEN_b, start->pToken2->token);
    assert(start->pR3 == NULL);
    assert(start->pR == NULL);

    p_free_tree(start);

    input = "abcd";
    p_context_init(&context, (uint8_t const *)input, strlen(input));
    assert(p_parse(&context) == P_SUCCESS);
    start = p_result(&context);
    assert(start->pToken1 != NULL);
    assert_eq(TOKEN_a, start->pToken1->token);
    assert(start->pToken2 != NULL);
    assert(start->pR3 != NULL);
    assert(start->pR != NULL);
    assert(start->pR == start->pR3);
    assert_eq(TOKEN_c, start->pR->pToken1->token);

    p_free_tree(start);

    input = "bdc";
    p_context_init(&context, (uint8_t const *)input, strlen(input));
    assert(p_parse(&context) == P_SUCCESS);
    start = p_result(&context);
    assert(start->pToken1 == NULL);
    assert(start->pToken2 != NULL);
    assert(start->pR != NULL);
    assert_eq(TOKEN_d, start->pR->pToken1->token);

    p_free_tree(start);

    return 0;
}

