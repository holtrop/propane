#include "testparser.h"
#include "json_types.h"
#include <string.h>
#include <assert.h>

int main()
{
    char const * input = "";
    p_context_t * context;
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse(context) == P_SUCCESS);
    p_context_delete(context);

    input = "{}";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse(context) == P_SUCCESS);
    assert(p_result(context)->id == JSON_OBJECT);
    p_context_delete(context);

    input = "[]";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse(context) == P_SUCCESS);
    assert(p_result(context)->id == JSON_ARRAY);
    p_context_delete(context);

    input = "-45.6";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse(context) == P_SUCCESS);
    assert(p_result(context)->id == JSON_NUMBER);
    assert(p_result(context)->number == -45.6);
    p_context_delete(context);

    input = "2E-2";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse(context) == P_SUCCESS);
    assert(p_result(context)->id == JSON_NUMBER);
    assert(p_result(context)->number == 0.02);
    p_context_delete(context);

    input = "{\"hi\":true}";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse(context) == P_SUCCESS);
    JSONValue * o = p_result(context);
    assert(o->id == JSON_OBJECT);
    assert_eq(1, o->object.size);
    assert(strcmp(o->object.entries[0].name, "hi") == 0);
    assert(o->object.entries[0].value->id == JSON_TRUE);
    p_context_delete(context);

    input = "{\"ff\": false, \"nn\": null}";
    context = p_context_new((uint8_t const *)input, strlen(input));
    assert(p_parse(context) == P_SUCCESS);
    o = p_result(context);
    assert(o->id == JSON_OBJECT);
    assert_eq(2, o->object.size);
    assert(strcmp(o->object.entries[0].name, "ff") == 0);
    assert(o->object.entries[0].value->id == JSON_FALSE);
    assert(strcmp(o->object.entries[1].name, "nn") == 0);
    assert(o->object.entries[1].value->id == JSON_NULL);
    p_context_delete(context);

    return 0;
}
