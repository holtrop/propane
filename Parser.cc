
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
    for (int i = 0; i < m_tokens.size(); i++)
    {
        if (i > 0)
            *tokenlist += "    ";
        *tokenlist += "{ \"" + m_tokens[i]->getName() + "\", \""
            + m_tokens[i]->getCString() + "\", "
            + (m_tokens[i]->getProcessFlag() ? "true" : "false") + " }";
        if (i < m_tokens.size() - 1)
            *tokenlist += ", \\\n";
    }
    return tokenlist;
}

bool Parser::parseInputFile(char * buff, int size)
{
    typedef pcre * pcre_ptr;
    enum { none, tokens, rules };
    pcre_ptr empty, comment, section_name, token, rule, code_end_sec;
    struct { pcre_ptr * re; const char * pattern; } exprs[] = {
        {&empty,        "^\\s*$"},
        {&comment,      "^\\s*#"},
        {&section_name, "^\\s*\\[([^\\]]+?)\\]\\s*$"},
        {&token,        "^\\s*"                     /* possible leading ws */
                        "([a-zA-Z_][a-zA-Z_0-9]*)"  /* 1: token name */
                        "\\s+"                      /* required whitespace */
                        "((?:[^\\\\\\s]|\\\\.)+)"   /* 2: token RE */
                        "(?:\\s+\\[([^\\]]+)\\])?"  /* 3: token flags */
                        "\\s*({{)?"                 /* 4: code section opener */
                        "\\s*$"},                   /* possible trailing ws */
        {&rule,         "^\\s*(\\S+)\\s*:=(.*)$"},
        {&code_end_sec, "^\\s*}}\\s*$"}
    };
    const int ovec_size = 3 * 10;
    int ovector[ovec_size];
    int lineno = 0;
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
    bool gathering_code = false;
    string code;

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

    while ((newline = strstr(input, "\n")) != NULL)
    {
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

        if (gathering_code)
        {
            if (pcre_exec(code_end_sec, NULL, line.c_str(), line.size(),
                        0, 0, ovector, ovec_size) >= 0)
            {
                gathering_code = false;
                code += "}\n";
                /* TODO: do something with gathered code */
            }
            else
            {
                code += line;
            }
            continue;
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
            sn = string(line, ovector[2], ovector[3] - ovector[2]);
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
                    if (ovector[8] >= 0 && ovector[9] >= 0
                            && ovector[9] - ovector[8] > 0)
                    {
                        td->setProcessFlag(true);
                        code = ""; /* FIXME: function definition */
                        gathering_code = true;
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

    for (int i = 0; i < sizeof(exprs)/sizeof(exprs[0]); i++)
    {
        pcre_free(*exprs[i].re);
    }

    return true;
}
