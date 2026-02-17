#include "testparser.h"
#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int main()
{
    char const * input = "aaa\n\n\na\n    # comment 1\na  a    aa\n\naa\n#    comment 2\na\n";
    p_context_t * context;
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse(context) == P_SUCCESS);

    fprintf(stderr, "comments: %s", context->comments);
    fprintf(stderr, "acount: %u\n", context->acount);
    free(context->comments);
    p_context_delete(context);

    return 0;
}
