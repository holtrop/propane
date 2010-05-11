
#ifndef IMBECILE_PARSER_HEADER
#define IMBECILE_PARSER_HEADER

#include <iostream>

#ifdef I_NAMESPACE
namespace I_NAMESPACE {
#endif

class I_CLASSNAME
{
    public:
        I_CLASSNAME();
        bool parse(std::istream & in);
        const char * getError() { return m_errstr; }

    protected:
        const char * m_errstr;
};

#ifdef I_NAMESPACE
};
#endif

#endif /* IMBECILE_PARSER_HEADER */
