import testparser;
import std.stdio;
import testutils;

int main()
{
    return 0;
}

unittest
{
    string input = "abbccc";
    p_context_t context;
    p_context_init(&context, input);
    assert(p_parse(&context) == P_SUCCESS);
    Start * start = p_result(&context);
    assert_eq(0, start.pT1.pToken.position.row);
    assert_eq(0, start.pT1.pToken.position.col);
    assert_eq(0, start.pT1.pToken.end_position.row);
    assert_eq(0, start.pT1.pToken.end_position.col);
    assert_eq(0, start.pT2.pToken.position.row);
    assert_eq(1, start.pT2.pToken.position.col);
    assert_eq(0, start.pT2.pToken.end_position.row);
    assert_eq(2, start.pT2.pToken.end_position.col);
    assert_eq(0, start.pT3.pToken.position.row);
    assert_eq(3, start.pT3.pToken.position.col);
    assert_eq(0, start.pT3.pToken.end_position.row);
    assert_eq(5, start.pT3.pToken.end_position.col);

    input = "\n\n  bb\nccc\n\n     a";
    p_context_init(&context, input);
    assert(p_parse(&context) == P_SUCCESS);
    start = p_result(&context);
    assert_eq(2, start.pT1.pToken.position.row);
    assert_eq(2, start.pT1.pToken.position.col);
    assert_eq(2, start.pT1.pToken.end_position.row);
    assert_eq(3, start.pT1.pToken.end_position.col);
    assert_eq(3, start.pT2.pToken.position.row);
    assert_eq(0, start.pT2.pToken.position.col);
    assert_eq(3, start.pT2.pToken.end_position.row);
    assert_eq(2, start.pT2.pToken.end_position.col);
    assert_eq(5, start.pT3.pToken.position.row);
    assert_eq(5, start.pT3.pToken.position.col);
    assert_eq(5, start.pT3.pToken.end_position.row);
    assert_eq(5, start.pT3.pToken.end_position.col);
}
