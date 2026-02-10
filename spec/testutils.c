#include <stdio.h>
#include <assert.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include "testutils.h"

void assert_eq_size_t_i(size_t expected, size_t actual, char const * file, size_t line)
{
    if (expected != actual)
    {
        fprintf(stderr, "%s:%lu: expected %lu, got %lu\n", file, line, expected, actual);
        assert(false);
    }
}

void assert_ne_size_t_i(size_t expected, size_t actual, char const * file, size_t line)
{
    if (expected == actual)
    {
        fprintf(stderr, "%s:%lu: expected not %lu, got %lu\n", file, line, expected, actual);
        assert(false);
    }
}

void assert_not_null_i(void * ptr, char const * file, size_t line)
{
    if (ptr == NULL)
    {
        fprintf(stderr, "%s:%lu: expected not NULL\n", file, line);
        assert(false);
    }
}

void str_init(str_t * str, char const * cs)
{
    size_t length = strlen(cs);
    str->cs = (char *)malloc(length + 1u);
    strcpy(str->cs, cs);
}

void str_append(str_t * str, char const * cs)
{
    size_t length = strlen(str->cs);
    size_t length2 = strlen(cs);
    char * new_cs = (char *)malloc(length + length2 + 1u);
    memcpy(new_cs, str->cs, length);
    strcpy(&new_cs[length], cs);
    free(str->cs);
    str->cs = new_cs;
}

void str_free(str_t * str)
{
    free(str->cs);
}
