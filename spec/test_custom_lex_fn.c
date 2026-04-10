#include "testparser.h"
#include "testutils.h"
#include <string.h>

int main()
{
    char const * input = "cbacba";
    p_context_t * context = p_context_new((uint8_t const *)input, strlen(input));
    assert_eq(P_SUCCESS, p_parse(context));
    size_t result = p_result(context);
    assert_eq(0x932187932187, result);
    p_context_delete(context);

    return 0;
}
