
#include <stdio.h>
#include <string.h>
#include <pcre.h>
#include <ctype.h>                  /* toupper() */

#include <iostream>
#include <fstream>
#include <string>
#include <map>

#include "Parser.h"
#include "TokenDefinition.h"
#include "RuleDefinition.h"
#include "tmpl.h"

using namespace std;

Parser::Parser()
    : m_classname("Parser"), m_namespace(""), m_extension("cc")
{
}

static void writeDefine(ostream & out,
        const string & defname, const string & definition)
{
    out << "#ifdef " << defname << endl;
    out << "#undef " << defname << endl;
    out << "#endif" << endl;
    out << "#define " << defname << " " << definition << endl;
}

bool Parser::write(const string & fname)
{
    if (m_tokens.size() < 1 || m_rules.size() < 1)
        return false;

    string header_fname = fname + ".h";
    string body_fname = fname + "." + m_extension;

    ofstream header(header_fname.c_str());
    ofstream body(body_fname.c_str());

    /* write the header */
    if (m_namespace != "")
    {
        writeDefine(header, "I_NAMESPACE", m_namespace);
    }
    writeDefine(header, "I_CLASSNAME", m_classname);
    refptr<string> tokenlist = buildTokenList();
    writeDefine(header, "I_TOKENLIST", *tokenlist);
    header << endl;
    header.write((const char *) tmpl_parser_h, tmpl_parser_h_len);

    /* write the body */
    writeDefine(body, "I_HEADER_NAME", string("\"") + header_fname + "\"");
    body << endl;
    body.write((const char *) tmpl_parser_cc, tmpl_parser_cc_len);

    header.close();
    body.close();
    return true;
}

refptr<string> Parser::buildTokenList()
{
    refptr<string> tokenlist = new string();
    for (list<TokenDefinitionRef>::const_iterator t = m_tokens.begin();
            t != m_tokens.end();
            t++)
    {
        if (t != m_tokens.begin())
            *tokenlist += "    ";
        *tokenlist += "{ \"" + (*t)->getName() + "\", \""
            + (*t)->getCString() + "\", "
            + ((*t)->getProcessFlag() ? "true" : "false") + " }";
        if (({typeof(t) tmp = t; ++tmp;}) != m_tokens.end())
            *tokenlist += ", \\\n";
    }
    return tokenlist;
}

