
#include <stdio.h>
#include <string.h>
#include <pcre.h>

#include <iostream>
#include <fstream>
#include <string>
#include <map>

#include "Parser.h"
#include "TokenDefinition.h"
#include "RuleDefinition.h"

using namespace std;

Parser::Parser()
    : m_classname("Parser")
{
}

void Parser::write(const string & fname)
{
    ofstream ofs(fname.c_str());
    ofs << "Content goes here" << endl;
    ofs.close();
}

bool Parser::parseInputFile(char * buff, int size)
{
    typedef pcre * pcre_ptr;
    enum { none, tokens, rules };
    pcre_ptr empty, comment, section_name, token, rule;
    struct { pcre_ptr * re; const char * pattern; } exprs[] = {
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
    map<string, int> sections;
    sections["none"] = none;
    sections["tokens"] = tokens;
    sections["rules"] = rules;
    int section = none;
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
                        refptr<TokenDefinition> td = new TokenDefinition();
                        if (td->create(name, definition, flags))
                        {
                            addTokenDefinition(td);
                        }
                        else
                        {
                            cerr << "Error in token definition ending on line "
                                << lineno << endl;
                            return false;
                        }
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
                        refptr<RuleDefinition> rd = new RuleDefinition();
                        if (rd->create(name, definition))
                        {
                            addRuleDefinition(rd);
                        }
                        else
                        {
                            cerr << "Error in rule definition ending on line "
                                << lineno << endl;
                            return false;
                        }
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

    pcre_free(empty);
    pcre_free(comment);
    pcre_free(section_name);
    pcre_free(token);
    pcre_free(rule);
    return true;
}
