
#include <iostream>

#include I_HEADER_NAME

using namespace std;

#ifdef I_NAMESPACE
namespace I_NAMESPACE {
#endif

bool I_CLASSNAME::parse(istream & i)
{
    struct { char * name; char * definition; } tokens[] = {
        I_TOKENLIST
    };
}

#ifdef I_NAMESPACE
};
#endif
