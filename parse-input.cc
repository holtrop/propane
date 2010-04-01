
#include <iostream>
#include <stdio.h>
#include <ctype.h>  /* isspace() */
#include "parse-input.h"
using namespace std;

#define SET_ERROR(err, args...) \
    sprintf(errstr, err " at line %d, column %d", ##args, lineno, colno)

void parse_input(refptr< vector<unichar_t> > ucs)
{
    enum State { INITIAL, LB, SECTION_NAME, RB };
    State state = INITIAL;
    int lineno = 1;
    int colno = 1;
    bool error = false;
    char errstr[200];

    for (int i = 0, sz = ucs->size(); i < sz; i++)
    {
        unichar_t c = (*ucs)[i];
        if (c == '\n')
        {
            lineno++;
            colno = 1;
        }
        else
        {
            colno++;
        }
        switch (state)
        {
            case INITIAL:
                if (c == '[')
                {
                    state = LB;
                }
                else if (isspace(c))
                {
                }
                else
                {
                    error = true;
                    SET_ERROR("Unexpected character 0x%x (%c) in input file",
                            c, c);
                }
                break;
        }
    }
}
