
#include <sstream>
#include <string>

#include "itest.h"

using namespace std;

int main(int argc, char * argv[])
{
    Parser p;
    stringstream t(string(
                "hi there (one and two and three and four) or (two = nine)\n"
                "0x42 12345 0 011 0b0011\n"
                ));
    p.parse(t);
}
