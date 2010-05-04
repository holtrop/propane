
#ifndef TOKENDEFINITION_H
#define TOKENDEFINITION_H

#include <string>

class TokenDefinition
{
    public:
        bool create(const std::string & name,
                const std::string & definition, const std::string & flags);
        std::string getCString() const;

    protected:
        std::string m_name;
        std::string m_definition;
};

#endif
