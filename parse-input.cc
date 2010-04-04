
#include <iostream>
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
    enum State { INITIAL, SECTION_NAME, RULES, RULE_NAME,
        RULE_EQUALS, RULE_RHS, TOKENS, TOKEN_NAME, TOKEN_EQUALS, TOKEN_RHS };
    State state = INITIAL;
    int lineno = 1;
    int colno = 1;
    bool error = false;
    char errstr[200];
    unistring build_str;
    struct { unistring name; unistring rhs; } rule;
    struct { unistring name; unistring rhs; } token;

    for (int i = 0, sz = ucs->size(); i < sz; i++)
    {
        unichar_t c = (*ucs)[i];
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
                        else if (build_str == "tokens")
                        {
                            state = TOKENS;
                        }
                        else
                        {
                            SET_ERROR("Unknown section name");
                        }
                        break;
                    case '\n':
                        SET_ERROR("Unterminated section header");
                        break;
                    default:
                        build_str += c;
                        break;
                }
                break;
            case RULES:
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
                    build_str = "";
                    build_str += c;
                    state = RULE_NAME;
                }
                break;
            case RULE_NAME:
                if (c == ':')
                {
                    rule.name = build_str;
                    build_str = "";
                    state = RULE_EQUALS;
                }
                else
                {
                    build_str += c;
                }
                break;
            case RULE_EQUALS:
                if (c == '=')
                {
                    state = RULE_RHS;
                }
                else
                {
                    SET_ERROR("Expected '='");
                }
                break;
            case RULE_RHS:
                if (c == '\n')
                {
                    rule.rhs = build_str;
                    state = RULES;
                }
                else
                {
                    build_str += c;
                }
                break;
            case TOKENS:
                if (c == '[')
                {
                    state = SECTION_NAME;
                    build_str = "";
                }
                else
                {
                    build_str = "";
                    build_str += c;
                    state = TOKEN_NAME;
                }
                break;
            case TOKEN_NAME:
                if (c == ':')
                {
                    state = TOKEN_EQUALS;
                }
                else
                {
                    build_str += c;
                }
                break;
            case TOKEN_EQUALS:
                if (c == '=')
                {
                    token.name = build_str;
                    build_str = "";
                    state = TOKEN_RHS;
                }
                else
                {
                    SET_ERROR("Expected '='");
                }
                break;
            case TOKEN_RHS:
                if (c == '\n')
                {
                    token.rhs = build_str;
                    state = RULES;
                }
                else
                {
                    build_str += c;
                }
                break;
        }

        /* update line and column position information */
        if (c == '\n')
        {
            lineno++;
            colno = 1;
        }
        else
        {
            colno++;
        }

        if (error)
        {
            cerr << errstr << endl;
            break;
        }
    }
}
