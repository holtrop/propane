#include "testparser.h"
#include <assert.h>
#include <string.h>
#include "testutils.h"

int main()
{
    char const * input = "abbccc";
    p_context_t context;
    p_context_init(&context, (uint8_t const *)input, strlen(input));
    assert(p_parse(&context) == P_SUCCESS);
    Start * start = p_result(&context);

    assert_eq(0, start->pT1->pToken->position.row);
    assert_eq(0, start->pT1->pToken->position.col);
    assert_eq(0, start->pT1->pToken->end_position.row);
    assert_eq(0, start->pT1->pToken->end_position.col);
    assert_eq(0, start->pT1->position.row);
    assert_eq(0, start->pT1->position.col);
    assert_eq(0, start->pT1->end_position.row);
    assert_eq(0, start->pT1->end_position.col);

    assert_eq(0, start->pT2->pToken->position.row);
    assert_eq(1, start->pT2->pToken->position.col);
    assert_eq(0, start->pT2->pToken->end_position.row);
    assert_eq(2, start->pT2->pToken->end_position.col);
    assert_eq(0, start->pT2->position.row);
    assert_eq(1, start->pT2->position.col);
    assert_eq(0, start->pT2->end_position.row);
    assert_eq(2, start->pT2->end_position.col);

    assert_eq(0, start->pT3->pToken->position.row);
    assert_eq(3, start->pT3->pToken->position.col);
    assert_eq(0, start->pT3->pToken->end_position.row);
    assert_eq(5, start->pT3->pToken->end_position.col);
    assert_eq(0, start->pT3->position.row);
    assert_eq(3, start->pT3->position.col);
    assert_eq(0, start->pT3->end_position.row);
    assert_eq(5, start->pT3->end_position.col);

    assert_eq(0, start->position.row);
    assert_eq(0, start->position.col);
    assert_eq(0, start->end_position.row);
    assert_eq(5, start->end_position.col);

    input = "\n\n  bb\nc\ncc\n\n     a";
    p_context_init(&context, (uint8_t const *)input, strlen(input));
    assert(p_parse(&context) == P_SUCCESS);
    start = p_result(&context);

    assert_eq(2, start->pT1->pToken->position.row);
    assert_eq(2, start->pT1->pToken->position.col);
    assert_eq(2, start->pT1->pToken->end_position.row);
    assert_eq(3, start->pT1->pToken->end_position.col);
    assert_eq(2, start->pT1->position.row);
    assert_eq(2, start->pT1->position.col);
    assert_eq(2, start->pT1->end_position.row);
    assert_eq(3, start->pT1->end_position.col);

    assert_eq(3, start->pT2->pToken->position.row);
    assert_eq(0, start->pT2->pToken->position.col);
    assert_eq(4, start->pT2->pToken->end_position.row);
    assert_eq(1, start->pT2->pToken->end_position.col);
    assert_eq(3, start->pT2->position.row);
    assert_eq(0, start->pT2->position.col);
    assert_eq(4, start->pT2->end_position.row);
    assert_eq(1, start->pT2->end_position.col);

    assert_eq(6, start->pT3->pToken->position.row);
    assert_eq(5, start->pT3->pToken->position.col);
    assert_eq(6, start->pT3->pToken->end_position.row);
    assert_eq(5, start->pT3->pToken->end_position.col);
    assert_eq(6, start->pT3->position.row);
    assert_eq(5, start->pT3->position.col);
    assert_eq(6, start->pT3->end_position.row);
    assert_eq(5, start->pT3->end_position.col);

    assert_eq(2, start->position.row);
    assert_eq(2, start->position.col);
    assert_eq(6, start->end_position.row);
    assert_eq(5, start->end_position.col);

    return 0;
}

