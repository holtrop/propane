#include "json_types.h"
#include <string.h>
#include <stdlib.h>
#include "testutils.h"

JSONValue * JSONValue_new(size_t id)
{
    JSONValue * jv = calloc(1, sizeof(JSONValue));
    jv->id = id;
    return jv;
}

JSONValue * JSONObject_new(void)
{
    JSONValue * jv = JSONValue_new(JSON_OBJECT);
    jv->object.size = 0u;
    return jv;
}

void JSONObject_append(JSONValue * object, char const * name, JSONValue * value)
{
    size_t const size = object->object.size;
    for (size_t i = 0u; i < size; i++)
    {
        if (strcmp(name, object->object.entries[i].name) == 0)
        {
            object->object.entries[i].value = value;
            return;
        }
    }
    size_t const new_size = size + 1;
    void * new_entries = malloc(sizeof(object->object.entries[0]) * new_size);
    if (size > 0)
    {
        memcpy(new_entries, object->object.entries, size * sizeof(object->object.entries[0]));
        free(object->object.entries);
    }
    object->object.entries = new_entries;
    object->object.entries[size].name = name;
    object->object.entries[size].value = value;
    object->object.size = new_size;
}

JSONValue * JSONArray_new(void)
{
    JSONValue * jv = JSONValue_new(JSON_ARRAY);
    jv->array.size = 0u;
    return jv;
}

void JSONArray_append(JSONValue * array, JSONValue * value)
{
    size_t const size = array->array.size;
    size_t const new_size = size + 1;
    JSONValue ** new_entries = malloc(sizeof(JSONValue *) * new_size);
    if (array->array.size > 0)
    {
        memcpy(new_entries, array->array.entries, sizeof(JSONValue *) * size);
        free(array->array.entries);
    }
    array->array.entries = new_entries;
    array->array.entries[size] = value;
    array->array.size = new_size;
}
