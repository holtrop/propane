
#include <stdio.h>
#include <string.h>

#include <iostream>
#include <string>
#include <map>
#include <pcre.h>

#include "parse-input.h"

using namespace std;

enum Section{ none, tokens, rules };

bool parse_input(char * buff, int size)
{
    pcre * empty;
    pcre * comment;
    pcre * section_name;
    pcre * token;
    pcre * rule;
    struct { pcre ** re; const char * pattern; } exprs[] = {
        {&empty,        "^\\s*$"},
        {&comment,      "^\\s*#"},
        {&section_name, "^\\s*\\[([^\\]]+?)\\]\\s*$"},
        {&token,        "^\\s*"                     /* possible leading ws */
                        "([a-zA-Z_][a-zA-Z_0-9]*)"  /* token name */
                        "\\s+"                      /* required whitespace */
                        "((?:[^\\\\\\s]|\\\\.)+)"   /* token RE */
                        "(?:\\s+\\[([^\\]]+)\\])?"  /* optional token flags */
                        "\\s*$"},                   /* possible trailing ws */
        {&rule,         "^\\s*(\\S+)\\s*:=(.*)$"}
    };
    const int ovec_size = 3 * 10;
    int ovector[ovec_size];
    int lineno = 1;
    char * newline;
    char * input = buff;
    string sn;
    map<string, Section> sections;
    sections["none"] = none;
    sections["tokens"] = tokens;
    sections["rules"] = rules;
    Section section = none;
    string line;
    bool append_line = false;

    for (int i = 0; i < sizeof(exprs)/sizeof(exprs[0]); i++)
    {
        const char * errptr;
        int erroffset;
        *exprs[i].re = pcre_compile(exprs[i].pattern, 0,
                &errptr, &erroffset, NULL);
        if (*exprs[i].re == NULL)
        {
            cerr << "Error compiling regex '" << exprs[i].pattern <<
                "': " << errptr << " at position " << erroffset << endl;
        }
    }

    while ((newline = strstr(input, "\n")) != NULL)
    {
        int line_length = newline - input;
        if (newline[-1] == '\r')
        {
            line_length--;
        }
        if (append_line)
        {
            line += string(input, line_length);
        }
        else
        {
            line = string(input, line_length);
        }
        if (line.size() > 0 && line[line.size()-1] == '\\')
        {
            line[line.size()-1] = ' ';
            append_line = true;
        }
        else
        {
            append_line = false;
        }
        if ( append_line
          || (pcre_exec(empty, NULL, line.c_str(), line.size(),
                  0, 0, ovector, ovec_size) >= 0)
          || (pcre_exec(comment, NULL, line.c_str(), line.size(),
                  0, 0, ovector, ovec_size) >= 0)
           )
        {
            /* nothing */;
        }
        else if (pcre_exec(section_name, NULL, line.c_str(), line.size(),
                    0, 0, ovector, ovec_size) >= 0)
        {
            sn = string(input, ovector[2], ovector[3] - ovector[2]);
            if (sections.find(sn) != sections.end())
            {
                section = sections[sn];
            }
            else
            {
                cerr << "Unknown section name '" << sn << "'!" << endl;
                return false;
            }
        }
        else
        {
            switch (section)
            {
                case none:
                    cerr << "Unrecognized input on line " << lineno << endl;
                    return false;
                case tokens:
                    if (pcre_exec(token, NULL, line.c_str(), line.size(),
                                0, 0, ovector, ovec_size) >= 0)
                    {
                        string name(line, ovector[2], ovector[3] - ovector[2]);
                        string definition(line,
                                ovector[4], ovector[5] - ovector[4]);
                        string flags;
                        if (ovector[6] >= 0 && ovector[7] >= 0)
                        {
                            flags = string(line,
                                    ovector[6], ovector[7] - ovector[6]);
                        }
                        /* TODO: process token */
                    }
                    else
                    {
                        cerr << "Unrecognized input on line " << lineno << endl;
                        return false;
                    }
                    break;
                case rules:
                    if (pcre_exec(rule, NULL, line.c_str(), line.size(),
                                0, 0, ovector, ovec_size) >= 0)
                    {
                        string name(line, ovector[2], ovector[3] - ovector[2]);
                        string definition(line,
                                ovector[4], ovector[5] - ovector[4]);
                        /* TODO: process rule */
                    }
                    else
                    {
                        cerr << "Unrecognized input on line " << lineno << endl;
                        return false;
                    }
                    break;
            }
        }
        input = newline + 1;
        lineno++;
    }

    return true;
}
