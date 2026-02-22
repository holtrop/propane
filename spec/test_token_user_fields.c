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
    Start * start = p_result(context);

#ifndef __cplusplus
    free(context->comments);
#endif
    p_context_delete(context);
    p_tree_delete(start);

    return 0;
}
