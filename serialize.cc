
#include "serialize.h"
#include <string.h>
#include <iconv.h>
#include <stdio.h>
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
    refptr< vector<unichar_t> > ucs = new vector<unichar_t>();

    cout << "encoding: " << encoding << endl;
    iconv_t cd = iconv_open(encoding, "UTF-32");
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
        cout << "inbuf_ptr: " << inbuf_ptr << endl;
        chars_converted = iconv(cd, &inbuf_ptr, &inbytesleft,
                &outbuf_ptr, &outbytesleft);
        if (chars_converted == (size_t) -1)
        {
            perror("iconv() error");
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

