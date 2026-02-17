#include "testparsermyp1.h"
#include "testparsermyp2.h"
#include <assert.h>
#include <string.h>

int main()
{
    char const * input1 = "a\n1";
    myp1_context_t * context1;
    context1 = myp1_context_new((uint8_t const *)input1, strlen(input1));
    assert(myp1_parse(context1) == MYP1_SUCCESS);
    myp1_context_delete(context1);

    char const * input2 = "bcb";
    myp2_context_t * context2;
    context2 = myp2_context_new((uint8_t const *)input2, strlen(input2));
    assert(myp2_parse(context2) == MYP2_SUCCESS);
    myp2_context_delete(context2);

    return 0;
}
