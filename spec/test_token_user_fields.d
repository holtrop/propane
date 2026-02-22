import testparser;
import std.stdio;

int main()
{
    return 0;
}

unittest
{
    string input =
        "# c1\n" ~
        "#  c2\n" ~
        "\n" ~
        "first\n" ~
        "\n   \n  \n" ~
        "  # s1\n" ~
        "   #   s2\n" ~
        "second\n";
    p_context_t * context;
    context = p_context_new(input);
    assert(p_parse(context) == P_SUCCESS);
    Start * start = p_result(context);
}
