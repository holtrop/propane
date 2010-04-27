
#ifndef PARSER_H
#define PARSER_H

#include <vector>
#include <string>

#include "refptr/refptr.h"
#include "TokenDefinition.h"
#include "RuleDefinition.h"

class Parser
{
    public:
        Parser();
        void addTokenDefinition(refptr<TokenDefinition> td)
        {
            m_tokens.push_back(td);
        }
        void addRuleDefinition(refptr<RuleDefinition> rd)
        {
            m_rules.push_back(rd);
        }
        void write(const std::string & fname);
        bool parseInputFile(char * buff, int size);

    protected:
        std::vector< refptr< TokenDefinition > > m_tokens;
        std::vector< refptr< RuleDefinition > > m_rules;
};

#endif
