#include "testparser.h"
#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

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
    IDs ids = p_Start_pIDs(start);
    assert(p_node_valid(ids));
    Token id0 = p_IDs_id(ids);
    assert(p_node_valid(id0));
    assert(p_node_data(id0)->comments);
    assert(strcmp(p_node_data(id0)->comments, "# c1\n#  c2\n") == 0);
    IDs ids2 = p_IDs_pIDs(ids);
    assert(p_node_valid(ids2));
    Token id1 = p_IDs_id(ids2);
    assert(p_node_valid(id1));
    assert(p_node_data(id1)->comments);
    assert(strcmp(p_node_data(id1)->comments, "# s1\n#   s2\n") == 0);

    free(context->comments);
    p_context_delete(context);

    return 0;
}
