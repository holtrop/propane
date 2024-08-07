import testparser;
import std.stdio;

int main()
{
    return 0;
}

unittest
{
    size_t result;
    p_code_point_t code_point;
    ubyte code_point_length;

    result = p_decode_code_point("5", &code_point, &code_point_length);
    assert(result == P_SUCCESS);
    assert(code_point == '5');
    assert(code_point_length == 1u);

    result = p_decode_code_point("", &code_point, &code_point_length);
    assert(result == P_EOF);

    result = p_decode_code_point("\xC2\xA9", &code_point, &code_point_length);
    assert(result == P_SUCCESS);
    assert(code_point == 0xA9u);
    assert(code_point_length == 2u);

    result = p_decode_code_point("\xf0\x9f\xa7\xa1", &code_point, &code_point_length);
    assert(result == P_SUCCESS);
    assert(code_point == 0x1F9E1u);
    assert(code_point_length == 4u);

    result = p_decode_code_point("\xf0\x9f\x27", &code_point, &code_point_length);
    assert(result == P_DECODE_ERROR);

    result = p_decode_code_point("\xf0\x9f\xa7\xFF", &code_point, &code_point_length);
    assert(result == P_DECODE_ERROR);

    result = p_decode_code_point("\xfe", &code_point, &code_point_length);
    assert(result == P_DECODE_ERROR);
}

unittest
{
    p_token_info_t token_info;
    string input = "5 + 4 * \n677 + 567";
    p_context_t context;
    p_context_init(&context, input);
    assert(p_lex(&context, &token_info) == P_SUCCESS);
    assert(token_info == p_token_info_t(p_position_t(0, 0), p_position_t(0, 0), 1, TOKEN_int));
    assert(p_lex(&context, &token_info) == P_SUCCESS);
    assert(token_info == p_token_info_t(p_position_t(0, 2), p_position_t(0, 2), 1, TOKEN_plus));
    assert(p_lex(&context, &token_info) == P_SUCCESS);
    assert(token_info == p_token_info_t(p_position_t(0, 4), p_position_t(0, 4), 1, TOKEN_int));
    assert(p_lex(&context, &token_info) == P_SUCCESS);
    assert(token_info == p_token_info_t(p_position_t(0, 6), p_position_t(0, 6), 1, TOKEN_times));
    assert(p_lex(&context, &token_info) == P_SUCCESS);
    assert(token_info == p_token_info_t(p_position_t(1, 0), p_position_t(1, 2), 3, TOKEN_int));
    assert(p_lex(&context, &token_info) == P_SUCCESS);
    assert(token_info == p_token_info_t(p_position_t(1, 4), p_position_t(1, 4), 1, TOKEN_plus));
    assert(p_lex(&context, &token_info) == P_SUCCESS);
    assert(token_info == p_token_info_t(p_position_t(1, 6), p_position_t(1, 8), 3, TOKEN_int));
    assert(p_lex(&context, &token_info) == P_SUCCESS);
    assert(token_info == p_token_info_t(p_position_t(1, 9), p_position_t(1, 9), 0, TOKEN___EOF));

    p_context_init(&context, "");
    assert(p_lex(&context, &token_info) == P_SUCCESS);
    assert(token_info == p_token_info_t(p_position_t(0, 0), p_position_t(0, 0), 0, TOKEN___EOF));
}
