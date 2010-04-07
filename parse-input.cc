
#include <stdio.h>
#include <ctype.h>  /* isspace() */
#include "parse-input.h"
using namespace std;

#define SET_ERROR(err, args...) \
    do { \
        error = true; \
        sprintf(errstr, err " at line %d, column %d", ##args, lineno, colno); \
    } while(0)

void parse_input(char * buff, int size)
{
}
