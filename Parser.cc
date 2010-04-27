
#include "Parser.h"
#include <string>
#include <fstream>

using namespace std;

Parser::Parser()
{
}

void Parser::write(const string & fname)
{
    ofstream ofs(fname.c_str());
    ofs << "Content goes here" << endl;
    ofs.close();
}
