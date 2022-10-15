import testparser;
import std.stdio;

int main()
{
    return 0;
}

unittest
{
    alias DCP = Testparser.Decoder.DecodedCodePoint;
    DCP dcp;

    dcp = Testparser.Decoder.decode_code_point("5");
    assert(dcp == DCP('5', 1u));

    dcp = Testparser.Decoder.decode_code_point("");
    assert(dcp == DCP(Testparser.Decoder.CODE_POINT_EOF, 0u));

    dcp = Testparser.Decoder.decode_code_point("\xC2\xA9");
    assert(dcp == DCP(0xA9u, 2u));

    dcp = Testparser.Decoder.decode_code_point("\xf0\x9f\xa7\xa1");
    assert(dcp == DCP(0x1F9E1, 4u));

    dcp = Testparser.Decoder.decode_code_point("\xf0\x9f\x27");
    assert(dcp == DCP(Testparser.Decoder.CODE_POINT_INVALID, 0u));

    dcp = Testparser.Decoder.decode_code_point("\xf0\x9f\xa7\xFF");
    assert(dcp == DCP(Testparser.Decoder.CODE_POINT_INVALID, 0u));

    dcp = Testparser.Decoder.decode_code_point("\xfe");
    assert(dcp == DCP(Testparser.Decoder.CODE_POINT_INVALID, 0u));
}

unittest
{
    alias LT = Testparser.Lexer.LexedToken;
    string input = "5 + 4 * \n677 + 567";
    Testparser.Lexer lexer = new Testparser.Lexer(input);
    assert(lexer.lex_token() == LT(0, 0, 1, Testparser.TOKEN_int));
    assert(lexer.lex_token() == LT(0, 2, 1, Testparser.TOKEN_plus));
    assert(lexer.lex_token() == LT(0, 4, 1, Testparser.TOKEN_int));
    assert(lexer.lex_token() == LT(0, 6, 1, Testparser.TOKEN_times));
    assert(lexer.lex_token() == LT(1, 0, 3, Testparser.TOKEN_int));
    assert(lexer.lex_token() == LT(1, 4, 1, Testparser.TOKEN_plus));
    assert(lexer.lex_token() == LT(1, 6, 3, Testparser.TOKEN_int));
    assert(lexer.lex_token() == LT(1, 9, 0, Testparser.TOKEN_0EOF));

    lexer = new Testparser.Lexer("");
    assert(lexer.lex_token() == LT(0, 0, 0, Testparser.TOKEN_0EOF));
}
