#pragma once

void assert_eq_size_t_i(size_t expected, size_t actual, char const * file, size_t line);

#define assert_eq(expected, actual) \
    assert_eq_size_t_i(expected, actual, __FILE__, __LINE__)

typedef struct
{
    char * cs;
} str_t;

void str_init(str_t * str, char const * cs);
void str_append(str_t * str, char const * cs);
void str_free(str_t * str);
static inline char * str_cstr(str_t * str)
{
    return str->cs;
}
