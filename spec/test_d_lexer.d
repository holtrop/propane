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

    inputstring = "\xf0\x1f\x27\x21";
    input = cast(const(ubyte) *)inputstring.ptr;
    input_length = inputstring.length;
    dcp = Testparser.Decoder.decode_code_point(input, input_length);
    assert(dcp == DCP(0x1F9E1, 4u));

    inputstring = "\xf0\x1f\x27";
    input = cast(const(ubyte) *)inputstring.ptr;
    input_length = inputstring.length;
    dcp = Testparser.Decoder.decode_code_point(input, input_length);
    assert(dcp == DCP(Testparser.Decoder.CODE_POINT_INVALID, 0u));

    inputstring = "\xf0\x1f\x27\xFF";
    input = cast(const(ubyte) *)inputstring.ptr;
    input_length = inputstring.length;
    dcp = Testparser.Decoder.decode_code_point(input, input_length);
    assert(dcp == DCP(Testparser.Decoder.CODE_POINT_INVALID, 0u));

    inputstring = "\xfe";
    input = cast(const(ubyte) *)inputstring.ptr;
    input_length = inputstring.length;
    dcp = Testparser.Decoder.decode_code_point(input, input_length);
    assert(dcp == DCP(Testparser.Decoder.CODE_POINT_INVALID, 0u));
}

unittest
{
    alias LT = Testparser.Lexer.LexedToken;
    string input = "5 + 4 * \n677 + 567";
    Testparser.Lexer lexer = new Testparser.Lexer(cast(const(ubyte) *)input.ptr, input.length);
    assert(lexer.lex_token() == LT(0, 0, 1, Testparser.TOKEN_int));
    assert(lexer.lex_token() == LT(0, 2, 1, Testparser.TOKEN_plus));
    assert(lexer.lex_token() == LT(0, 4, 1, Testparser.TOKEN_int));
    assert(lexer.lex_token() == LT(0, 6, 1, Testparser.TOKEN_times));
    assert(lexer.lex_token() == LT(1, 0, 3, Testparser.TOKEN_int));
    assert(lexer.lex_token() == LT(1, 4, 1, Testparser.TOKEN_plus));
    assert(lexer.lex_token() == LT(1, 6, 3, Testparser.TOKEN_int));
    assert(lexer.lex_token() == LT(1, 9, 0, Testparser.TOKEN_0EOF));

    lexer = new Testparser.Lexer(null, 0u);
    assert(lexer.lex_token() == LT(0, 0, 0, Testparser.TOKEN_0EOF));
}
