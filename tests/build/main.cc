
#include <sstream>
#include <string>

#include "itest.h"

using namespace std;

int main(int argc, char * argv[])
{
    Parser p;
    stringstream t(string(
                "hi there (one and two and three and four) or (two = nine)"
                ));
    p.parse(t);
}
