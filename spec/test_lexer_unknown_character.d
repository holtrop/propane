import testparser;
import std.stdio;

int main()
{
    return 0;
}

unittest
{
    string input = `x`;
    p_context_t * context;
    context = p_context_new(input);
    assert(p_parse(context) == P_UNEXPECTED_INPUT);

    input = `123`;
    context = p_context_new(input);
    assert(p_parse(context) == P_SUCCESS);
    assert(p_result(context) == 123u);
}
