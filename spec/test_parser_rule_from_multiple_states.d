import testparser;
import std.stdio;

int main()
{
    return 0;
}

unittest
{
    string input = "a";
    p_context_t context;
    p_context_init(&context, input);
    assert(p_parse(&context) == P_UNEXPECTED_TOKEN);
    assert(p_position(&context) == p_position_t(1, 2));
    assert(context.token == TOKEN___EOF);

    input = "a b";
    p_context_init(&context, input);
    assert(p_parse(&context) == P_SUCCESS);

    input = "bb";
    p_context_init(&context, input);
    assert(p_parse(&context) == P_SUCCESS);
}
