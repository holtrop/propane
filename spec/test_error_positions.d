import testparser;
import std.stdio;

int main()
{
    return 0;
}

unittest
{
    string input = "a 42";
    p_context_t context;
    p_context_init(&context, input);
    assert(p_parse(&context) == P_SUCCESS);

    input = "a\n123\na  a";
    p_context_init(&context, input);
    assert(p_parse(&context) == P_UNEXPECTED_TOKEN);
    assert(p_position(&context) == p_position_t(2, 3));

    input = "12";
    p_context_init(&context, input);
    assert(p_parse(&context) == P_UNEXPECTED_TOKEN);
    assert(p_position(&context) == p_position_t(0, 0));

    input = "a 12\n\nab";
    p_context_init(&context, input);
    assert(p_parse(&context) == P_UNEXPECTED_INPUT);
    assert(p_position(&context) == p_position_t(2, 1));

    input = "a 12\n\na\n\n77\na   \xAA";
    p_context_init(&context, input);
    assert(p_parse(&context) == P_DECODE_ERROR);
    writeln(p_position(&context));
    assert(p_position(&context) == p_position_t(5, 4));
}
