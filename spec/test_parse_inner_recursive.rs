use testparser::*;

fn main() {
    let mut c = p_context_new(b"c");
    assert_eq!(P_SUCCESS, p_parse_Start(&mut c));
    assert_eq!(3, p_result_Start(&c));
    p_context_delete(c);

    let mut c = p_context_new(b"acb");
    assert_eq!(P_SUCCESS, p_parse_Start(&mut c));
    assert_eq!(3, p_result_Start(&c));
    p_context_delete(c);

    let mut c = p_context_new(b"ac");
    assert_eq!(P_UNEXPECTED_TOKEN, p_parse_Start(&mut c));
    p_context_delete(c);

    let mut c = p_context_new(b"ac");
    assert_eq!(P_UNEXPECTED_TOKEN, p_parse_inner_Start(&mut c, &[TOKEN_b, TOKEN___EOF]));
    p_context_delete(c);

    let mut c = p_context_new(b"acb");
    assert_eq!(P_SUCCESS, p_parse_inner_Start(&mut c, &[TOKEN_b]));
    assert_eq!(3, p_result_Start(&c));
    p_context_delete(c);

    let mut c = p_context_new(b"c");
    assert_eq!(P_SUCCESS, p_parse_inner_Start(&mut c, &[TOKEN_b]));
    assert_eq!(3, p_result_Start(&c));
    p_context_delete(c);
}
