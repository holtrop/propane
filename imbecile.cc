
#include <getopt.h>

#include <iostream>
#include <fstream>

#include "refptr/refptr.h"
#include "Parser.h"

using namespace std;

string buildOutputFilename(string & input_fname);

int main(int argc, char * argv[])
{
    int longind = 1;
    int opt;
    Parser p;
    string outfile;

    static struct option longopts[] = {
        /* name, has_arg, flag, val */
        { "classname", required_argument, NULL, 'c' },
        { "extension", required_argument, NULL, 'e' },
        { "namespace", required_argument, NULL, 'n' },
        { "outfile", required_argument, NULL, 'o' },
        { NULL, 0, NULL, 0 }
    };

    while ((opt = getopt_long(argc, argv, "", longopts, &longind)) != -1)
    {
        switch (opt)
        {
            case 'c':   /* classname */
                p.setClassName(optarg);
                break;
            case 'e':   /* extension */
                p.setExtension(optarg);
                break;
            case 'n':   /* namespace */
                p.setNamespace(optarg);
                break;
            case 'o':   /* outfile */
                outfile = optarg;
                break;
        }
    }

    if (optind >= argc)
    {
        cerr << "Usage: imbecile [options] <input-file>" << endl;
        return 1;
    }

    string input_fname = argv[optind];
    ifstream ifs;
    ifs.open(input_fname.c_str(), ios::binary);
    if (!ifs.is_open())
    {
        cerr << "Error opening input file: '" << input_fname << "'";
        return 2;
    }
    ifs.seekg(0, ios_base::end);
    int size = ifs.tellg();
    ifs.seekg(0, ios_base::beg);
    char * buff = new char[size];
    ifs.read(buff, size);
    ifs.close();

    if (outfile == "")
        outfile = buildOutputFilename(input_fname);

    if (!p.parseInputFile(buff, size))
    {
        cerr << "Error parsing " << input_fname << endl;
        return 3;
    }
    if (!p.write(outfile))
    {
        cerr << "Error processing " << input_fname << endl;
        return 4;
    }

    delete[] buff;
    return 0;
}

string buildOutputFilename(string & input_fname)
{
    string outfile;
    size_t len = input_fname.length();
    if (len > 2 && input_fname.substr(len - 2) == ".I")
    {
        outfile = input_fname.substr(0, len - 2);
    }
    else
    {
        outfile = input_fname;
    }
    return outfile;
}
