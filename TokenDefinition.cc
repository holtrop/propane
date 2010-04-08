
#include <pcre.h>

#include <iostream>
#include <string>

#include "TokenDefinition.h"

using namespace std;

TokenDefinition::TokenDefinition()
    : m_re(NULL)
{
}

TokenDefinition::~TokenDefinition()
{
    if (m_re != NULL)
    {
        pcre_free(m_re);
    }
}

bool TokenDefinition::create(const string & name,
        const string & definition, const string & flags)
{
    const char * errptr;
    int erroffset;
    m_re = pcre_compile(definition.c_str(), 0, &errptr, &erroffset, NULL);
    if (m_re == NULL)
    {
        cerr << "Error compiling regular expression '" << definition
            << "' at position " << erroffset << ": " << errptr << endl;
        return false;
    }
    return true;
}
