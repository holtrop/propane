use testparser::*;

fn main() {
    let c = p_context_new(b"ab");
    assert_eq!(0, p_input_index(&c));
    p_context_delete(c);

    let mut c = p_context_new(b"a b");
    let mut ti = p_token_info_t::default();
    assert_eq!(P_SUCCESS, p_lex(&mut c, &mut ti));
    assert_eq!(TOKEN_a, ti.token);
    assert_eq!(1, p_input_index(&c));
    assert_eq!(P_SUCCESS, p_lex(&mut c, &mut ti));
    assert_eq!(TOKEN_b, ti.token);
    assert_eq!(3, p_input_index(&c));
    p_context_delete(c);

    let mut c = p_context_new(b"ab");
    assert_eq!(P_SUCCESS, p_parse_Start(&mut c));
    assert_eq!(2, p_input_index(&c));
    p_context_delete(c);

    let mut c = p_context_new(b"abb");
    let follow = [TOKEN_b];
    assert_eq!(P_SUCCESS, p_parse_inner_Start(&mut c, &follow));
    assert_eq!(2, p_input_index(&c));
    p_context_delete(c);
}
