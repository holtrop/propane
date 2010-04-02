
#ifndef UNICODE_H
#define UNICODE_H

#include <stdint.h>
#include <vector>

typedef uint32_t unichar_t;

class unistring
{
    public:
        unistring & operator=(const char * ascii_str);
        unistring & operator+=(const unichar_t c);
        bool operator==(const char * ascii_str);

    protected:
        std::vector<unichar_t> chars;
};

#endif
