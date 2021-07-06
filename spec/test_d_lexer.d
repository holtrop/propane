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
}

unittest
{
    alias LT = Testparser.Lexer.LexedToken;
    string input = "5 + 4 * \n677 + 567";
    Testparser.Lexer lexer = new Testparser.Lexer(cast(const(ubyte) *)input.ptr, input.sizeof);
    //assert(lexer.lex_token() == LT(0, 0, Testparser.TOKEN_INT));
}
