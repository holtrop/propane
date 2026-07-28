#include "testparser.h"
#include <cassert>
#include <cstring>
#include <string>

int main()
{
    char const * input =
        "# c1\n"
        "#  c2\n"
        "\n"
        "first\n"
        "\n   \n  \n"
        "  # s1\n"
        "   #   s2\n"
        "second\n";
    p_context_t * context;
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse(context) == P_SUCCESS);
    Start start = p_result(context);
    assert(start.pIDs().valid());
    assert(start.pIDs().id().valid());
    assert(start.pIDs().id().data()->comments == "# c1\n#  c2\n");
    assert(start.pIDs().pIDs().valid());
    assert(start.pIDs().pIDs().id().valid());
    assert(start.pIDs().pIDs().id().data()->comments == "# s1\n#   s2\n");

    p_context_delete(context);

    return 0;
}
