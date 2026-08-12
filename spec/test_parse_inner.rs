use testparser::*;

fn main() {
    let mut c = p_context_new(b"a");
    assert_eq!(P_SUCCESS, p_parse_Start(&mut c));
    assert_eq!(1, p_result_Start(&c));
    p_context_delete(c);

    let mut c = p_context_new(b"ab");
    assert_eq!(P_UNEXPECTED_TOKEN, p_parse_Start(&mut c));
    p_context_delete(c);

    let mut c = p_context_new(b"ab");
    assert_eq!(P_SUCCESS, p_parse_inner_Start(&mut c, &[TOKEN_b]));
    assert_eq!(1, p_result_Start(&c));
    p_context_delete(c);

    let mut c = p_context_new(b"ab");
    assert_eq!(P_UNEXPECTED_TOKEN, p_parse_inner_Start(&mut c, &[]));
    p_context_delete(c);

    let mut c = p_context_new(b"a");
    assert_eq!(P_SUCCESS, p_parse_inner_Start(&mut c, &[TOKEN_b]));
    assert_eq!(1, p_result_Start(&c));
    p_context_delete(c);

    let mut c = p_context_new(b"ab");
    assert_eq!(P_UNEXPECTED_TOKEN, p_parse_inner_Start(&mut c, &[TOKEN___EOF]));
    p_context_delete(c);
}
