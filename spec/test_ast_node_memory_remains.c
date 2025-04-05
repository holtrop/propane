#include "testparser.h"
#include <assert.h>
#include <string.h>
#include <stdlib.h>
#include "testutils.h"

int main(int argc, char * argv[])
{
    const char * input =
        "# 0\n"
        "def byte_val() -> byte\n"
        "{\n"
        "    return 0x42;\n"
        "}\n"
        "\n"
        "# 1\n"
        "def short_val() -> short\n"
        "{\n"
        "    return 0x4242;\n"
        "}\n"
        "\n"
        "# 2\n"
        "def int_val() -> int\n"
        "{\n"
        "    return 0x42424242;\n"
        "}\n"
        "\n"
        "# 3\n"
        "def long_val() -> long\n"
        "{\n"
        "    return 0x4242_4242_4242_4242;\n"
        "}\n"
        "\n"
        "# 4\n"
        "def ssize_t_val() -> ssize_t\n"
        "{\n"
        "    return 0x42424242;\n"
        "}\n"
        "\n"
        "# 5\n"
        "def byte_to_short() -> short\n"
        "{\n"
        "    return byte_val();\n"
        "}\n"
        "\n"
        "# 6\n"
        "def byte_to_int() -> int\n"
        "{\n"
        "    return byte_val();\n"
        "}\n"
        "\n"
        "# 7\n"
        "def byte_to_long() -> long\n"
        "{\n"
        "    return byte_val();\n"
        "}\n"
        "\n"
        "# 8\n"
        "def byte_to_ssize_t() -> ssize_t\n"
        "{\n"
        "    return byte_val();\n"
        "}\n"
        "\n"
        "# 9\n"
        "def short_to_byte() -> byte\n"
        "{\n"
        "    return short_val();\n"
        "}\n"
        "\n"
        "# 10\n"
        "def short_to_int() -> int\n"
        "{\n"
        "    return short_val();\n"
        "}\n"
        "\n"
        "# 11\n"
        "def short_to_long() -> long\n"
        "{\n"
        "    return short_val();\n"
        "}\n"
        "\n"
        "# 12\n"
        "def short_to_ssize_t() -> ssize_t\n"
        "{\n"
        "    return short_val();\n"
        "}\n"
        "\n"
        "# 13\n"
        "def int_to_byte() -> byte\n"
        "{\n"
        "    return int_val();\n"
        "}\n"
        "\n"
        "# 14\n"
        "def int_to_short() -> short\n"
        "{\n"
        "    return int_val();\n"
        "}\n"
        "\n"
        "# 15\n"
        "def int_to_long() -> long\n"
        "{\n"
        "    return int_val();\n"
        "}\n"
        "\n"
        "# 16\n"
        "def int_to_ssize_t() -> ssize_t\n"
        "{\n"
        "    return int_val();\n"
        "}\n"
        "\n"
        "# 17\n"
        "def long_to_byte() -> byte\n"
        "{\n"
        "    return long_val();\n"
        "}\n"
        "\n"
        "# 18\n"
        "def long_to_short() -> short\n"
        "{\n"
        "    return long_val();\n"
        "}\n"
        "\n"
        "# 19\n"
        "def long_to_int() -> int\n"
        "{\n"
        "    return long_val();\n"
        "}\n"
        "\n"
        "# 20\n"
        "def long_to_ssize_t() -> ssize_t\n"
        "{\n"
        "    return long_val();\n"
        "}\n"
        "\n"
        "# 21\n"
        "def ssize_t_to_byte() -> byte\n"
        "{\n"
        "    return ssize_t_val();\n"
        "}\n"
        "\n"
        "# 22\n"
        "def ssize_t_to_short() -> short\n"
        "{\n"
        "    return ssize_t_val();\n"
        "}\n"
        "\n"
        "# 23\n"
        "def ssize_t_to_int() -> int\n"
        "{\n"
        "    return ssize_t_val();\n"
        "}\n"
        "\n"
        "# 24\n"
        "def ssize_t_to_long() -> long\n"
        "{\n"
        "    return ssize_t_val();\n"
        "}\n"
        "\n"
        "# 25\n"
        "def ubyte_val() -> ubyte\n"
        "{\n"
        "    return 0x42;\n"
        "}\n"
        "\n"
        "# 26\n"
        "def ushort_val() -> ushort\n"
        "{\n"
        "    return 0x4242;\n"
        "}\n"
        "\n"
        "# 27\n"
        "def uint_val() -> uint\n"
        "{\n"
        "    return 0x42424242;\n"
        "}\n"
        "\n"
        "# 28\n"
        "def ulong_val() -> ulong\n"
        "{\n"
        "    return 0x4242_4242_4242_4242;\n"
        "}\n"
        "\n"
        "# 29\n"
        "def size_t_val() -> size_t\n"
        "{\n"
        "    return 0x42424242;\n"
        "}\n"
        "\n"
        "# 30\n"
        "def ubyte_to_ushort() -> ushort\n"
        "{\n"
        "    return ubyte_val();\n"
        "}\n"
        "\n"
        "# 31\n"
        "def ubyte_to_uint() -> uint\n"
        "{\n"
        "    return ubyte_val();\n"
        "}\n"
        "\n"
        "# 32\n"
        "def ubyte_to_ulong() -> ulong\n"
        "{\n"
        "    return ubyte_val();\n"
        "}\n"
        "\n"
        "# 33\n"
        "def ubyte_to_size_t() -> size_t\n"
        "{\n"
        "    return ubyte_val();\n"
        "}\n"
        "\n"
        "# 34\n"
        "def ushort_to_ubyte() -> ubyte\n"
        "{\n"
        "    return ushort_val();\n"
        "}\n"
        "\n"
        "# 35\n"
        "def ushort_to_uint() -> uint\n"
        "{\n"
        "    return ushort_val();\n"
        "}\n"
        "\n"
        "# 36\n"
        "def ushort_to_ulong() -> ulong\n"
        "{\n"
        "    return ushort_val();\n"
        "}\n"
        "\n"
        "# 37\n"
        "def ushort_to_size_t() -> size_t\n"
        "{\n"
        "    return ushort_val();\n"
        "}\n"
        "\n"
        "# 38\n"
        "def uint_to_ubyte() -> ubyte\n"
        "{\n"
        "    return uint_val();\n"
        "}\n"
        "\n"
        "# 39\n"
        "def uint_to_ushort() -> ushort\n"
        "{\n"
        "    return uint_val();\n"
        "}\n"
        "\n"
        "# 40\n"
        "def uint_to_ulong() -> ulong\n"
        "{\n"
        "    return uint_val();\n"
        "}\n"
        "\n"
        "# 41\n"
        "def uint_to_size_t() -> size_t\n"
        "{\n"
        "    return uint_val();\n"
        "}\n"
        "\n"
        "# 42\n"
        "def ulong_to_ubyte() -> ubyte\n"
        "{\n"
        "    return ulong_val();\n"
        "}\n"
        "\n"
        "# 43\n"
        "def ulong_to_ushort() -> ushort\n"
        "{\n"
        "    return ulong_val();\n"
        "}\n"
        "\n"
        "# 44\n"
        "def ulong_to_uint() -> uint\n"
        "{\n"
        "    return ulong_val();\n"
        "}\n"
        "\n"
        "# 45\n"
        "def ulong_to_size_t() -> size_t\n"
        "{\n"
        "    return ulong_val();\n"
        "}\n"
        "\n"
        "# 46\n"
        "def size_t_to_ubyte() -> ubyte\n"
        "{\n"
        "    return size_t_val();\n"
        "}\n"
        "\n"
        "# 47\n"
        "def size_t_to_ushort() -> ushort\n"
        "{\n"
        "    return size_t_val();\n"
        "}\n"
        "\n"
        "# 48\n"
        "def size_t_to_int() -> int\n"
        "{\n"
        "    return size_t_val();\n"
        "}\n"
        "\n"
        "# 49\n"
        "def size_t_to_ulong() -> ulong\n"
        "{\n"
        "    return size_t_val();\n"
        "}\n"
        "\n"
        "# 50\n"
        "def main() -> int\n"
        "{\n"
        "    return int_val();\n"
        "}\n";
    struct
    {
        const char * name;
        p_token_t token;
    } expected[] = {
        {"byte_val", TOKEN_byte},
        {"short_val", TOKEN_short},
        {"int_val", TOKEN_int},
        {"long_val", TOKEN_long},
        {"ssize_t_val", TOKEN_ssize_t},
        {"byte_to_short", TOKEN_short},
        {"byte_to_int", TOKEN_int},
        {"byte_to_long", TOKEN_long},
        {"byte_to_ssize_t", TOKEN_ssize_t},
        {"short_to_byte", TOKEN_byte},
        {"short_to_int", TOKEN_int},
        {"short_to_long", TOKEN_long},
        {"short_to_ssize_t", TOKEN_ssize_t},
        {"int_to_byte", TOKEN_byte},
        {"int_to_short", TOKEN_short},
        {"int_to_long", TOKEN_long},
        {"int_to_ssize_t", TOKEN_ssize_t},
        {"long_to_byte", TOKEN_byte},
        {"long_to_short", TOKEN_short},
        {"long_to_int", TOKEN_int},
        {"long_to_ssize_t", TOKEN_ssize_t},
        {"ssize_t_to_byte", TOKEN_byte},
        {"ssize_t_to_short", TOKEN_short},
        {"ssize_t_to_int", TOKEN_int},
        {"ssize_t_to_long", TOKEN_long},
        {"ubyte_val", TOKEN_ubyte},
        {"ushort_val", TOKEN_ushort},
        {"uint_val", TOKEN_uint},
        {"ulong_val", TOKEN_ulong},
        {"size_t_val", TOKEN_size_t},
        {"ubyte_to_ushort", TOKEN_ushort},
        {"ubyte_to_uint", TOKEN_uint},
        {"ubyte_to_ulong", TOKEN_ulong},
        {"ubyte_to_size_t", TOKEN_size_t},
        {"ushort_to_ubyte", TOKEN_ubyte},
        {"ushort_to_uint", TOKEN_uint},
        {"ushort_to_ulong", TOKEN_ulong},
        {"ushort_to_size_t", TOKEN_size_t},
        {"uint_to_ubyte", TOKEN_ubyte},
        {"uint_to_ushort", TOKEN_ushort},
        {"uint_to_ulong", TOKEN_ulong},
        {"uint_to_size_t", TOKEN_size_t},
        {"ulong_to_ubyte", TOKEN_ubyte},
        {"ulong_to_ushort", TOKEN_ushort},
        {"ulong_to_uint", TOKEN_uint},
        {"ulong_to_size_t", TOKEN_size_t},
        {"size_t_to_ubyte", TOKEN_ubyte},
        {"size_t_to_ushort", TOKEN_ushort},
        {"size_t_to_int", TOKEN_int},
        {"size_t_to_ulong", TOKEN_ulong},
        {"main", TOKEN_int},
    };
    p_context_t context;
    p_context_init(&context, (const uint8_t *)input, strlen(input));
    size_t result = p_parse(&context);
    assert_eq(P_SUCCESS, result);
    PModule * pmod = p_result(&context);
    PModuleItems * pmis = pmod->pModuleItems;
    PFunctionDefinition ** pfds;
    size_t n_pfds = 0u;
    while (pmis != NULL)
    {
        PModuleItem * pmi = pmis->pModuleItem;
        if (pmi->pFunctionDefinition != NULL)
        {
            n_pfds++;
        }
        pmis = pmis->pModuleItems;
    }
    pfds = malloc(n_pfds * sizeof(PModuleItems *));
    pmis = pmod->pModuleItems;
    size_t pfd_i = n_pfds;
    while (pmis != NULL)
    {
        PModuleItem * pmi = pmis->pModuleItem;
        PFunctionDefinition * pfd = pmi->pFunctionDefinition;
        if (pfd != NULL)
        {
            pfd_i--;
            assert(pfd_i < n_pfds);
            pfds[pfd_i] = pfd;
        }
        pmis = pmis->pModuleItems;
    }
    assert_eq(51, n_pfds);
    for (size_t i = 0; i < n_pfds; i++)
    {
        if (strncmp(expected[i].name, (const char *)pfds[i]->name->pvalue.s, strlen(expected[i].name)) != 0 ||
            (expected[i].token != pfds[i]->returntype->pType->pTypeBase->pToken1->token))
        {
            fprintf(stderr, "Index %lu: expected %s/%u, got %u\n", i, expected[i].name, expected[i].token, pfds[i]->returntype->pType->pTypeBase->pToken1->token);
        }
    }

    return 0;
}
