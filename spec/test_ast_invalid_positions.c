#include "testparser.h"
#include <assert.h>
#include <string.h>
#include "testutils.h"

int main()
{
    char const * input = "\na\n  bb ccc";
    p_context_t context;
    p_context_init(&context, (uint8_t const *)input, strlen(input));
    assert(p_parse(&context) == P_SUCCESS);
    Start * start = p_result(&context);

    assert_eq(2, start->pT1->pToken->position.row);
    assert_eq(1, start->pT1->pToken->position.col);
    assert_eq(2, start->pT1->pToken->end_position.row);
    assert_eq(1, start->pT1->pToken->end_position.col);
    assert(p_position_valid(start->pT1->pA->position));
    assert_eq(3, start->pT1->pA->position.row);
    assert_eq(3, start->pT1->pA->position.col);
    assert_eq(3, start->pT1->pA->end_position.row);
    assert_eq(8, start->pT1->pA->end_position.col);
    assert_eq(2, start->pT1->position.row);
    assert_eq(1, start->pT1->position.col);
    assert_eq(3, start->pT1->end_position.row);
    assert_eq(8, start->pT1->end_position.col);

    assert_eq(2, start->position.row);
    assert_eq(1, start->position.col);
    assert_eq(3, start->end_position.row);
    assert_eq(8, start->end_position.col);

    input = "a\nbb";
    p_context_init(&context, (uint8_t const *)input, strlen(input));
    assert(p_parse(&context) == P_SUCCESS);
    start = p_result(&context);

    assert_eq(1, start->pT1->pToken->position.row);
    assert_eq(1, start->pT1->pToken->position.col);
    assert_eq(1, start->pT1->pToken->end_position.row);
    assert_eq(1, start->pT1->pToken->end_position.col);
    assert(p_position_valid(start->pT1->pA->position));
    assert_eq(2, start->pT1->pA->position.row);
    assert_eq(1, start->pT1->pA->position.col);
    assert_eq(2, start->pT1->pA->end_position.row);
    assert_eq(2, start->pT1->pA->end_position.col);
    assert_eq(1, start->pT1->position.row);
    assert_eq(1, start->pT1->position.col);
    assert_eq(2, start->pT1->end_position.row);
    assert_eq(2, start->pT1->end_position.col);

    assert_eq(1, start->position.row);
    assert_eq(1, start->position.col);
    assert_eq(2, start->end_position.row);
    assert_eq(2, start->end_position.col);

    input = "a\nc\nc";
    p_context_init(&context, (uint8_t const *)input, strlen(input));
    assert(p_parse(&context) == P_SUCCESS);
    start = p_result(&context);

    assert_eq(1, start->pT1->pToken->position.row);
    assert_eq(1, start->pT1->pToken->position.col);
    assert_eq(1, start->pT1->pToken->end_position.row);
    assert_eq(1, start->pT1->pToken->end_position.col);
    assert(p_position_valid(start->pT1->pA->position));
    assert_eq(2, start->pT1->pA->position.row);
    assert_eq(1, start->pT1->pA->position.col);
    assert_eq(3, start->pT1->pA->end_position.row);
    assert_eq(1, start->pT1->pA->end_position.col);
    assert_eq(1, start->pT1->position.row);
    assert_eq(1, start->pT1->position.col);
    assert_eq(3, start->pT1->end_position.row);
    assert_eq(1, start->pT1->end_position.col);

    assert_eq(1, start->position.row);
    assert_eq(1, start->position.col);
    assert_eq(3, start->end_position.row);
    assert_eq(1, start->end_position.col);

    input = "a";
    p_context_init(&context, (uint8_t const *)input, strlen(input));
    assert(p_parse(&context) == P_SUCCESS);
    start = p_result(&context);

    assert_eq(1, start->pT1->pToken->position.row);
    assert_eq(1, start->pT1->pToken->position.col);
    assert_eq(1, start->pT1->pToken->end_position.row);
    assert_eq(1, start->pT1->pToken->end_position.col);
    assert(!p_position_valid(start->pT1->pA->position));
    assert_eq(1, start->pT1->position.row);
    assert_eq(1, start->pT1->position.col);
    assert_eq(1, start->pT1->end_position.row);
    assert_eq(1, start->pT1->end_position.col);

    assert_eq(1, start->position.row);
    assert_eq(1, start->position.col);
    assert_eq(1, start->end_position.row);
    assert_eq(1, start->end_position.col);

    return 0;
}
