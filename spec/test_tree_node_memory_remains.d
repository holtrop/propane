import testparser;
import std.stdio;
import testutils;

int main()
{
    return 0;
}

unittest
{
    string input = "
# 0
def byte_val() -> byte
{
    return 0x42;
}

# 1
def short_val() -> short
{
    return 0x4242;
}

# 2
def int_val() -> int
{
    return 0x42424242;
}

# 3
def long_val() -> long
{
    return 0x4242_4242_4242_4242;
}

# 4
def ssize_t_val() -> ssize_t
{
    return 0x42424242;
}

# 5
def byte_to_short() -> short
{
    return byte_val();
}

# 6
def byte_to_int() -> int
{
    return byte_val();
}

# 7
def byte_to_long() -> long
{
    return byte_val();
}

# 8
def byte_to_ssize_t() -> ssize_t
{
    return byte_val();
}

# 9
def short_to_byte() -> byte
{
    return short_val();
}

# 10
def short_to_int() -> int
{
    return short_val();
}

# 11
def short_to_long() -> long
{
    return short_val();
}

# 12
def short_to_ssize_t() -> ssize_t
{
    return short_val();
}

# 13
def int_to_byte() -> byte
{
    return int_val();
}

# 14
def int_to_short() -> short
{
    return int_val();
}

# 15
def int_to_long() -> long
{
    return int_val();
}

# 16
def int_to_ssize_t() -> ssize_t
{
    return int_val();
}

# 17
def long_to_byte() -> byte
{
    return long_val();
}

# 18
def long_to_short() -> short
{
    return long_val();
}

# 19
def long_to_int() -> int
{
    return long_val();
}

# 20
def long_to_ssize_t() -> ssize_t
{
    return long_val();
}

# 21
def ssize_t_to_byte() -> byte
{
    return ssize_t_val();
}

# 22
def ssize_t_to_short() -> short
{
    return ssize_t_val();
}

# 23
def ssize_t_to_int() -> int
{
    return ssize_t_val();
}

# 24
def ssize_t_to_long() -> long
{
    return ssize_t_val();
}

# 25
def ubyte_val() -> ubyte
{
    return 0x42;
}

# 26
def ushort_val() -> ushort
{
    return 0x4242;
}

# 27
def uint_val() -> uint
{
    return 0x42424242;
}

# 28
def ulong_val() -> ulong
{
    return 0x4242_4242_4242_4242;
}

# 29
def size_t_val() -> size_t
{
    return 0x42424242;
}

# 30
def ubyte_to_ushort() -> ushort
{
    return ubyte_val();
}

# 31
def ubyte_to_uint() -> uint
{
    return ubyte_val();
}

# 32
def ubyte_to_ulong() -> ulong
{
    return ubyte_val();
}

# 33
def ubyte_to_size_t() -> size_t
{
    return ubyte_val();
}

# 34
def ushort_to_ubyte() -> ubyte
{
    return ushort_val();
}

# 35
def ushort_to_uint() -> uint
{
    return ushort_val();
}

# 36
def ushort_to_ulong() -> ulong
{
    return ushort_val();
}

# 37
def ushort_to_size_t() -> size_t
{
    return ushort_val();
}

# 38
def uint_to_ubyte() -> ubyte
{
    return uint_val();
}

# 39
def uint_to_ushort() -> ushort
{
    return uint_val();
}

# 40
def uint_to_ulong() -> ulong
{
    return uint_val();
}

# 41
def uint_to_size_t() -> size_t
{
    return uint_val();
}

# 42
def ulong_to_ubyte() -> ubyte
{
    return ulong_val();
}

# 43
def ulong_to_ushort() -> ushort
{
    return ulong_val();
}

# 44
def ulong_to_uint() -> uint
{
    return ulong_val();
}

# 45
def ulong_to_size_t() -> size_t
{
    return ulong_val();
}

# 46
def size_t_to_ubyte() -> ubyte
{
    return size_t_val();
}

# 47
def size_t_to_ushort() -> ushort
{
    return size_t_val();
}

# 48
def size_t_to_int() -> int
{
    return size_t_val();
}

# 49
def size_t_to_ulong() -> ulong
{
    return size_t_val();
}

# 50
def main() -> int
{
    return int_val();
}
";
    struct Expected
    {
        string name;
        p_token_t token;
    }
    Expected[] expected = [
        Expected("byte_val", TOKEN_byte),
        Expected("short_val", TOKEN_short),
        Expected("int_val", TOKEN_int),
        Expected("long_val", TOKEN_long),
        Expected("ssize_t_val", TOKEN_ssize_t),
        Expected("byte_to_short", TOKEN_short),
        Expected("byte_to_int", TOKEN_int),
        Expected("byte_to_long", TOKEN_long),
        Expected("byte_to_ssize_t", TOKEN_ssize_t),
        Expected("short_to_byte", TOKEN_byte),
        Expected("short_to_int", TOKEN_int),
        Expected("short_to_long", TOKEN_long),
        Expected("short_to_ssize_t", TOKEN_ssize_t),
        Expected("int_to_byte", TOKEN_byte),
        Expected("int_to_short", TOKEN_short),
        Expected("int_to_long", TOKEN_long),
        Expected("int_to_ssize_t", TOKEN_ssize_t),
        Expected("long_to_byte", TOKEN_byte),
        Expected("long_to_short", TOKEN_short),
        Expected("long_to_int", TOKEN_int),
        Expected("long_to_ssize_t", TOKEN_ssize_t),
        Expected("ssize_t_to_byte", TOKEN_byte),
        Expected("ssize_t_to_short", TOKEN_short),
        Expected("ssize_t_to_int", TOKEN_int),
        Expected("ssize_t_to_long", TOKEN_long),
        Expected("ubyte_val", TOKEN_ubyte),
        Expected("ushort_val", TOKEN_ushort),
        Expected("uint_val", TOKEN_uint),
        Expected("ulong_val", TOKEN_ulong),
        Expected("size_t_val", TOKEN_size_t),
        Expected("ubyte_to_ushort", TOKEN_ushort),
        Expected("ubyte_to_uint", TOKEN_uint),
        Expected("ubyte_to_ulong", TOKEN_ulong),
        Expected("ubyte_to_size_t", TOKEN_size_t),
        Expected("ushort_to_ubyte", TOKEN_ubyte),
        Expected("ushort_to_uint", TOKEN_uint),
        Expected("ushort_to_ulong", TOKEN_ulong),
        Expected("ushort_to_size_t", TOKEN_size_t),
        Expected("uint_to_ubyte", TOKEN_ubyte),
        Expected("uint_to_ushort", TOKEN_ushort),
        Expected("uint_to_ulong", TOKEN_ulong),
        Expected("uint_to_size_t", TOKEN_size_t),
        Expected("ulong_to_ubyte", TOKEN_ubyte),
        Expected("ulong_to_ushort", TOKEN_ushort),
        Expected("ulong_to_uint", TOKEN_uint),
        Expected("ulong_to_size_t", TOKEN_size_t),
        Expected("size_t_to_ubyte", TOKEN_ubyte),
        Expected("size_t_to_ushort", TOKEN_ushort),
        Expected("size_t_to_int", TOKEN_int),
        Expected("size_t_to_ulong", TOKEN_ulong),
        Expected("main", TOKEN_int),
    ];
    p_context_t * context;
    context = p_context_new(input);
    size_t result = p_parse(context);
    assert_eq(P_SUCCESS, result);
    PModule * pmod = p_result(context);
    PModuleItems * pmis = pmod.pModuleItems;
    PFunctionDefinition *[] pfds;
    while (pmis !is null)
    {
        PModuleItem * pmi = pmis.pModuleItem;
        if (pmi is null)
        {
            stderr.writeln("pmi is null!!!?");
            assert(0);
        }
        PFunctionDefinition * pfd = pmi.pFunctionDefinition;
        if (pfd !is null)
        {
            pfds = [pfd] ~ pfds;
        }
        pmis = pmis.pModuleItems;
    }
    assert_eq(51, pfds.length);
    for (size_t i = 0; i < pfds.length; i++)
    {
        if ((expected[i].name != pfds[i].name.pvalue.s) ||
            (expected[i].token != pfds[i].returntype.pType.pTypeBase.pToken1.token))
        {
            stderr.writeln("Index ", i, ": expected ", expected[i].name, "/", expected[i].token, ", got ", pfds[i].name.pvalue.s, "/", pfds[i].returntype.pType.pTypeBase.pToken1.token);
        }
    }
}
