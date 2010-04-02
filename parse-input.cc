
#include <iostream>
#include <string>
#include <stdio.h>
#include <ctype.h>  /* isspace() */
#include "parse-input.h"
using namespace std;

#define SET_ERROR(err, args...) \
    do { \
        error = true; \
        sprintf(errstr, err " at line %d, column %d", ##args, lineno, colno); \
    } while(0)

void parse_input(refptr< vector<unichar_t> > ucs)
{
    enum State { INITIAL, SECTION_NAME, RULES };
    State state = INITIAL;
    int lineno = 1;
    int colno = 1;
    bool error = false;
    char errstr[200];
    unistring build_str;

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
                    state = SECTION_NAME;
                    build_str = "";
                }
                else if (isspace(c))
                {
                }
                else
                {
                    SET_ERROR("Unexpected character 0x%x (%c) in input file",
                            c, c);
                }
                break;
            case SECTION_NAME:
                switch (c)
                {
                    case ']':
                        if (build_str == "rules")
                        {
                            state = RULES;
                        }
                        else
                        {
                            SET_ERROR("Unknown section name");
                        }
                        break;
                    case '\n':
                        SET_ERROR("Unterminated section header");
                        break;
                }
                break;
        }
    }
}
