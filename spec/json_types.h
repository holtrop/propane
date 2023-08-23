#pragma once

#include <stddef.h>
#include "testutils.h"

#define JSON_OBJECT 0u
#define JSON_ARRAY 1u
#define JSON_NUMBER 2u
#define JSON_STRING 3u
#define JSON_TRUE 4u
#define JSON_FALSE 5u
#define JSON_NULL 6u

typedef struct JSONValue_s
{
    size_t id;
    union
    {
        struct
        {
            size_t size;
            struct
            {
                char const * name;
                struct JSONValue_s * value;
            } * entries;
        } object;
        struct
        {
            size_t size;
            struct JSONValue_s ** entries;
        } array;
        double number;
        str_t string;
    };
} JSONValue;

JSONValue * JSONValue_new(size_t id);

JSONValue * JSONObject_new(void);

void JSONObject_append(JSONValue * object, char const * name, JSONValue * value);

JSONValue * JSONArray_new(void);

void JSONArray_append(JSONValue * array, JSONValue * value);
