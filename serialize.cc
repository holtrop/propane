
#include "serialize.h"
#include <string.h>
using namespace std;

refptr< vector<unichar_t> > deserialize(const char * encoding, istream & in)
{
    const int buf_size = 200;
    int num_read;
    char inbuf[buf_size];
    char * inbuf_ptr = (char *) &inbuf[0];
    unichar_t outbuf[buf_size];
    char * outbuf_ptr;
    size_t bytes_converted, inbytes = 0, outbytes;
    refptr< vector<unichar_t> > ucs = new vector<unichar_t>();

    iconv_t cd = iconv_open(encoding, "UTF-32");
    if (cd == (iconv_t) -1)
    {
        cerr << "iconv_open() error" << endl;
        return NULL;
    }

    for (;;)
    {
        in.read(inbuf_ptr, sizeof(inbuf) - inbytes);
        num_read = in.gcount();
        if (num_read <= 0)
            break;
        outbuf_ptr = (char *) &outbuf[0];
        outbytes = sizeof(outbuf);
        bytes_converted = iconv(cd, &inbuf_ptr, &inbytes,
                &outbuf_ptr, &outbytes);
        if (inbytes > 0)
        {
            memmove(&inbuf[0], inbuf_ptr, inbytes);
        }
        inbuf_ptr = ((char *) &inbuf[0]) + inbytes;
        for (int i = 0; i < (bytes_converted / sizeof(outbuf[0])); i++)
        {
            ucs->push_back(outbuf[i]);
        }
        if (bytes_converted & 0x3)
            cerr << "Warning: bytes_converted = " << bytes_converted << endl;
        if (in.eof())
            break;
    }

    iconv_close(cd);
    return ucs;
}

