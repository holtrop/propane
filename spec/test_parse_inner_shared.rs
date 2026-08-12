use testparser::*;

fn main() {
    let mut c = p_context_new(b"aba");
    assert_eq!(P_SUCCESS, p_parse_Start(&mut c));
    p_context_delete(c);

    let mut c = p_context_new(b"abb");
    assert_eq!(P_SUCCESS, p_parse_Start(&mut c));
    p_context_delete(c);

    let mut c = p_context_new(b"ab");
    assert_eq!(P_SUCCESS, p_parse_R1(&mut c));
    assert_eq!(11, p_result_R1(&c));
    p_context_delete(c);

    let mut c = p_context_new(b"abb");
    assert_eq!(P_UNEXPECTED_TOKEN, p_parse_R1(&mut c));
    p_context_delete(c);

    let mut c = p_context_new(b"abb");
    assert_eq!(P_SUCCESS, p_parse_inner_R1(&mut c, &[TOKEN_b]));
    assert_eq!(11, p_result_R1(&c));
    let pos = p_position(&c);
    assert_eq!(1, pos.row);
    assert_eq!(3, pos.col);
    let mut ti = p_token_info_t::default();
    assert_eq!(P_SUCCESS, p_lex(&mut c, &mut ti));
    assert_eq!(TOKEN_b, ti.token);
    assert_eq!(3, ti.position.col);
    p_context_delete(c);

    let mut c = p_context_new(b"aba");
    assert_eq!(P_SUCCESS, p_parse_inner_R1(&mut c, &[TOKEN_a]));
    assert_eq!(11, p_result_R1(&c));
    let pos = p_position(&c);
    assert_eq!(3, pos.col);
    let mut ti = p_token_info_t::default();
    assert_eq!(P_SUCCESS, p_lex(&mut c, &mut ti));
    assert_eq!(TOKEN_a, ti.token);
    p_context_delete(c);

    let mut c = p_context_new(b"ab");
    assert_eq!(P_SUCCESS, p_parse_inner_R1(&mut c, &[]));
    assert_eq!(11, p_result_R1(&c));
    p_context_delete(c);
}
