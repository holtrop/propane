
#include <getopt.h>

#include <iostream>
#include <fstream>

#include "refptr/refptr.h"
#include "Parser.h"

using namespace std;

int main(int argc, char * argv[])
{
    int longind = 1;
    int opt;
    string output_fname;

    static struct option longopts[] = {
        /* name, has_arg, flag, val */
        { "outfile", required_argument, NULL, 'o' },
        { NULL, 0, NULL, 0 }
    };

    while ((opt = getopt_long(argc, argv, "", longopts, &longind)) != -1)
    {
        switch (opt)
        {
            case 'o':   /* outfile */
                output_fname = optarg;
                break;
        }
    }

    string input_fname = argv[optind];
    ifstream ifs;
    ifs.open(input_fname.c_str(), ios::binary);
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
    ifs.close();

    Parser p;

    p.parseInputFile(buff, size);

    if (output_fname == "")
    {
        size_t len = input_fname.length();
        if (len > 2 && input_fname.substr(len - 2) == ".I")
        {
            output_fname = input_fname.substr(0, len - 2) + ".cc";
        }
        else
        {
            output_fname = input_fname + ".cc";
        }
    }
    p.write(output_fname);

    delete[] buff;
    return 0;
}
