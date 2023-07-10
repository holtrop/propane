import testparser;
import std.stdio;

int main()
{
    return 0;
}

unittest
{
    size_t result;
    Testparser.CodePoint code_point;
    ubyte code_point_length;

    result = Testparser.Decoder.decode_code_point("5", code_point, code_point_length);
    assert(result == Testparser.P_SUCCESS);
    assert(code_point == '5');
    assert(code_point_length == 1u);

    result = Testparser.Decoder.decode_code_point("", code_point, code_point_length);
    assert(result == Testparser.P_EOF);

    result = Testparser.Decoder.decode_code_point("\xC2\xA9", code_point, code_point_length);
    assert(result == Testparser.P_SUCCESS);
    assert(code_point == 0xA9u);
    assert(code_point_length == 2u);

    result = Testparser.Decoder.decode_code_point("\xf0\x9f\xa7\xa1", code_point, code_point_length);
    assert(result == Testparser.P_SUCCESS);
    assert(code_point == 0x1F9E1u);
    assert(code_point_length == 4u);

    result = Testparser.Decoder.decode_code_point("\xf0\x9f\x27", code_point, code_point_length);
    assert(result == Testparser.P_DECODE_ERROR);

    result = Testparser.Decoder.decode_code_point("\xf0\x9f\xa7\xFF", code_point, code_point_length);
    assert(result == Testparser.P_DECODE_ERROR);

    result = Testparser.Decoder.decode_code_point("\xfe", code_point, code_point_length);
    assert(result == Testparser.P_DECODE_ERROR);
}

unittest
{
    alias TokenInfo = Testparser.Lexer.TokenInfo;
    TokenInfo token_info;
    string input = "5 + 4 * \n677 + 567";
    Testparser.Lexer lexer = new Testparser.Lexer(input);
    assert(lexer.lex_token(&token_info) == Testparser.P_TOKEN);
    assert(token_info == TokenInfo(Testparser.Position(0, 0), 1, Testparser.TOKEN_int));
    assert(lexer.lex_token(&token_info) == Testparser.P_TOKEN);
    assert(token_info == TokenInfo(Testparser.Position(0, 2), 1, Testparser.TOKEN_plus));
    assert(lexer.lex_token(&token_info) == Testparser.P_TOKEN);
    assert(token_info == TokenInfo(Testparser.Position(0, 4), 1, Testparser.TOKEN_int));
    assert(lexer.lex_token(&token_info) == Testparser.P_TOKEN);
    assert(token_info == TokenInfo(Testparser.Position(0, 6), 1, Testparser.TOKEN_times));
    assert(lexer.lex_token(&token_info) == Testparser.P_TOKEN);
    assert(token_info == TokenInfo(Testparser.Position(1, 0), 3, Testparser.TOKEN_int));
    assert(lexer.lex_token(&token_info) == Testparser.P_TOKEN);
    assert(token_info == TokenInfo(Testparser.Position(1, 4), 1, Testparser.TOKEN_plus));
    assert(lexer.lex_token(&token_info) == Testparser.P_TOKEN);
    assert(token_info == TokenInfo(Testparser.Position(1, 6), 3, Testparser.TOKEN_int));
    assert(lexer.lex_token(&token_info) == Testparser.P_TOKEN);
    assert(token_info == TokenInfo(Testparser.Position(1, 9), 0, Testparser.TOKEN___EOF));

    lexer = new Testparser.Lexer("");
    assert(lexer.lex_token(&token_info) == Testparser.P_TOKEN);
    assert(token_info == TokenInfo(Testparser.Position(0, 0), 0, Testparser.TOKEN___EOF));
}
