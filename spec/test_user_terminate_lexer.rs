use testparser::*;

fn main() {
    let mut c = p_context_new(b"a");
    assert_eq!(P_SUCCESS, p_parse(&mut c));
    p_context_delete(c);

    let mut c = p_context_new(b"b");
    assert_eq!(P_USER_TERMINATED, p_parse(&mut c));
    assert_eq!(8675309, p_user_terminate_code(&c));
    p_context_delete(c);
}
