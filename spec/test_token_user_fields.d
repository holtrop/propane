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
    p_context_t * context = p_context_new(input);
    assert(p_parse(context) == P_SUCCESS);
    Start * start = p_result(context);
    assert(start.pIDs);
    assert(start.pIDs.id);
    assert(start.pIDs.id.comments == "# c1\n#  c2\n");
    assert(start.pIDs.pIDs);
    assert(start.pIDs.pIDs.id);
    assert(start.pIDs.pIDs.id.comments == "# s1\n#   s2\n");

    p_tree_delete(start);
}
