#include "testparser.h"
#include <assert.h>
#include <string.h>

int main()
{
    char const * input = "\a\b\t\n\v\f\rt";
    p_context_t context;
    p_context_init(&context, (uint8_t const *)input, strlen(input));
    assert(p_parse(&context) == P_SUCCESS);

    return 0;
}
