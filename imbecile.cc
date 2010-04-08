
#include <iostream>
#include <fstream>
#include <getopt.h>
#include <iconv.h>
#include "refptr/refptr.h"
#include "parse-input.h"
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
    ifs.seekg(0, ios_base::end);
    int size = ifs.tellg();
    ifs.seekg(0, ios_base::beg);
    char * buff = new char[size];
    ifs.read(buff, size);

    Parser p;

    parse_input(buff, size, p);

    ifs.close();
    delete[] buff;
    return 0;
}
