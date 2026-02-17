#include "testparser.h"
#include <assert.h>
#include <stdio.h>
#include <string.h>

int main()
{
    char const * input = "    # comment 1\n#    comment 2\na\n";
    p_context_t * context;
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse(context) == P_SUCCESS);
    p_context_delete(context);

    return 0;
}
