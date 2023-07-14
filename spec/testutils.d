import std.stdio;

void assert_eq(T)(T expected, T actual, string file = __FILE__, size_t line = __LINE__)
{
    if (expected != actual)
    {
        stderr.writeln(file, ":", line, ": expected ", expected, ", got ", actual);
        assert(false);
    }
}
