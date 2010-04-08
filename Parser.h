
#ifndef PARSER_H
#define PARSER_H

#include <vector>

#include "refptr/refptr.h"
#include "TokenDefinition.h"

class Parser
{
    public:
        Parser();
        void addTokenDefinition(refptr<TokenDefinition> td)
        {
            m_tokens.push_back(td);
        }

    protected:
        std::vector< refptr< TokenDefinition > > m_tokens;
};

#endif