bool Parser::parseInputFile(char * buff, int size)
{
    typedef pcre * pcre_ptr;
    enum { none, tokens, rules };
    pcre_ptr empty, comment, section_name, token, rule,
             data_begin, data_end, code_begin, code_end;
    struct { pcre_ptr * re; const char * pattern; } exprs[] = {
        {&empty,        "^\\s*$"},
        {&comment,      "^\\s*#"},
        {&section_name, "^\\s*\\[([^\\]]+?)\\]\\s*$"},
        {&token,        "^\\s*"                     /* possible leading ws */
                        "([a-zA-Z_][a-zA-Z_0-9]*)"  /* 1: token name */
                        "\\s+"                      /* required whitespace */
                        "((?:[^\\\\\\s]|\\\\.)+)"}, /* 2: token RE */
        {&rule,         "^\\s*(\\S+)\\s*:=(.*)$"},
        {&data_begin,   "^\\s*\\${"},
        {&data_end,     "\\$}"},
        {&code_begin,   "^\\s*%{"},
        {&code_end,     "%}"}
    };
    const int ovec_size = 3 * 10;
    int ovector[ovec_size];
    int lineno = 0;
    char * newline;
    char * input = buff;
    string current_section_name;
    map<string, int> sections;
    sections["none"] = none;
    sections["tokens"] = tokens;
    sections["rules"] = rules;
    int section = none;
    string line;
    bool append_line = false;
    bool gathering_data = false;
    bool gathering_code = false;
    string gather;
    bool continue_line = false;
    TokenDefinitionRef current_token;

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
            return false;
        }
    }

    for (;;)
    {
        if (continue_line)
        {
            continue_line = false;
        }
        else
        {
            if ((newline = strstr(input, "\n")) == NULL)
                break;
            int line_length = newline - input;
            if (line_length >= 1 && newline[-1] == '\r')
            {
                newline[-1] = '\n';
                line_length--;
            }
            lineno++;

            if (append_line)
            {
                line += string(input, line_length);
            }
            else
            {
                line = string(input, line_length);
            }
            input = newline + 1;        /* set up for next loop iteration */
        }

        if ( (pcre_exec(empty, NULL, line.c_str(), line.size(),
                  0, 0, ovector, ovec_size) >= 0)
          || (pcre_exec(comment, NULL, line.c_str(), line.size(),
                  0, 0, ovector, ovec_size) >= 0)
           )
        {
            /* skip empty or comment lines */;
            continue;
        }

        if (! (gathering_code || gathering_data) )
        {
            if (line.size() > 0 && line[line.size()-1] == '\\')
            {
                line[line.size()-1] = ' ';
                append_line = true;
                continue;
            }
            else
            {
                append_line = false;
            }

            if (pcre_exec(section_name, NULL, line.c_str(), line.size(),
                        0, 0, ovector, ovec_size) >= 0)
            {
                current_section_name
                    = string(line, ovector[2], ovector[3] - ovector[2]);
                if (sections.find(current_section_name) != sections.end())
                {
                    section = sections[current_section_name];
                }
                else
                {
                    cerr << "Unknown section name '" << current_section_name
                        << "'!" << endl;
                    return false;
                }
                continue;
            }
        }

        switch (section)
        {
            case none:
                cerr << "Unrecognized input on line " << lineno << endl;
                return false;
            case tokens:
                if      (gathering_data)
                {
                    if (pcre_exec(data_end, NULL, line.c_str(), line.size(),
                                0, 0, ovector, ovec_size) >= 0)
                    {
                        gather += string(line, 0, ovector[0]) + "\n";
                        gathering_data = false;
                        line = string(line, ovector[1]);
                        continue_line = true;
                        if (current_token.isNull())
                        {
                            cerr << "Data section with no corresponding "
                                "token definition on line " << lineno << endl;
                            return false;
                        }
                        else
                        {
                            current_token->addData(gather);
                        }
                    }
                    else
                    {
                        gather += line + "\n";
                    }
                    continue;
                }
                else if (gathering_code)
                {
                    if (pcre_exec(code_end, NULL, line.c_str(), line.size(),
                                0, 0, ovector, ovec_size) >= 0)
                    {
                        gather += string(line, 0, ovector[0]) + "\n";
                        gathering_code = false;
                        line = string(line, ovector[1]);
                        continue_line = true;
                        if (current_token.isNull())
                        {
                            cerr << "Code section with no corresponding "
                                "token definition on line " << lineno << endl;
                            return false;
                        }
                        else
                        {
                            current_token->addCode(gather);
                        }
                    }
                    else
                    {
                        gather += line + "\n";
                    }
                    continue;
                }
                else if (pcre_exec(data_begin, NULL, line.c_str(), line.size(),
                            0, 0, ovector, ovec_size) >= 0)
                {
                    gathering_data = true;
                    gather = "";
                    line = string(line, ovector[1]);
                    continue_line = true;
                    continue;
                }
                else if (pcre_exec(code_begin, NULL, line.c_str(), line.size(),
                            0, 0, ovector, ovec_size) >= 0)
                {
                    gathering_code = true;
                    gather = "";
                    line = string(line, ovector[1]);
                    continue_line = true;
                    continue;
                }
                else if (pcre_exec(token, NULL, line.c_str(), line.size(),
                            0, 0, ovector, ovec_size) >= 0)
                {
                    string name(line, ovector[2], ovector[3] - ovector[2]);
                    string definition(line,
                            ovector[4], ovector[5] - ovector[4]);
                    current_token = new TokenDefinition();
                    if (current_token->create(name, definition))
                    {
                        addTokenDefinition(current_token);
                    }
                    else
                    {
                        cerr << "Error in token definition ending on line "
                            << lineno << endl;
                        return false;
                    }
                    line = string(line, ovector[1]);
                    continue_line = true;
                    continue;
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

    for (int i = 0; i < sizeof(exprs)/sizeof(exprs[0]); i++)
    {
        pcre_free(*exprs[i].re);
    }

    return true;
}
