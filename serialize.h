
#ifndef SERIALIZE_H

#include <iostream>
#include <iconv.h>
#include <vector>
#include "refptr/refptr.h"
#include "unicode.h"
using namespace std;

refptr< vector<unichar_t> > deserialize(const char * encoding, istream & in);

#endif
