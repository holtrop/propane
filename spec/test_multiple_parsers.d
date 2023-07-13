import testparsermyp1;
import testparsermyp2;
import std.stdio;

int main()
{
    return 0;
}

unittest
{
    string input1 = "a\n1";
    myp1_context_t context1;
    myp1_context_init(&context1, input1);
    assert(myp1_parse(&context1) == MYP1_SUCCESS);

    string input2 = "bcb";
    myp2_context_t context2;
    myp2_context_init(&context2, input2);
    assert(myp2_parse(&context2) == MYP2_SUCCESS);
}
