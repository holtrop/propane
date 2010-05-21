
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

#define DEBUG

Parser::Parser()
    : m_classname("Parser"), m_namespace(""), m_extension("cc"),
    m_token_data(new string()), m_token_code(new string()),
    m_defines(new string())
{
}

void Parser::makeDefine(const string & defname, const string & definition)
{
    *m_defines += string("#define ") + defname + " " + definition + "\n";
}

bool Parser::write(const string & fname)
{
    if (m_tokens.size() < 1 || m_rules.size() < 1)
        return false;

    string header_fname = fname + ".h";
    string body_fname = fname + "." + m_extension;

    ofstream header(header_fname.c_str());
    ofstream body(body_fname.c_str());

    /* process data */
    refptr<string> token_classes = new string();
    refptr<string> token_classes_code = new string();
    int i = 0;
    for (list<TokenDefinitionRef>::const_iterator it = m_tokens.begin();
            it != m_tokens.end();
            it++)
    {
        char buff[20];
        sprintf(buff, "%d", i++);
        makeDefine((*it)->getIdentifier(), buff);
        *token_classes += (*it)->getClassDefinition();
        *token_classes_code += (*it)->getProcessMethod();
    }
    if (m_namespace != "")
    {
        makeDefine("I_NAMESPACE", m_namespace);
    }
    makeDefine("I_CLASSNAME", m_classname);

    /* set up replacements */
    setReplacement("token_list", buildTokenList());
    setReplacement("buildToken", buildBuildToken());
    setReplacement("header_name",
            new string(string("\"") + header_fname + "\""));
    setReplacement("token_code", m_token_code);
    setReplacement("token_data", m_token_data);
    setReplacement("defines", m_defines);
    setReplacement("token_classes", token_classes);
    setReplacement("token_classes_code", token_classes_code);

    /* write the header */
    writeTmpl(header, (char *) tmpl_parser_h, tmpl_parser_h_len);

    /* write the body */
    writeTmpl(body, (char *) tmpl_parser_cc, tmpl_parser_cc_len);

    header.close();
    body.close();

    return true;
}

bool Parser::writeTmpl(std::ostream & out, char * dat, int len)
{
    char * newline;
    char * data = dat;
    const char * errptr;
    int erroffset;
    data[len-1] = '\n';
    const int ovec_size = 6;
    int ovector[ovec_size];
    pcre * replace = pcre_compile("{%(\\w+)%}", 0, &errptr, &erroffset, NULL);
    while (data < (dat + len) && (newline = strstr(data, "\n")) != NULL)
    {
        if (pcre_exec(replace, NULL, data, newline - data,
                    0, 0, ovector, ovec_size) >= 0)
        {
            if (ovector[0] > 0)
            {
                out.write(data, ovector[0]);
            }
            out << *getReplacement(string(data, ovector[2],
                        ovector[3] - ovector[2]));
            if (ovector[1] < newline - data)
            {
                out.write(data + ovector[1], newline - data - ovector[1]);
            }
        }
        else
        {
            out.write(data, newline - data);
        }
        out << '\n';
        data = newline + 1;
    }
}

refptr<std::string> Parser::getReplacement(const std::string & name)
{
    if (m_replacements.find(name) != m_replacements.end())
    {
        return m_replacements[name];
    }
#ifdef DEBUG
    cerr << "No replacement found for \"" << name << "\"" << endl;
#endif
    return new string("");
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
            *tokenlist += ",\n";
    }
    return tokenlist;
}

refptr<string> Parser::buildBuildToken()
{
    refptr<string> buildToken = new string();
    for (list<TokenDefinitionRef>::const_iterator t = m_tokens.begin();
            t != m_tokens.end();
            t++)
    {
        *buildToken += "case " + (*t)->getIdentifier() + ":\n";
        *buildToken += "    token = new " + (*t)->getClassName() + "();\n";
        *buildToken += "    break;\n";
    }
    return buildToken;
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
                            *m_token_data += gather;
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
                            *m_token_code += gather;
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
