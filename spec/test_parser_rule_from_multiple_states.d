import testparser;
import std.stdio;

int main()
{
    return 0;
}

unittest
{
    string input = "a";
    p_context_t * context;
    context = p_context_new(input);
    assert(p_parse(context) == P_UNEXPECTED_TOKEN);
    assert(p_position(context) == p_position_t(1, 2));
    assert(context.token == TOKEN___EOF);

    input = "a b";
    context = p_context_new(input);
    assert(p_parse(context) == P_SUCCESS);

    input = "bb";
    context = p_context_new(input);
    assert(p_parse(context) == P_SUCCESS);
}
