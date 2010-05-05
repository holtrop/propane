
#include <iostream>
#include <vector>

#include I_HEADER_NAME

using namespace std;

#ifdef I_NAMESPACE
namespace I_NAMESPACE {
#endif

static void read_istream(istream & i, vector<char> & buff, int & size)
{
    size = 0;
    int bytes_read;
    char read_buff[1000];
    while (!i.eof())
    {
        i.read(&read_buff[0], sizeof(read_buff));
        bytes_read = i.gcount();
        size += bytes_read;
        for (int j = 0; j < bytes_read; j++)
            buff.push_back(read_buff[j]);
    }
}

bool I_CLASSNAME::parse(istream & i)
{
    struct { char * name; char * definition; } tokens[] = {
        I_TOKENLIST
    };

    vector<char> buff;
    int size;
    read_istream(i, buff, size);

    if (size <= 0)
        return false;
}

#ifdef I_NAMESPACE
};
#endif
