import testparser;
import std.stdio;
import testutils;

int main()
{
    return 0;
}

unittest
{
    string input = "\na\n  bb ccc";
    p_context_t context;
    p_context_init(&context, input);
    assert(p_parse(&context) == P_SUCCESS);
    Start * start = p_result(&context);

    assert_eq(1, start.pT1.pToken.position.row);
    assert_eq(0, start.pT1.pToken.position.col);
    assert_eq(1, start.pT1.pToken.end_position.row);
    assert_eq(0, start.pT1.pToken.end_position.col);
    assert(start.pT1.pA.position.valid);
    assert_eq(2, start.pT1.pA.position.row);
    assert_eq(2, start.pT1.pA.position.col);
    assert_eq(2, start.pT1.pA.end_position.row);
    assert_eq(7, start.pT1.pA.end_position.col);
    assert_eq(1, start.pT1.position.row);
    assert_eq(0, start.pT1.position.col);
    assert_eq(2, start.pT1.end_position.row);
    assert_eq(7, start.pT1.end_position.col);

    assert_eq(1, start.position.row);
    assert_eq(0, start.position.col);
    assert_eq(2, start.end_position.row);
    assert_eq(7, start.end_position.col);

    input = "a\nbb";
    p_context_init(&context, input);
    assert(p_parse(&context) == P_SUCCESS);
    start = p_result(&context);

    assert_eq(0, start.pT1.pToken.position.row);
    assert_eq(0, start.pT1.pToken.position.col);
    assert_eq(0, start.pT1.pToken.end_position.row);
    assert_eq(0, start.pT1.pToken.end_position.col);
    assert(start.pT1.pA.position.valid);
    assert_eq(1, start.pT1.pA.position.row);
    assert_eq(0, start.pT1.pA.position.col);
    assert_eq(1, start.pT1.pA.end_position.row);
    assert_eq(1, start.pT1.pA.end_position.col);
    assert_eq(0, start.pT1.position.row);
    assert_eq(0, start.pT1.position.col);
    assert_eq(1, start.pT1.end_position.row);
    assert_eq(1, start.pT1.end_position.col);

    assert_eq(0, start.position.row);
    assert_eq(0, start.position.col);
    assert_eq(1, start.end_position.row);
    assert_eq(1, start.end_position.col);

    input = "a\nc\nc";
    p_context_init(&context, input);
    assert(p_parse(&context) == P_SUCCESS);
    start = p_result(&context);

    assert_eq(0, start.pT1.pToken.position.row);
    assert_eq(0, start.pT1.pToken.position.col);
    assert_eq(0, start.pT1.pToken.end_position.row);
    assert_eq(0, start.pT1.pToken.end_position.col);
    assert(start.pT1.pA.position.valid);
    assert_eq(1, start.pT1.pA.position.row);
    assert_eq(0, start.pT1.pA.position.col);
    assert_eq(2, start.pT1.pA.end_position.row);
    assert_eq(0, start.pT1.pA.end_position.col);
    assert_eq(0, start.pT1.position.row);
    assert_eq(0, start.pT1.position.col);
    assert_eq(2, start.pT1.end_position.row);
    assert_eq(0, start.pT1.end_position.col);

    assert_eq(0, start.position.row);
    assert_eq(0, start.position.col);
    assert_eq(2, start.end_position.row);
    assert_eq(0, start.end_position.col);

    input = "a";
    p_context_init(&context, input);
    assert(p_parse(&context) == P_SUCCESS);
    start = p_result(&context);

    assert_eq(0, start.pT1.pToken.position.row);
    assert_eq(0, start.pT1.pToken.position.col);
    assert_eq(0, start.pT1.pToken.end_position.row);
    assert_eq(0, start.pT1.pToken.end_position.col);
    assert(!start.pT1.pA.position.valid);
    assert_eq(0, start.pT1.position.row);
    assert_eq(0, start.pT1.position.col);
    assert_eq(0, start.pT1.end_position.row);
    assert_eq(0, start.pT1.end_position.col);

    assert_eq(0, start.position.row);
    assert_eq(0, start.position.col);
    assert_eq(0, start.end_position.row);
    assert_eq(0, start.end_position.col);
}
