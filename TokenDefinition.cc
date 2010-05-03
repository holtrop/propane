
#include <pcre.h>

#include <iostream>
#include <string>

#include "TokenDefinition.h"

using namespace std;

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
