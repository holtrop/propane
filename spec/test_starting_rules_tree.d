import testparser;
import std.stdio;
import testutils;

int main()
{
    return 0;
}

unittest
{
    string input = "bbbb";
    p_context_t context;
    p_context_init(&context, input);
    assert(p_parse(&context) == P_SUCCESS);
    Start * start = p_result(&context);
    assert(start.bs);
    assert(start.bs.b);
    assert(start.bs.bs.b);
    assert(start.bs.bs.bs.b);
    assert(start.bs.bs.bs.bs.b);

    p_context_init(&context, input);
    assert(p_parse_Bs(&context) == P_SUCCESS);
    Bs * bs = p_result_Bs(&context);
    assert(bs.b);
    assert(bs.bs.b);
    assert(bs.bs.bs.b);
    assert(bs.bs.bs.bs.b);

    input = "c";
    p_context_init(&context, input);
    assert(p_parse_R(&context) == P_SUCCESS);
    R * r = p_result_R(&context);
    assert(r.c);
}
