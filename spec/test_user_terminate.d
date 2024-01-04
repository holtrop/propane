import testparser;
import std.stdio;

int main()
{
    return 0;
}

unittest
{
    string input = "aacc";
    p_context_t context;
    p_context_init(&context, input);
    assert(p_parse(&context) == P_SUCCESS);

    input = "abc";
    p_context_init(&context, input);
    assert(p_parse(&context) == P_USER_TERMINATED);
    assert(p_user_terminate_code(&context) == 4200);
}
