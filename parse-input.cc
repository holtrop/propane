
#include <stdio.h>
#include <string.h>

#include <iostream>
#include <string>
#include <map>
#include <pcrecpp.h>

#include "parse-input.h"

using namespace std;
using namespace pcrecpp;

enum Section{ none, tokens, rules };

bool parse_input(char * buff, int size)
{
    RE empty("\\s*");
    RE comment("\\s*#.*");
    RE section_name("\\s*\\[([^\\]]+?)\\]\\s*");
    RE token("\\s*"                             /* possible leading ws */
             "([a-zA-Z_][a-zA-Z_0-9]*)"         /* token name */
             "\\s+"                             /* required whitespace */
             "((?:[^\\\\\\s]|\\\\.)+)"          /* token regular expression */
             "(?:\\s+\\[([^\\]]+)\\])?"         /* optional token flags */
             "\\s*");                           /* possible trailing ws */
    RE rule("\\s*(\\S+)\\s*:=(.*)");

    Section section = none;

    int lineno = 1;
    char * newline;
    char * input = buff;
    string sn;
    map<string, Section> sections;
    sections["none"] = none;
    sections["tokens"] = tokens;
    sections["rules"] = rules;
    while ((newline = strstr(input, "\n")) != NULL)
    {
        int line_length = newline - input;
        if (newline[-1] == '\r')
        {
            line_length--;
        }
        string line(input, line_length);
        if (empty.FullMatch(line))
            continue;
        if (comment.FullMatch(line))
            continue;
        if (section_name.FullMatch(line, &sn))
        {
            if (sections.find(sn) != sections.end())
            {
                section = sections[sn];
            }
            else
            {
                cerr << "Unknown section name '" << sn << "'!" << endl;
                return false;
            }
            continue;
        }
        switch (section)
        {
            case none:
                break;
            case tokens:
                {
                    string name, definition, flags;
                    if (token.FullMatch(line, &name, &definition, &flags))
                    {
                        /* TODO: process token */
                    }
                }
                break;
            case rules:
                {
                    string name, definition;
                    if (rule.FullMatch(line, &name, &definition))
                    {
                        /* TODO: process rule */
                    }
                }
                break;
        }
        input = newline + 1;
        lineno++;
    }
}
