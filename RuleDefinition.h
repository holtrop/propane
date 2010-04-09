
#ifndef RULEDEFINITION_H
#define RULEDEFINITION_H

#include <string>

class RuleDefinition
{
    public:
        bool create(const std::string & name, const std::string & definition);

    protected:
        std::string m_name;
};

#endif
