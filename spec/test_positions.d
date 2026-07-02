import testparser;
import std.stdio;

int main()
{
    return 0;
}

unittest
{
    string input = "    Hello\n\n        4200\n";
    p_context_t * context;
    context = p_context_new(input);
    assert(p_parse(context) == P_SUCCESS);

    writeln();

    input = "\n tok2";
    context = p_context_new(input);
    assert(p_parse(context) == P_SUCCESS);

    writeln();

    input = "  tok1";
    context = p_context_new(input);
    assert(p_parse(context) == P_SUCCESS);
}
