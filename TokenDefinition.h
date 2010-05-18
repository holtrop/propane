
#ifndef TOKENDEFINITION_H
#define TOKENDEFINITION_H

#include <string>

class TokenDefinition
{
    public:
        TokenDefinition();
        bool create(const std::string & name,
                const std::string & definition, const std::string & flags);
        std::string getCString() const;
        std::string getName() const { return m_name; }
        bool getProcessFlag() const { return m_process; }
        void setProcessFlag(bool p) { m_process = p; }

    protected:
        std::string m_name;
        std::string m_definition;
        bool m_process;
};

#endif
