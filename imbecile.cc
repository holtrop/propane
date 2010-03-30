
#include <iostream>
#include <fstream>
#include <getopt.h>
#include <iconv.h>
#include "refptr/refptr.h"
#include "serialize.h"
#include "unicode.h"
using namespace std;

int main(int argc, char * argv[])
{
    int longind = 1;
    int opt;
    const char * encoding = "UTF-8";

    static struct option longopts[] = {
        /* name, has_arg, flag, val */
        { "encoding", required_argument, NULL, 'e' },
        { NULL, 0, NULL, 0 }
    };

    while ((opt = getopt_long(argc, argv, "", longopts, &longind)) != -1)
    {
        switch (opt)
        {
            case 'e':   /* encoding */
                encoding = optarg;
                break;
        }
    }

    ifstream ifs;
    ifs.open(argv[optind], ios::binary);
    if (!ifs.is_open())
    {
        cerr << "Error opening input file: '" << argv[optind] << "'";
        return 2;
    }
    refptr< vector<unichar_t> > ucs_str = deserialize(encoding, ifs);
    if (ucs_str.isNull())
    {
        cerr << "Error deserializing input file." << endl;
        return 1;
    }

    cout << "Size: " << ucs_str->size() << endl;
    for (int i = 0; i < ucs_str->size(); i++)
    {
        cout << (*ucs_str)[i] << ": '" << (char) (*ucs_str)[i] << "'" << endl;
    }

    return 0;
}
