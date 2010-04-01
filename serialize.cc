
#include "serialize.h"
#include <string.h>
#include <iconv.h>
#include <stdio.h>
#include <errno.h>
#include <endian.h>
using namespace std;

refptr< vector<unichar_t> > deserialize(const char * encoding, istream & in)
{
    const int buf_size = 200;
    int num_read;
    char * inbuf = new char[buf_size];
    char * inbuf_ptr = (char *) &inbuf[0];
    unichar_t * outbuf = new unichar_t[buf_size];
    char * outbuf_ptr;
    size_t chars_converted, inbytesleft = 0, outbytesleft;
    const char * to_encoding
#if __BYTE_ORDER == __LITTLE_ENDIAN
        = "UCS-4LE";
#else
        = "UCS-4BE";
#endif
    refptr< vector<unichar_t> > ucs = new vector<unichar_t>();

    iconv_t cd = iconv_open(/* to */ to_encoding, /* from */ encoding);
    if (cd == (iconv_t) -1)
    {
        cerr << "iconv_open() error" << endl;
        return NULL;
    }

    outbuf_ptr = (char *) &outbuf[0];
    outbytesleft = buf_size * sizeof(outbuf[0]);
    iconv(cd, NULL, NULL, &outbuf_ptr, &outbytesleft);

    for (;;)
    {
        in.read(inbuf_ptr, buf_size * sizeof(inbuf[0]) - inbytesleft);
        num_read = in.gcount();
        if (num_read <= 0)
            break;
        inbytesleft += num_read;
        outbuf_ptr = (char *) &outbuf[0];
        outbytesleft = buf_size * sizeof(outbuf[0]);
        chars_converted = iconv(cd, &inbuf_ptr, &inbytesleft,
                &outbuf_ptr, &outbytesleft);
        if (chars_converted == (size_t) -1)
        {
            perror("iconv()");
        }
        if (inbytesleft > 0)
        {
            memmove(&inbuf[0], inbuf_ptr, inbytesleft);
        }
        inbuf_ptr = ((char *) &inbuf[0]) + inbytesleft;
        for (int i = 0;
             i < (((buf_size * sizeof(outbuf[0])) - outbytesleft)
                 / sizeof(outbuf[0]));
             i++)
        {
            ucs->push_back(outbuf[i]);
        }
        if (in.eof())
            break;
    }

    delete[] inbuf;
    delete[] outbuf;
    iconv_close(cd);
    return ucs;
}
