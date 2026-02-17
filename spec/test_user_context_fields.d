import testparser;
import std.stdio;
import testutils;

int main()
{
    return 0;
}

unittest
{
    string input = "aaa\n\n\na\n    # comment 1\na  a    aa\n\naa\n#    comment 2\na\n";
    p_context_t * context;
    context = p_context_new(input);
    assert(p_parse(context) == P_SUCCESS);

    stderr.writeln("comments: ", context.comments);
    stderr.writeln("acount: ", context.acount);
}
