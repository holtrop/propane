
#include <iostream>
#include <vector>

#include I_HEADER_NAME

using namespace std;

#ifdef I_NAMESPACE
namespace I_NAMESPACE {
#endif

I_CLASSNAME::I_CLASSNAME()
    : m_errstr(NULL)
{
}

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
    struct { char * name; char * definition; pcre * re; } tokens[] = {
        I_TOKENLIST
    };

    if (sizeof(tokens)/sizeof(tokens[0]) == 0)
    {
        m_errstr = "No tokens defined";
        return false;
    }

    vector<char> buff;
    int buff_size;
    read_istream(i, buff, buff_size);

    if (buff_size <= 0)
    {
        m_errstr = "0-length input string";
        return false;
    }

    /* append trailing NUL byte for pcre functions */
    buff.push_back('\0');

    /* compile all token regular expressions */
    for (int i = 0; i < sizeof(tokens)/sizeof(tokens[0]); i++)
    {
        char * errptr;
        int erroffset;
        tokens[i].re = pcre_compile(tokens[i].definition, PCRE_DOTALL,
                &errptr, &erroffset, NULL);
        if (tokens[i].re == NULL)
        {
            cerr << "Error compiling token '" << tokens[i].name
                << "' regular expression at position " << erroffset
                << ": " << errptr << endl;
            m_errstr = "Error in token regular expression";
            return false;
        }
    }

    int buff_pos = 0;
    while (buff_pos < buff_size)
    {
    }
}

#ifdef I_NAMESPACE
};
#endif
