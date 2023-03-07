import testparser;
import std.stdio;

int main()
{
    return 0;
}

unittest
{
    alias Result = Testparser.Decoder.Result;
    Result result;

    result = Testparser.Decoder.decode_code_point("5");
    assert(result == Result.success('5', 1u));

    result = Testparser.Decoder.decode_code_point("");
    assert(result == Result.eof());

    result = Testparser.Decoder.decode_code_point("\xC2\xA9");
    assert(result == Result.success(0xA9u, 2u));

    result = Testparser.Decoder.decode_code_point("\xf0\x9f\xa7\xa1");
    assert(result == Result.success(0x1F9E1, 4u));

    result = Testparser.Decoder.decode_code_point("\xf0\x9f\x27");
    assert(result == Result.decode_error());

    result = Testparser.Decoder.decode_code_point("\xf0\x9f\xa7\xFF");
    assert(result == Result.decode_error());

    result = Testparser.Decoder.decode_code_point("\xfe");
    assert(result == Result.decode_error());
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
