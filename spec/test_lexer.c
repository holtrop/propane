#include "testparser.h"
#include <assert.h>
#include <string.h>

int main()
{
    size_t result;
    p_code_point_t code_point;
    uint8_t code_point_length;

    result = p_decode_code_point((uint8_t const *)"5", 1u, &code_point, &code_point_length);
    assert(result == P_SUCCESS);
    assert(code_point == '5');
    assert(code_point_length == 1u);

    result = p_decode_code_point((uint8_t const *)"", 0u, &code_point, &code_point_length);
    assert(result == P_EOF);

    result = p_decode_code_point((uint8_t const *)"\xC2\xA9", 2u, &code_point, &code_point_length);
    assert(result == P_SUCCESS);
    assert(code_point == 0xA9u);
    assert(code_point_length == 2u);

    result = p_decode_code_point((uint8_t const *)"\xf0\x9f\xa7\xa1", 4u, &code_point, &code_point_length);
    assert(result == P_SUCCESS);
    assert(code_point == 0x1F9E1u);
    assert(code_point_length == 4u);

    result = p_decode_code_point((uint8_t const *)"\xf0\x9f\x27", 3u, &code_point, &code_point_length);
    assert(result == P_DECODE_ERROR);

    result = p_decode_code_point((uint8_t const *)"\xf0\x9f\xa7\xFF", 4u, &code_point, &code_point_length);
    assert(result == P_DECODE_ERROR);

    result = p_decode_code_point((uint8_t const *)"\xfe", 1u, &code_point, &code_point_length);
    assert(result == P_DECODE_ERROR);


    p_token_info_t token_info;
    char const * input = "5 + 4 * \n677 + 567";
    p_context_t context;
    p_context_init(&context, (uint8_t const *)input, strlen(input));
    assert(p_lex(&context, &token_info) == P_SUCCESS);
    assert(token_info.position.row == 0u);
    assert(token_info.position.col == 0u);
    assert(token_info.end_position.row == 0u);
    assert(token_info.end_position.col == 0u);
    assert(token_info.length == 1u);
    assert(token_info.token == TOKEN_int);
    assert(p_lex(&context, &token_info) == P_SUCCESS);
    assert(token_info.position.row == 0u);
    assert(token_info.position.col == 2u);
    assert(token_info.end_position.row == 0u);
    assert(token_info.end_position.col == 2u);
    assert(token_info.length == 1u);
    assert(token_info.token == TOKEN_plus);
    assert(p_lex(&context, &token_info) == P_SUCCESS);
    assert(token_info.position.row == 0u);
    assert(token_info.position.col == 4u);
    assert(token_info.end_position.row == 0u);
    assert(token_info.end_position.col == 4u);
    assert(token_info.length == 1u);
    assert(token_info.token == TOKEN_int);
    assert(p_lex(&context, &token_info) == P_SUCCESS);
    assert(token_info.position.row == 0u);
    assert(token_info.position.col == 6u);
    assert(token_info.end_position.row == 0u);
    assert(token_info.end_position.col == 6u);
    assert(token_info.length == 1u);
    assert(token_info.token == TOKEN_times);
    assert(p_lex(&context, &token_info) == P_SUCCESS);
    assert(token_info.position.row == 1u);
    assert(token_info.position.col == 0u);
    assert(token_info.end_position.row == 1u);
    assert(token_info.end_position.col == 2u);
    assert(token_info.length == 3u);
    assert(token_info.token == TOKEN_int);
    assert(p_lex(&context, &token_info) == P_SUCCESS);
    assert(token_info.position.row == 1u);
    assert(token_info.position.col == 4u);
    assert(token_info.end_position.row == 1u);
    assert(token_info.end_position.col == 4u);
    assert(token_info.length == 1u);
    assert(token_info.token == TOKEN_plus);
    assert(p_lex(&context, &token_info) == P_SUCCESS);
    assert(token_info.position.row == 1u);
    assert(token_info.position.col == 6u);
    assert(token_info.end_position.row == 1u);
    assert(token_info.end_position.col == 8u);
    assert(token_info.length == 3u);
    assert(token_info.token == TOKEN_int);
    assert(p_lex(&context, &token_info) == P_SUCCESS);
    assert(token_info.position.row == 1u);
    assert(token_info.position.col == 9u);
    assert(token_info.end_position.row == 1u);
    assert(token_info.end_position.col == 9u);
    assert(token_info.length == 0u);
    assert(token_info.token == TOKEN___EOF);

    p_context_init(&context, (uint8_t const *)"", 0u);
    assert(p_lex(&context, &token_info) == P_SUCCESS);
    assert(token_info.position.row == 0u);
    assert(token_info.position.col == 0u);
    assert(token_info.end_position.row == 0u);
    assert(token_info.end_position.col == 0u);
    assert(token_info.length == 0u);
    assert(token_info.token == TOKEN___EOF);

    return 0;
}
