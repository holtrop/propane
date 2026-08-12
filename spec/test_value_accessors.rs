use testparser::*;

fn main() {
    let mut c = p_context_new(b"42 f s");
    let mut ti = p_token_info_t::default();

    assert_eq!(P_SUCCESS, p_lex(&mut c, &mut ti));
    assert_eq!(TOKEN_num, ti.token);
    assert_eq!(42, p_value_get(&ti.pvalue));

    assert_eq!(P_SUCCESS, p_lex(&mut c, &mut ti));
    assert_eq!(TOKEN_flt, ti.token);
    assert_eq!(1.5, p_value_get_float(&ti.pvalue));

    assert_eq!(P_SUCCESS, p_lex(&mut c, &mut ti));
    assert_eq!(TOKEN_str, ti.token);
    assert_eq!("hello", p_value_get_string(&ti.pvalue));

    p_context_delete(c);
}
