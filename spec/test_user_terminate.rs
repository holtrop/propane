use testparser::*;

fn main() {
    let mut c = p_context_new(b"aacc");
    assert_eq!(P_SUCCESS, p_parse(&mut c));
    p_context_delete(c);

    let mut c = p_context_new(b"abc");
    assert_eq!(P_USER_TERMINATED, p_parse(&mut c));
    assert_eq!(4200, p_user_terminate_code(&c));
    p_context_delete(c);
}
