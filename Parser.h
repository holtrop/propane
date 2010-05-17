
#ifndef PARSER_H
#define PARSER_H

#include <vector>
#include <string>

#include "refptr.h"
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
        bool write(const std::string & fname);
        bool parseInputFile(char * buff, int size);

        void setClassName(const std::string & cn) { m_classname = cn; }
        std::string getClassName() { return m_classname; }

        void setNamespace(const std::string & ns) { m_namespace = ns; }
        std::string getNamespace() { return m_namespace; }

        void setExtension(const std::string & e) { m_extension = e; }
        std::string getExtension() { return m_extension; }

    protected:
        std::vector< refptr< TokenDefinition > > m_tokens;
        std::vector< refptr< RuleDefinition > > m_rules;
        std::string m_classname;
        std::string m_namespace;
        std::string m_extension;
};

#endif
