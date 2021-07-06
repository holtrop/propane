import testparser;
import std.stdio;

int main()
{
    return 0;
}

unittest
{
    alias DCP = Testparser.Decoder.DecodedCodePoint;
    string inputstring = "5+\n 66";
    const(ubyte) * input = cast(const(ubyte) *)inputstring.ptr;
    size_t input_length = inputstring.length;
    DCP dcp;
    dcp = Testparser.Decoder.decode_code_point(input, input_length);
    assert(dcp == DCP('5', 1u));
    input += dcp.code_point_length;
    input_length -= dcp.code_point_length;
    dcp = Testparser.Decoder.decode_code_point(input, input_length);
    assert(dcp == DCP('+', 1u));
    input += dcp.code_point_length;
    input_length -= dcp.code_point_length;
    dcp = Testparser.Decoder.decode_code_point(input, input_length);
    assert(dcp == DCP('\n', 1u));
    input += dcp.code_point_length;
    input_length -= dcp.code_point_length;
    dcp = Testparser.Decoder.decode_code_point(input, input_length);
    assert(dcp == DCP(' ', 1u));
    input += dcp.code_point_length;
    input_length -= dcp.code_point_length;
    dcp = Testparser.Decoder.decode_code_point(input, input_length);
    assert(dcp == DCP('6', 1u));
    input += dcp.code_point_length;
    input_length -= dcp.code_point_length;
    dcp = Testparser.Decoder.decode_code_point(input, input_length);
    assert(dcp == DCP('6', 1u));
    input += dcp.code_point_length;
    input_length -= dcp.code_point_length;
    dcp = Testparser.Decoder.decode_code_point(input, input_length);
    assert(dcp == DCP(Testparser.Decoder.CODE_POINT_EOF, 0u));

    inputstring = "\xf0\x9f\xa7\xa1";
    input = cast(const(ubyte) *)inputstring.ptr;
    input_length = inputstring.length;
    dcp = Testparser.Decoder.decode_code_point(input, input_length);
    assert(dcp == DCP(0x1F9E1, 4u));
}

unittest
{
    alias LT = Testparser.Lexer.LexedToken;
    string input = "5 + 4 * \n677 + 567";
    Testparser.Lexer lexer = new Testparser.Lexer(cast(const(ubyte) *)input.ptr, input.length);
    assert(lexer.lex_token() == LT(0, 0, Testparser.TOKEN_INT));
    assert(lexer.lex_token() == LT(0, 2, Testparser.TOKEN_PLUS));
    assert(lexer.lex_token() == LT(0, 4, Testparser.TOKEN_INT));
    assert(lexer.lex_token() == LT(0, 6, Testparser.TOKEN_TIMES));
    assert(lexer.lex_token() == LT(1, 0, Testparser.TOKEN_INT));
    assert(lexer.lex_token() == LT(1, 4, Testparser.TOKEN_PLUS));
    assert(lexer.lex_token() == LT(1, 6, Testparser.TOKEN_INT));
    assert(lexer.lex_token() == LT(1, 9, Testparser.TOKEN_EOF));
}
