
#include <pcre.h>

#include <iostream>
#include <string>

#include "TokenDefinition.h"

using namespace std;

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
    return true;
}

string TokenDefinition::getCString() const
{
    return c_escape(m_definition);
}
