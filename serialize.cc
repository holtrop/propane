
#include "serialize.h"
#include <string.h>
#include <iconv.h>
#include <stdio.h>
#include <errno.h>
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
    const char * to_encoding;
    refptr< vector<unichar_t> > ucs = new vector<unichar_t>();

    {
        uint32_t endianness_test = 1u;
        uint8_t * p = (uint8_t *) &endianness_test;
        to_encoding = (*p == 1) ? "UCS-4LE" : "UCS-4BE";
    }

    iconv_t cd = iconv_open(/* to */ to_encoding, /* from */ encoding);
    if (cd == (iconv_t) -1)
    {
        cerr << "iconv_open() error" << endl;
        return NULL;
    }

    outbuf_ptr = (char *) &outbuf[0];
    outbytesleft = buf_size * sizeof(outbuf[0]);
    iconv(cd, NULL, NULL, &outbuf_ptr, &outbytesleft);
    cout << "initial outbytesleft: " << outbytesleft << endl;

    for (;;)
    {
        in.read(inbuf_ptr, buf_size * sizeof(inbuf[0]) - inbytesleft);
        num_read = in.gcount();
        cout << "num_read: " << num_read << endl;
        if (num_read <= 0)
            break;
        inbytesleft += num_read;
        outbuf_ptr = (char *) &outbuf[0];
        outbytesleft = buf_size * sizeof(outbuf[0]);
        cout << "before inbytesleft: " << inbytesleft << ", outbytesleft: " << outbytesleft << endl;
//        cout << "inbuf_ptr: " << inbuf_ptr << endl;
        chars_converted = iconv(cd, &inbuf_ptr, &inbytesleft,
                &outbuf_ptr, &outbytesleft);
        if (chars_converted == (size_t) -1)
        {
            int err = errno;
            perror("iconv() error");
            switch (err)
            {
                case EINVAL:
                    cerr << "EINVAL" << endl;
                    break;
                case EILSEQ:
                    cerr << "EILSEQ" << endl;
                    printf("inbuf: %p, inbuf_ptr: %p\n", inbuf, inbuf_ptr);
                    for (int i = 0; i < 6; i++)
                        printf("%02x ", inbuf_ptr[i]);
                    cout << endl;
                    break;
                case E2BIG:
                    cerr << "E2BIG" << endl;
                    break;
            }
        }
        cout << "chars_converted: " << chars_converted << endl;
        cout << "after inbytesleft: " << inbytesleft << ", outbytesleft: " << outbytesleft << endl;
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

