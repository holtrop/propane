
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
    string outfile;
    string classname = "Parser";
    string namespace_name = "";

    static struct option longopts[] = {
        /* name, has_arg, flag, val */
        { "classname", required_argument, NULL, 'c' },
        { "namespace", required_argument, NULL, 'n' },
        { "outfile", required_argument, NULL, 'o' },
        { NULL, 0, NULL, 0 }
    };

    while ((opt = getopt_long(argc, argv, "", longopts, &longind)) != -1)
    {
        switch (opt)
        {
            case 'c':   /* classname */
                classname = optarg;
                break;
            case 'n':   /* namespace */
                namespace_name = optarg;
                break;
            case 'o':   /* outfile */
                outfile = optarg;
                break;
        }
    }

    if (optind >= argc)
    {
        cerr << "Usage: imbecile [options] <input-file>" << endl;
        return 2;
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

    Parser p;
    p.setClassName(classname);
    p.setNamespace(namespace_name);
    p.parseInputFile(buff, size);
    p.write(outfile);

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
