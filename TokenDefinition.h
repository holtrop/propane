
#ifndef TOKENDEFINITION_H
#define TOKENDEFINITION_H

#include <pcre.h>

#include <string>

class TokenDefinition
{
    public:
        TokenDefinition();
        ~TokenDefinition();
        bool create(const std::string & name,
                const std::string & definition, const std::string & flags);

    protected:
        pcre * m_re;
};

#endif
