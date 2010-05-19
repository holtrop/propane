
#ifndef TOKENDEFINITION_H
#define TOKENDEFINITION_H

#include <string>
#include "refptr.h"

class TokenDefinition
{
    public:
        TokenDefinition();
        bool create(const std::string & name,
                const std::string & definition);
        std::string getCString() const;
        std::string getName() const { return m_name; }
        bool getProcessFlag() const { return m_process; }
        void setProcessFlag(bool p) { m_process = p; }
        void addData(const std::string & d) { m_data += d; }
        std::string getData() const { return m_data; }
        void addCode(const std::string & c) { m_code += c; m_process = true; }
        std::string getCode() const { return m_code; }

    protected:
        std::string m_name;
        std::string m_definition;
        bool m_process;
        std::string m_data;
        std::string m_code;
};

typedef refptr<TokenDefinition> TokenDefinitionRef;

#endif
