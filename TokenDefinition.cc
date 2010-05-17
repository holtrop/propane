
#include <pcre.h>

#include <iostream>
#include <string>
#include <vector>

#include "TokenDefinition.h"
#include "refptr.h"

using namespace std;

#define WHITESPACE " \n\r\t\v"

static string trim(string s)
{
    size_t lastpos = s.find_last_not_of(WHITESPACE);
    if (lastpos == string::npos)
        return "";
    s.erase(lastpos + 1);
    s.erase(0, s.find_first_not_of(WHITESPACE));
    return s;
}

static refptr< vector<string> > split(const string & delim, string str)
{
    refptr< vector<string> > ret = new vector<string>();
    size_t pos;
    while ( (pos = str.find(delim)) != string::npos )
    {
        string t = str.substr(0, pos);
        ret->push_back(t);
        str.erase(0, pos + 1);
    }
    if (str != "")
        ret->push_back(str);
    return ret;
}

static string c_escape(const string & orig)
{
    string result;
    for (string::const_iterator it = orig.begin(); it != orig.end(); it++)
    {
        if (*it == '\\' || *it == '"')
            result += '\\';
        result += *it;
    }
    return result;
}


TokenDefinition::TokenDefinition()
    : m_ignored(false)
{
}

bool TokenDefinition::create(const string & name,
        const string & definition, const string & flags)
{
    const char * errptr;
    int erroffset;
    pcre * re = pcre_compile(definition.c_str(), 0, &errptr, &erroffset, NULL);
    if (re == NULL)
    {
        cerr << "Error compiling regular expression '" << definition
            << "' at position " << erroffset << ": " << errptr << endl;
        return false;
    }
    m_name = name;
    m_definition = definition;
    pcre_free(re);

    refptr< vector< string > > parts = split(",", flags);
    for (int i = 0, sz = parts->size(); i < sz; i++)
    {
        (*parts)[i] = trim((*parts)[i]);
        string & s = (*parts)[i];
        if (s == "i")
        {
            m_ignored = true;
        }
        else
        {
            cerr << "Unknown token flag \"" << s << "\"" << endl;
            return false;
        }
    }

    return true;
}

string TokenDefinition::getCString() const
{
    return c_escape(m_definition);
}
