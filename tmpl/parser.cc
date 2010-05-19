
#include <string.h>                 /* memcpy() */
#include <pcre.h>

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
    struct {
        const char * name;
        const char * definition;
        bool process;
        pcre * re;
        pcre_extra * re_extra;
    } tokens[] = {
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
        const char * errptr;
        int erroffset;
        tokens[i].re = pcre_compile(tokens[i].definition, 0,
                &errptr, &erroffset, NULL);
        if (tokens[i].re == NULL)
        {
            cerr << "Error compiling token '" << tokens[i].name
                << "' regular expression at position " << erroffset
                << ": " << errptr << endl;
            m_errstr = "Error in token regular expression";
            return false;
        }
        tokens[i].re_extra = pcre_study(tokens[i].re, 0, &errptr);
    }

    int buff_pos = 0;
    const int ovector_num_matches = 16;
    const int ovector_size = 3 * (ovector_num_matches + 1);
    int ovector[ovector_size];
    while (buff_pos < buff_size)
    {
        int longest_match_length = 0;
        int longest_match_index = -1;
        int longest_match_ovector[ovector_size];
        for (int i = 0; i < sizeof(tokens)/sizeof(tokens[0]); i++)
        {
            int rc = pcre_exec(tokens[i].re, tokens[i].re_extra,
                    &buff[0], buff_size, buff_pos,
                    PCRE_ANCHORED | PCRE_NOTEMPTY,
                    ovector, ovector_size);
            if (rc > 0)
            {
                /* this pattern matched some of the input */
                int len = ovector[1] - ovector[0];
                if (len > longest_match_length)
                {
                    longest_match_length = len;
                    longest_match_index = i;
                    memcpy(longest_match_ovector, ovector, sizeof(ovector));
                }
            }
        }
        if (longest_match_index >= 0)
        {
            cout << "Matched a " << tokens[longest_match_index].name << endl;
            buff_pos += longest_match_length;
        }
        else
        {
            /* no pattern matched the input at the current position */
            return false;
        }
    }
}

refptr<Node> Node::operator[](int index)
{
    return (0 <= index && index < m_indexed_children.size())
        ? m_indexed_children[index]
        : NULL;
}

refptr<Node> Node::operator[](const std::string & index)
{
    return (m_named_children.find(index) != m_named_children.end())
        ? m_named_children[index]
        : NULL;
}

void Token::process()
{
}

Matches::Matches(pcre * re, const char * data, int * ovector, int ovec_size)
    : m_re(re), m_data(data), m_ovector(ovector), m_ovec_size(ovec_size)
{
}

std::string Matches::operator[](int index)
{
    if (0 <= index && index < (m_ovec_size / 3))
    {
        int idx = 2 * index;
        if (m_ovector[idx] >= 0 && m_ovector[idx + 1] >= 0)
        {
            return string(m_data, m_ovector[idx],
                    m_ovector[idx + 1] - m_ovector[idx]);
        }
    }
    return "";
}

std::string Matches::operator[](const std::string & index)
{
    int idx = pcre_get_stringnumber(m_re, index.c_str());
    if (idx > 0 && idx < (m_ovec_size / 3))
    {
        if (m_ovector[idx] >= 0 && m_ovector[idx + 1] >= 0)
        {
            return string(m_data, m_ovector[idx],
                    m_ovector[idx + 1] - m_ovector[idx]);
        }
    }
    return "";
}

#ifdef I_NAMESPACE
};
#endif
