
#include "unicode.h"
#include <string.h>

unistring & unistring::operator=(const char * ascii_str)
{
    chars.clear();
    const char * as_ptr = ascii_str;
    while (*as_ptr != '\0')
    {
        chars.push_back(*as_ptr);
    }
    return *this;
}

unistring & unistring::operator+=(const unichar_t c)
{
    chars.push_back(c);
    return *this;
}

bool unistring::operator==(const char * ascii_str)
{
    int len = chars.size();
    if (len != strlen(ascii_str))
        return false;
    for (int i = 0; i < len; i++)
    {
        if (chars[i] != ascii_str[i])
            return false;
    }
    return true;
}
